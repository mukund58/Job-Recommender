# plumber API for job recommendations using local job postings dataset
library(plumber)
library(jsonlite)
library(readr)
library(stringr)
library(dplyr)
library(purrr)

# CORS filter
#* @filter cors
cors <- function(req, res) {
  res$setHeader('Access-Control-Allow-Origin', '*')
  res$setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
  res$setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
  if (req$REQUEST_METHOD == 'OPTIONS') {
    res$status <- 200
    return(list())
  }
  plumber::forward()
}

# Helper: load jobs dataset (cached)
clean_text <- function(text) {
  # Basic cleaning similar to the preprocessing script: lowercase, remove numbers/punct, collapse spaces
  if (is.na(text) || length(text) == 0) return("")
  txt <- tolower(text)
  txt <- gsub("[0-9]+", " ", txt)
  txt <- gsub("[[:punct:]]+", " ", txt)
  txt <- gsub("\\s+", " ", txt)
  txt <- trimws(txt)
  txt
}
base_dir <- "/home/bun/play/react/08-PdfExtracter/PdfExtracter/server/r_backend"

load_jobs <- function() {
  message('load_jobs called')
  message('getwd(): ', getwd())
  base <- getwd()
  message('base: ', base)
  # Prefer cleaned JSON, then larger datasets
  candidates <- c('data/enhanced_jobs_step3.json', 'data/cleaned_jobs_5k.json')
  chosen <- NULL
  is_json <- FALSE
  for (c in candidates) {
    p <- file.path(base, c)
    message('Checking: ', p, ' exists: ', file.exists(p))
    if (file.exists(p)) { 
      chosen <- p
      is_json <- grepl('\\.json$', c)
      break
    }
  }

  

  message('Loading jobs from: ', chosen)
  df <- if (is_json) {
    tryCatch({
      data <- jsonlite::fromJSON(chosen)
      message('Parsed JSON with ', length(data), ' items')
      as_tibble(data)
    }, error = function(e) {
      warning('Failed reading jobs JSON: ', e$message)
      message('JSON read error: ', e$message)
      return(tibble::tibble())
    })
  } else {
    tryCatch(
      read_csv(chosen, col_types = cols(.default = col_character())),
      error = function(e) {
        warning('Failed reading jobs CSV: ', e$message)
        return(tibble::tibble())
      }
    )
  }

  message('Loaded dataframe with ', nrow(df), ' rows and ', ncol(df), ' columns')
  if (nrow(df) == 0) {
    message('No rows in dataframe, returning empty')
    return(df)
  }

  # Ensure required columns exist
  if (!'title' %in% names(df)) df$title <- ''
  if (!'description' %in% names(df)) df$description <- ''
  if (!'skills' %in% names(df)) df$skills <- ''
  if (!'id' %in% names(df)) df$id <- as.character(seq_len(nrow(df)))

  # If not already cleaned (for CSV files), apply basic cleaning
  if (!is_json) {
    df <- df %>% mutate(
      title_clean = sapply(title, clean_text),
      description_clean = sapply(description, clean_text)
    )
    # remove duplicates by title_clean
    df <- df[!duplicated(df$title_clean), ]
  } else {
    # JSON is already cleaned, set title_clean and description_clean if missing
    if (!'title_clean' %in% names(df)) df$title_clean <- sapply(df$title, clean_text)
    if (!'description_clean' %in% names(df)) df$description_clean <- sapply(df$description, clean_text)
  }

  df
  
}

# Simple scoring: count number of exact skill matches (word boundaries) in title/description/skills
score_jobs <- function(jobs_df, skills) {
  if (length(skills) == 0) {
    return(jobs_df %>% mutate(score = 0, matches = 0))
  }

  skills_lower <- tolower(skills)

  # Load word frequency safely
  freq_path <- file.path(base_dir, "data", "word_frequency.csv")
  if (!file.exists(freq_path)) {
    warning("⚠️ word_frequency.csv not found, using equal weights")
    freq_df <- tibble(word = skills_lower, weight = 1)
  } else {
    freq_df <- suppressMessages(read_csv(freq_path, col_types = cols(.default = col_character()))) %>%
      mutate(frequency = as.numeric(frequency)) %>%
      filter(!is.na(frequency)) %>%
      mutate(weight = log1p(frequency)) %>%
      select(word, weight)
  }

  # Build named vector for lookup
  weight_map <- setNames(freq_df$weight, freq_df$word)

  # Safe lookup helper
  get_weight <- function(skill) {
    if (skill %in% names(weight_map)) {
      weight_map[[skill]]
    } else {
      1  # default fallback weight if not found
    }
  }

  jobs_df %>%
    rowwise() %>%
    mutate(
      text = tolower(paste(title_clean, description_clean, skills_extracted, tags, sep = " ")),
      matched_skills = list(skills_lower[sapply(skills_lower, function(s) grepl(s, text, fixed = TRUE))]),
      matches = length(matched_skills),
      weighted_score = sum(sapply(skills_lower, function(s) {
        if (grepl(s, text, fixed = TRUE)) get_weight(s) else 0
      })),
      score = weighted_score / sum(sapply(skills_lower, get_weight))
    ) %>%
    ungroup()
}



#* Recommend jobs based on provided skills
#* @param body The JSON body containing { skills: ["skill1","skill2"] }
#* @post /recommend
function(req, res) {
  # parse body
  payload <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) list())
  skills <- payload$skills
  if (is.null(skills) || length(skills) == 0) {
    res$status <- 200
    return(list(results = list(), message = 'No skills provided'))
  }

  jobs_df <- load_jobs()
  if (nrow(jobs_df) == 0) {
    res$status <- 200
    return(list(results = list(), message = 'No job postings available'))
  }

  scored <- score_jobs(jobs_df, skills)
  ranked <- scored %>% arrange(desc(score)) %>% filter(score > 0)
  # format top 10
topn <- head(ranked, 10)
results <- topn %>%
  select(title_clean, company_name, location, score, matches, matched_skills, description, tags, job_category, seniority_level, remote_type, employment_type, salary_range) %>%
  purrr::pmap(function(title_clean, company_name, location, score, matches, matched_skills, description, tags, job_category, seniority_level, remote_type, employment_type, salary_range) {
    list(
      title_clean = title_clean,
      company_name = company_name,
      location = location,
      score = round(score * 100, 1),  # as percentage
      matches = matches,
      matched_skills = matched_skills,
      description = description,
      tags = tags,
      job_category = job_category,
      seniority_level = seniority_level,
      remote_type = remote_type,
      employment_type = employment_type,
      salary_range = salary_range
    )
  })


  res$status <- 200
  return(list(results = results))
}

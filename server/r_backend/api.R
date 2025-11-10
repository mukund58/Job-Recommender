library(plumber)
library(jsonlite)
library(readr)
library(stringr)
library(dplyr)
library(purrr)

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

clean_text <- function(text) {
  if (is.na(text) || length(text) == 0) return("")
  txt <- tolower(text)
  txt <- gsub("[0-9]+", " ", txt)
  txt <- gsub("[[:punct:]]+", " ", txt)
  txt <- gsub("\\s+", " ", txt)
  txt <- trimws(txt)
  txt
}

load_jobs <- function() {
  candidates <- c('data/enhanced_jobs_step3.json', 'data/cleaned_jobs_5k.json')
  for (c in candidates) {
    p <- file.path(getwd(), c)
    if (file.exists(p)) {
      is_json <- grepl('\\.json$', c)
      df <- if (is_json) {
        data <- jsonlite::fromJSON(p)
        as_tibble(data)
      } else {
        read_csv(p, col_types = cols(.default = col_character()))
      }
      if (nrow(df) == 0) return(df)
      if (!'title' %in% names(df)) df$title <- ''
      if (!'description' %in% names(df)) df$description <- ''
      if (!'skills' %in% names(df)) df$skills <- ''
      if (!'id' %in% names(df)) df$id <- as.character(seq_len(nrow(df)))
      if (!is_json) {
        df <- df %>% mutate(
          title_clean = sapply(title, clean_text),
          description_clean = sapply(description, clean_text)
        )
        df <- df[!duplicated(df$title_clean), ]
      } else {
        if (!'title_clean' %in% names(df)) df$title_clean <- sapply(df$title, clean_text)
        if (!'description_clean' %in% names(df)) df$description_clean <- sapply(df$description, clean_text)
      }
      return(df)
    }
  }
  return(tibble::tibble())
}

score_jobs <- function(jobs_df, skills) {
  if (length(skills) == 0) {
    return(jobs_df %>% mutate(score = 0, matches = 0))
  }
  skills_lower <- tolower(skills)
  freq_path <- file.path(getwd(), "data", "word_frequency.csv")
  if (!file.exists(freq_path)) {
    freq_df <- tibble(word = skills_lower, weight = 1)
  } else {
    freq_df <- suppressMessages(read_csv(freq_path, col_types = cols(.default = col_character()))) %>%
      mutate(frequency = as.numeric(frequency)) %>%
      filter(!is.na(frequency)) %>%
      mutate(weight = log1p(frequency)) %>%
      select(word, weight)
  }
  weight_map <- setNames(freq_df$weight, freq_df$word)
  get_weight <- function(skill) {
    if (skill %in% names(weight_map)) weight_map[[skill]] else 1
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

#* @param body The JSON body containing { skills: ["skill1","skill2"] }
#* @post /recommend
function(req, res) {
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
  topn <- head(ranked, 10)
  results <- topn %>%
    select(title_clean, company_name, location, score, matches, matched_skills, description, tags, job_category, seniority_level, remote_type, employment_type, salary_range) %>%
    purrr::pmap(function(title_clean, company_name, location, score, matches, matched_skills, description, tags, job_category, seniority_level, remote_type, employment_type, salary_range) {
      list(
        title_clean = title_clean,
        company_name = company_name,
        location = location,
        score = round(score * 100, 1),
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

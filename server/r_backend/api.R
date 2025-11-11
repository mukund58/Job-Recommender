library(plumber)
library(jsonlite)
library(dplyr)
library(purrr)
library(tibble)
library(stringr)
library(lubridate)

# Inline if function for concise null checks
iif <- function(condition, true_value, false_value) {
  if (condition) true_value else false_value
}

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

load_jobs <- function() {
  path <- 'data/enhanced_jobs_step3.json'
  if (file.exists(path)) {
    df <- jsonlite::fromJSON(path) %>% as_tibble()
    if (nrow(df) > 0) {
      df <- df %>% mutate(date_time = as.POSIXct(date_time))
      return(df)
    }
  }
  return(tibble())
}

score_jobs <- function(jobs_df, skills) {
  if (length(skills) == 0) return(jobs_df %>% mutate(score = 0, matches = 0))
  skills_lower <- tolower(skills)
  jobs_df %>%
    rowwise() %>%
    mutate(
      text = tolower(paste(title_clean, description_clean, skills_extracted, tags, sep = " ")),
      matched_skills = list(skills_lower[sapply(skills_lower, function(s) grepl(s, text, fixed = TRUE))]),
      matches = length(matched_skills),
      score = matches / length(skills_lower)
    ) %>%
    ungroup()
}

#* @post /recommend
function(req, res) {
  payload <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) list())
  skills <- payload$skills
  if (is.null(skills) || length(skills) == 0) {
    return(list(results = list(), message = 'No skills provided'))
  }
  jobs_df <- load_jobs()
  if (nrow(jobs_df) == 0) {
    return(list(results = list(), message = 'No job postings available'))
  }
  scored <- score_jobs(jobs_df, skills)
  ranked <- scored %>% arrange(desc(score)) %>% filter(score > 0) %>% head(10)
  results <- ranked %>%
    mutate(posted_date = if_else(grepl("\\d+.*ago", posted_at), {
      parts <- str_match(posted_at, "(\\d+)\\s+(hour|minute|day|week|month|year)s?\\s+ago")
      if (!is.na(parts[1,1])) {
        num <- as.numeric(parts[1,2])
        unit <- parts[1,3]
        unit_map <- c(hour = "hours", minute = "mins", day = "days", week = "weeks", month = "months", year = "years")
        unit <- unit_map[unit]
        if (is.na(unit)) unit <- "days"
        date_time - as.difftime(num, units = unit)
      } else {
        NA
      }
    }, NA)) %>%
    mutate(posted_date = as.character(posted_date)) %>%
    select(title_clean, company_name, location, posted_date, score, matches, matched_skills, description, tags, job_category, seniority_level, remote_type, employment_type, salary_range) %>%
    mutate(score = round(score * 100, 1)) %>%
    pmap(function(...) as.list(list(...)))
  return(list(results = results))
}

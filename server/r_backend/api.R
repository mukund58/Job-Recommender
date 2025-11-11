library(plumber)
library(jsonlite)
library(dplyr)
library(purrr)
library(tibble)

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
    if (nrow(df) > 0) return(df)
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
    select(title_clean, company_name, location, score, matches, matched_skills, description, tags, job_category, seniority_level, remote_type, employment_type, salary_range) %>%
    mutate(score = round(score * 100, 1)) %>%
    pmap(function(...) as.list(list(...)))
  return(list(results = results))
}

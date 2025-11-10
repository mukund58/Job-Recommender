library(stringr)
library(jsonlite)

jobs_5k <- read.csv("server/r_backend/data/enhanced_jobs_step1.csv", stringsAsFactors = FALSE)

extract_salary <- function(text) {
  pattern <- "(₹|\\$)\\s?\\d+[kK]?(–|-|to)?\\s?(₹|\\$)?\\s?\\d*[kK]?"
  match <- str_extract(text, pattern)
  ifelse(is.na(match), "Not specified", match)
}

jobs_5k$salary_range <- sapply(jobs_5k$description, extract_salary)

normalize_employment_type <- function(text) {
  if (is.na(text)) return("Not specified")
  if (str_detect(text, regex("full[- ]?time", ignore_case = TRUE))) return("Full-time")
  if (str_detect(text, regex("part[- ]?time", ignore_case = TRUE))) return("Part-time")
  if (str_detect(text, regex("contract", ignore_case = TRUE))) return("Contract")
  if (str_detect(text, regex("intern|internship", ignore_case = TRUE))) return("Internship")
  return("Other")
}

jobs_5k$employment_type <- sapply(paste(jobs_5k$extensions, jobs_5k$description), normalize_employment_type)

convert_to_days <- function(time_str) {
  if (is.na(time_str) || nchar(time_str) == 0) return(NA)
  if (str_detect(time_str, "hour")) return(0)
  if (str_detect(time_str, "day")) {
    num <- as.numeric(str_extract(time_str, "\\d+"))
    return(ifelse(is.na(num), 0, num))
  }
  if (str_detect(time_str, "week")) {
    num <- as.numeric(str_extract(time_str, "\\d+"))
    return(ifelse(is.na(num), 0, num * 7))
  }
  if (str_detect(time_str, "month")) {
    num <- as.numeric(str_extract(time_str, "\\d+"))
    return(ifelse(is.na(num), 0, num * 30))
  }
  return(NA)
}

jobs_5k$posted_days_ago <- sapply(jobs_5k$posted_at, convert_to_days)

detect_remote_type <- function(text) {
  if (str_detect(text, regex("remote|work from home|wfh", ignore_case = TRUE))) return("Remote")
  if (str_detect(text, regex("hybrid", ignore_case = TRUE))) return("Hybrid")
  if (str_detect(text, regex("onsite|on-site|office", ignore_case = TRUE))) return("Onsite")
  return("Not specified")
}

jobs_5k$remote_type <- sapply(paste(jobs_5k$title, jobs_5k$description), detect_remote_type)

normalize_platform <- function(via_text) {
  if (is.na(via_text)) return("Unknown")
  if (str_detect(via_text, regex("linkedin", ignore_case = TRUE))) return("LinkedIn")
  if (str_detect(via_text, regex("indeed", ignore_case = TRUE))) return("Indeed")
  if (str_detect(via_text, regex("naukri", ignore_case = TRUE))) return("Naukri")
  if (str_detect(via_text, regex("glassdoor", ignore_case = TRUE))) return("Glassdoor")
  return("Other")
}

jobs_5k$source_platform <- sapply(jobs_5k$via, normalize_platform)

write.csv(jobs_5k, "server/r_backend/data/enhanced_jobs_step2.csv", row.names = FALSE)
write_json(jobs_5k, "server/r_backend/data/enhanced_jobs_step2.json", pretty = TRUE)

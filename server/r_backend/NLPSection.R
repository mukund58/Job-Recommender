library(stringr)
library(tm)
library(jsonlite)

jobs_5k <- read.csv("server/r_backend/data/cleaned_jobs_5k.csv", stringsAsFactors = FALSE)

# define skill list
skill_list <- c("python","r","sql","excel","tableau","powerbi","spark","hadoop",
                "java","c\\+\\+","c#","javascript","react","node","aws","azure",
                "docker","kubernetes","tensorflow","pytorch","hive","alteryx",
                "sas","matlab","scala","go","php")

# extract skills from description
extract_skills <- function(text) {
  found <- skill_list[str_detect(text, regex(skill_list, ignore_case = TRUE))]
  found <- unique(tolower(found))
  if (length(found) == 0) return(NA)
  return(paste(found, collapse = ", "))
}

jobs_5k$skills_extracted <- sapply(jobs_5k$description_clean, extract_skills)

# determine seniority level
get_seniority <- function(title) {
  if (str_detect(title, regex("intern|junior|entry", ignore_case = TRUE))) return("Junior")
  if (str_detect(title, regex("senior|lead|principal|manager|head", ignore_case = TRUE))) return("Senior")
  return("Mid-level")
}

jobs_5k$seniority_level <- sapply(jobs_5k$title, get_seniority)

# determine job category
get_category <- function(title) {
  if (str_detect(title, "data scientist|machine learning|ml")) return("Data Science")
  if (str_detect(title, "data analyst|business analyst")) return("Analytics")
  if (str_detect(title, "software|developer|engineer")) return("Software Engineering")
  if (str_detect(title, "devops|cloud|infrastructure")) return("DevOps")
  if (str_detect(title, "product manager|project manager")) return("Product/Management")
  return("Other")
}

jobs_5k$job_category <- sapply(jobs_5k$title_clean, get_category)

# define tool list
tool_list <- c("tableau","hive","alteryx","etl","powerbi","airflow","kafka","snowflake",
               "looker","bigquery","databricks","informatica","pentaho")

# extract tools from description
extract_tools <- function(text) {
  found <- tool_list[str_detect(text, regex(tool_list, ignore_case = TRUE))]
  found <- unique(tolower(found))
  if (length(found) == 0) return(NA)
  return(paste(found, collapse = ", "))
}

jobs_5k$tools_used <- sapply(jobs_5k$description_clean, extract_tools)

# clean and deduplicate keywords
get_keywords <- function(text) {
  tokens <- unlist(str_split(text, "\\s+"))
  tokens <- tokens[!tokens %in% stopwords("en")]
  tokens <- tokens[nchar(tokens) > 2]
  tokens <- unique(tokens)
  return(paste(tokens, collapse = ", "))
}

jobs_5k$keywords_clean <- sapply(jobs_5k$description_clean, get_keywords)

write.csv(jobs_5k, "server/r_backend/data/enhanced_jobs_step1.csv", row.names = FALSE)
write_json(jobs_5k, "server/r_backend/data/enhanced_jobs_step1.json", pretty = TRUE)

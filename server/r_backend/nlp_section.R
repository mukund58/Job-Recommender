# --- STEP 1: ML / NLP FEATURES ---

library(stringr)
library(tm)
library(jsonlite)

# Load cleaned jobs (from your previous script)
jobs_5k <- read.csv("server/r_backend/cleaned_jobs_5k.csv", stringsAsFactors = FALSE)

# --------------------------
# 1️⃣ Extract skills
# --------------------------
skill_list <- c("python","r","sql","excel","tableau","powerbi","spark","hadoop",
                "java","c\\+\\+","c#","javascript","react","node","aws","azure",
                "docker","kubernetes","tensorflow","pytorch","hive","alteryx",
                "sas","matlab","scala","go","php")

extract_skills <- function(text) {
  found <- skill_list[str_detect(text, regex(skill_list, ignore_case = TRUE))]
  found <- unique(tolower(found))
  if (length(found) == 0) return(NA)
  return(paste(found, collapse = ", "))
}

jobs_5k$skills_extracted <- sapply(jobs_5k$description_clean, extract_skills)

# --------------------------
# 2️⃣ Determine seniority level
# --------------------------
get_seniority <- function(title) {
  if (str_detect(title, regex("intern|junior|entry", ignore_case = TRUE))) return("Junior")
  if (str_detect(title, regex("senior|lead|principal|manager|head", ignore_case = TRUE))) return("Senior")
  return("Mid-level")
}

jobs_5k$seniority_level <- sapply(jobs_5k$title, get_seniority)

# --------------------------
# 3️⃣ Determine job category
# --------------------------
get_category <- function(title) {
  if (str_detect(title, "data scientist|machine learning|ml")) return("Data Science")
  if (str_detect(title, "data analyst|business analyst")) return("Analytics")
  if (str_detect(title, "software|developer|engineer")) return("Software Engineering")
  if (str_detect(title, "devops|cloud|infrastructure")) return("DevOps")
  if (str_detect(title, "product manager|project manager")) return("Product/Management")
  return("Other")
}

jobs_5k$job_category <- sapply(jobs_5k$title_clean, get_category)

# --------------------------
# 4️⃣ Extract tools used
# --------------------------
tool_list <- c("tableau","hive","alteryx","etl","powerbi","airflow","kafka","snowflake",
               "looker","bigquery","databricks","informatica","pentaho")

extract_tools <- function(text) {
  found <- tool_list[str_detect(text, regex(tool_list, ignore_case = TRUE))]
  found <- unique(tolower(found))
  if (length(found) == 0) return(NA)
  return(paste(found, collapse = ", "))
}

jobs_5k$tools_used <- sapply(jobs_5k$description_clean, extract_tools)

# --------------------------
# 5️⃣ Clean & deduplicate keywords
# --------------------------
get_keywords <- function(text) {
  tokens <- unlist(str_split(text, "\\s+"))
  tokens <- tokens[!tokens %in% stopwords("en")]
  tokens <- tokens[nchar(tokens) > 2]
  tokens <- unique(tokens)
  return(paste(tokens, collapse = ", "))
}

jobs_5k$keywords_clean <- sapply(jobs_5k$description_clean, get_keywords)

# Save enhanced dataset
write.csv(jobs_5k, "server/r_backend/enhanced_jobs_step1.csv", row.names = FALSE)
write_json(jobs_5k, "server/r_backend/enhanced_jobs_step1.json", pretty = TRUE)

message("✅ Step 1 complete: ML/NLP fields added (skills_extracted, seniority_level, job_category, tools_used, keywords_clean).")

library(stringr)
library(jsonlite)

jobs_5k <- read.csv("server/r_backend/data/enhanced_jobs_step2.csv", stringsAsFactors = FALSE)

# short description (first 150 characters)
jobs_5k$short_description <- substr(jobs_5k$description, 1, 150)

# skills count
jobs_5k$skills_count <- sapply(jobs_5k$skills_extracted, function(x) {
  skills <- str_extract_all(x, "[a-zA-Z0-9_\\+\\#\\.]+")[[1]]
  length(unique(tolower(skills)))
})

# placeholder for match score
jobs_5k$match_score <- NA

# generate tags for filtering
generate_tags <- function(category, skills, keywords) {
  skill_list <- str_extract_all(skills, "[a-zA-Z0-9_\\+\\#\\.]+")[[1]]
  keyword_list <- str_extract_all(keywords, "[a-zA-Z0-9_\\+\\#\\.]+")[[1]]
  
  tags <- unique(c(
    category,
    tolower(head(skill_list, 2)),
    tolower(head(keyword_list, 1))
  ))
  
  paste(tags[!is.na(tags) & tags != ""], collapse = ", ")
}

jobs_5k$tags <- mapply(generate_tags,
                       jobs_5k$job_category,
                       jobs_5k$skills_extracted,
                       jobs_5k$keywords_clean)

write.csv(jobs_5k, "server/r_backend/data/enhanced_jobs_step3.csv", row.names = FALSE)
write_json(jobs_5k, "server/r_backend/data/enhanced_jobs_step3.json", pretty = TRUE)

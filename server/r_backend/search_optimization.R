# --- STEP 3: SEARCH OPTIMIZATION / UI FEATURES ---

library(stringr)
library(jsonlite)

# Load data from previous step
jobs_5k <- read.csv("server/r_backend/data/enhanced_jobs_step2.csv", stringsAsFactors = FALSE)

# --------------------------
# 1️⃣ Short description (first ~150 characters)
# --------------------------
jobs_5k$short_description <- substr(jobs_5k$description, 1, 150)

# --------------------------
# 2️⃣ Skills count
# --------------------------
jobs_5k$skills_count <- sapply(jobs_5k$skills_extracted, function(x) {
  # Handle list-like string ["a", "b"]
  skills <- str_extract_all(x, "[a-zA-Z0-9_\\+\\#\\.]+")[[1]]
  length(unique(tolower(skills)))
})

# --------------------------
# 3️⃣ Placeholder for match score
# --------------------------
jobs_5k$match_score <- NA  # to be filled later during resume-job matching phase

# --------------------------
# 4️⃣ Tags for filtering / UI chips
# --------------------------
# Combine job_category + top 2 skills + one keyword to make tags
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

# Save final enriched dataset
write.csv(jobs_5k, "server/r_backend/data/enhanced_jobs_step3.csv", row.names = FALSE)
write_json(jobs_5k, "server/r_backend/data/enhanced_jobs_step3.json", pretty = TRUE)

message("✅ Step 3 complete: Added UI/search optimization fields (short_description, skills_count, match_score, tags).")

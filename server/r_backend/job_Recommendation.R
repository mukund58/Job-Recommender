options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install required packages if missing (non-interactive)
required_pkgs <- c('readr','dplyr','tidyverse','tm','stringr','jsonlite','purrr','tibble')
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    message('Installing missing package: ', p)
    install.packages(p, repos = options()$repos)
  }
}

# Load libraries
library(readr)
library(dplyr)
library(tidyverse)
library(tm)
library(stringr)
library(jsonlite)

setwd("/home/bun/play/react/08-PdfExtracter/PdfExtracter/server/r_backend/")

# --- LOAD EXISTING FILE ---
# input_path <- file.path("server", "r_backend", "gsearch_jobs.csv")

# if (!file.exists(input_path)) {
#   stop("Could not find gsearch_jobs.csv. Place it in server/r_backend/data/")
# }

# message("Loading jobs from: ", input_path)
library(readr)

library(readr)

jobs <- read_csv(
  "data/gsearch_jobs.csv",
  quote = "\"",
  trim_ws = TRUE,
  show_col_types = FALSE
)
dim(jobs)
colnames(jobs)
head(jobs[1:3])


glimpse(jobs)
# jobs_noNA <- jobs %>% na.omit()
# glimpse(jobs)

jobs_5k <- head(jobs, 5000)
write_csv(jobs_5k, "data/gsearch_jobs_5k.csv")



# --- CLEANING ---
jobs_5k <- jobs_5k %>%
  mutate(
    title       = tolower(title),
    location    = tolower(location),
    description = tolower(description)
  )

# --- CLEAN TEXT FUNCTION ---
clean_text <- function(text) {
  if (is.na(text)) return(NA_character_)
  text <- tolower(text)
  text <- removeNumbers(text)
  text <- removePunctuation(text)
  text <- stripWhitespace(text)
  text <- removeWords(text, stopwords("en"))
  return(text)
}

# Apply cleaning
jobs_5k$title_clean        <- sapply(jobs_5k$title, clean_text)
jobs_5k$location_clean     <- sapply(jobs_5k$location, clean_text)
jobs_5k$description_clean  <- sapply(jobs_5k$description, clean_text)

# Remove duplicates
jobs_5k <- jobs_5k[!duplicated(jobs_5k$title_clean), ]

# Split words and compute frequency
jobs_5k$title_tokens <- str_split(jobs_5k$title_clean, "\\s+")
all_words <- unlist(jobs_5k$title_tokens)
word_freq <- sort(table(all_words), decreasing = TRUE)
# word_freq_df <- as.data.frame(word_freq)
# colnames(word_freq_df) <- c("word", "frequency")
word_freq <- sort(table(all_words), decreasing = TRUE)
word_freq_df <- as.data.frame(word_freq)

if (ncol(word_freq_df) == 1) {
  names(word_freq_df) <- "word"
} else {
  names(word_freq_df) <- c("word", "frequency")
}

# Save outputs
write.csv(word_freq_df, "data/word_frequency.csv", row.names = FALSE)

# Flatten list column before saving to CSV
jobs_5k$title_tokens <- sapply(jobs_5k$title_tokens, function(x) paste(unlist(x), collapse = " "))

write.csv(jobs_5k, "data/cleaned_jobs_5k.csv", row.names = FALSE)
write_json(jobs_5k, "data/cleaned_jobs_5k.json", pretty = TRUE)
message("✅ Cleaning complete. Files saved to server/r_backend/data/")

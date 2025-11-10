options(repos = c(CRAN = "https://cloud.r-project.org"))
required_pkgs <- c('readr','dplyr','tidyverse','tm','stringr','jsonlite','purrr','tibble')
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = options()$repos)
  }
}
library(readr)
library(dplyr)
library(tidyverse)
library(tm)
library(stringr)
library(jsonlite)

jobs <- read_csv("data/gsearch_jobs.csv", quote = "\"", trim_ws = TRUE, show_col_types = FALSE)
jobs_5k <- head(jobs, 5000)
write_csv(jobs_5k, "data/gsearch_jobs_5k.csv")

jobs_5k <- jobs_5k %>% mutate(title = tolower(title), location = tolower(location), description = tolower(description))

clean_text <- function(text) {
  if (is.na(text)) return(NA_character_)
  text <- tolower(text)
  text <- removeNumbers(text)
  text <- removePunctuation(text)
  text <- stripWhitespace(text)
  text <- removeWords(text, stopwords("en"))
  return(text)
}

jobs_5k$title_clean <- sapply(jobs_5k$title, clean_text)
jobs_5k$location_clean <- sapply(jobs_5k$location, clean_text)
jobs_5k$description_clean <- sapply(jobs_5k$description, clean_text)
jobs_5k <- jobs_5k[!duplicated(jobs_5k$title_clean), ]

jobs_5k$title_tokens <- str_split(jobs_5k$title_clean, "\\s+")
all_words <- unlist(jobs_5k$title_tokens)
word_freq <- sort(table(all_words), decreasing = TRUE)
word_freq_df <- as.data.frame(word_freq)
if (ncol(word_freq_df) == 1) names(word_freq_df) <- "word" else names(word_freq_df) <- c("word", "frequency")

write.csv(word_freq_df, "data/word_frequency.csv", row.names = FALSE)
jobs_5k$title_tokens <- sapply(jobs_5k$title_tokens, function(x) paste(unlist(x), collapse = " "))
write.csv(jobs_5k, "data/cleaned_jobs_5k.csv", row.names = FALSE)
write_json(jobs_5k, "data/cleaned_jobs_5k.json", pretty = TRUE)

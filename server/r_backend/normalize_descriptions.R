library(jsonlite)
library(stringr)
library(dplyr)

# Load the enhanced jobs data
jobs <- fromJSON('data/enhanced_jobs_step3.json')

# Function to normalize description formatting
normalize_description <- function(desc) {
  if (is.na(desc) || desc == "") return(desc)

  # If description already has line breaks, preserve them
  if (grepl("\\n", desc)) {
    return(desc)
  }

  # For descriptions without line breaks, add basic formatting
  # Split on periods followed by spaces and capitalize next word (basic sentence splitting)
  desc <- str_replace_all(desc, "\\. ([A-Z])", ".\n\n\\1")

  # Look for bullet point indicators and format them
  desc <- str_replace_all(desc, "•", "\n•")

  # Look for numbered lists
  desc <- str_replace_all(desc, "(\\d+)\\.", "\n\\1.")

  # Look for common section headers and add line breaks
  desc <- str_replace_all(desc, "(responsibilities|requirements|qualifications|skills|experience|education|benefits|about us|job summary|what you'll do|what we offer)(:)", "\n\n\\1\\2")

  # Look for "we are" or "we need" or "looking for" patterns that might start new sections
  desc <- str_replace_all(desc, "(we are|we need|looking for|join us|about the role|in this role)( )", "\n\n\\1\\2")

  # Clean up excessive whitespace
  desc <- str_replace_all(desc, "\\n\\s+", "\n")
  desc <- str_replace_all(desc, "\\n{3,}", "\n\n")

  # If still no line breaks after processing, add some basic paragraph breaks every ~100 characters
  if (!grepl("\\n", desc) && nchar(desc) > 200) {
    # Find good break points (after periods, commas, etc.)
    words <- str_split(desc, " ")[[1]]
    result <- ""
    char_count <- 0
    for (word in words) {
      result <- paste0(result, word, " ")
      char_count <- char_count + nchar(word) + 1
      if (char_count > 80 && grepl("[.,;:]$", word)) {
        result <- paste0(result, "\n\n")
        char_count <- 0
      }
    }
    desc <- str_trim(result)
  }

  return(desc)
}

# Apply normalization to all descriptions
jobs$description <- sapply(jobs$description, normalize_description)

# Save the updated data
write_json(jobs, 'data/enhanced_jobs_step3.json', pretty = TRUE)

print("Description formatting normalized and saved.")
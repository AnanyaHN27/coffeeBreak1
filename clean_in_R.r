library(readr)
library(stringr)

mystring <- read_file("dead_poets_society.txt")
result <- str_extract_all(mystring, "<DIALOGUE>\\s*(.*?)\\s*</DIALOGUE>", simplify = TRUE)

cleaned_result <- gsub("<DIALOGUE>|</DIALOGUE>", "", result)
cleaned_result <- trimws(cleaned_result)

write(cleaned_result, file = "dead_poets_society_cleaned.txt", sep = "\n\n")
cat("Cleaned dialogue saved to dead_poets_society_cleaned.txt")

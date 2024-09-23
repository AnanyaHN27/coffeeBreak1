#Distribution of Tokens in each text

library(quanteda)
library(quanteda.textstats)
library(tidyverse)
library(gt)

source("/Users/yahanyang/Desktop/CMU_everything/36-468Text Analysis/helper_functions.R")
source("/Users/yahanyang/Desktop/CMU_everything/36-468Text Analysis/dispersion_functions.R")
load('/Users/yahanyang/Desktop/CMU_everything/36-468Text Analysis/multiword_expressions.rda')

# read, corpus, and tokenize
totc_beautiful <- readLines("/Users/yahanyang/coffeeBreak1/data/beautiful_mind.txt")
totc_immitation <- readLines("/Users/yahanyang/coffeeBreak1/data/imitation_game.txt")

totc_beautiful_corpus <- corpus(totc_beautiful)
totc_immitation_corpus <- corpus(totc_immitation)


doc_beautiful <- str_extract(totc_beautiful_corpus$doc_id, "^[a-z]+")
doc_immitation <- str_extract(totc_immitation_corpus$doc_id, "^[a-z]+")

docvars(totc_beautiful_corpus, field = "text_type") <- doc_beautiful
docvars(totc_immitation_corpus, field = "text_type") <- doc_immitation

beautiful_tokens <- tokens(totc_beautiful_corpus, include_docvars=TRUE, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE, what = "word")
beautiful_tokens <- tokens_tolower(beautiful_tokens)
immitation_tokens <- tokens(totc_immitation_corpus, include_docvars=TRUE, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE, what = "word")
immitation_tokens <- tokens_tolower(immitation_tokens)

beautiful_tokens <- tokens_compound(beautiful_tokens, pattern = phrase(multiword_expressions))

beautiful_dfm <- dfm(beautiful_tokens)


beautiful_word <- totc_beautiful_freq %>% 
  filter(rank == 1) %>% 
  dplyr::select(feature) %>%
  as.character()

prop1_dfm <- dfm_weight(beautiful_dfm, scheme = "prop")
beautiful_word_df <- dfm_select(prop1_dfm, beautiful_word, valuetype = "fixed") # select the token

beautiful_word_df <- beautiful_word_df %>% 
  convert(to = "data.frame") %>% 
  cbind(docvars(beautiful_word_df)) %>% 
  rename(RF = !!as.name(beautiful_word)) %>% 
  mutate(RF = RF*1000000)
 
summary_table_beautiful <- beautiful_word_df %>% 
  group_by(text_type) %>%
  summarize(MEAN = mean(RF),
              SD = sd(RF),
              N = n())

summary_table_beautiful |> 
  gt()


# Note "regex" rather than "fixed"

beautiful_word_df <- dfm_select(prop1_dfm, "^you$|^the$", valuetype = "regex")

# Now we'll convert our selection and normalize to 10000 words.
beautiful_word_df <- beautiful_word_df %>% 
  convert(to = "data.frame") %>%
  mutate(you = you*10000) %>%
  mutate(the = the*10000)

# Use "pivot_longer" to go from a wide format to a long one
beautiful_word_df <- beautiful_word_df %>% 
  pivot_longer(!doc_id, names_to = "token", values_to = "RF") %>% 
  mutate(token = factor(token))

bin_width <- function(x){
  2 * IQR(x) / length(x)^(1/3) * 0.3
  }

ggplot(beautiful_word_df,aes(x = RF, color = token, fill = token)) + 
  geom_histogram(binwidth = bin_width(beautiful_word_df$RF), alpha=.5, position = "identity") +
  theme_classic() +
  theme(axis.text = element_text(size=5)) +
  theme(legend.position = "none") +
  xlab("RF (per mil. words)") +
  facet_wrap(~ token)
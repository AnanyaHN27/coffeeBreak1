# Tokenization and frequency

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

# Frequency of the words in Beautiful Mind
totc_beautiful_freq <- totc_beautiful_corpus %>%
  tokens(what = "word", remove_punct = TRUE) %>%
  dfm() %>%
  textstat_frequency()
  gt(totc_beautiful_freq)

# Frequency of the words in Imitation Game
totc_immitation_freq <- totc_immitation_corpus %>%
  tokens(what = "word", remove_punct = TRUE) %>%
  dfm() %>%
  textstat_frequency()
  gt(totc_immitation_freq)


# Number of Tokens in each film text

comb_corpus <- data.frame(
  doc_id = c(paste0("totc_beautiful_", seq_along(totc_beautiful)),
             paste0("totc_immitation_", seq_along(totc_immitation))),
  text = c(totc_beautiful, totc_immitation)
) %>%
  mutate(text = preprocess_text(text)) %>%
  corpus()

text_type <- c(rep("Beautiful_Mind", length(totc_beautiful)),
               rep("Imitation_Game", length(totc_immitation)))

docvars(comb_corpus) <- data.frame(text_type = text_type)

docvars(comb_corpus)

comb_tkns <- comb_corpus %>%
  tokens(what = "fastestword")
  comb_dfm <- dfm(comb_tkns) %>% 
  dfm_group(groups = text_type)

corpus_comp <- ntoken(comb_dfm) %>%
  data.frame(frequency = .) %>%
  rownames_to_column("group") %>%
  group_by(group) %>%
  summarize(Texts = n(),
            Tokens = sum(frequency))

corpus_comp |> 
  gt() |>
  fmt_integer() |>
  cols_label(
    group = md("**Text Type**"),
    Texts = md("**Texts**"),
    Tokens = md("**Tokens**")
  ) |>
  grand_summary_rows(
    columns = c(Texts, Tokens),
    fns = list(
      Total ~ sum(.)
    ) ,
    fmt = ~ fmt_integer(.)
    )



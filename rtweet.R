
# Install and load the required packages
library(rtweet)
library(plyr)
library(dplyr)
library(openxlsx)
library(tidyr)
library(ggplot2)

# Please set working directory
setwd("")


# Insert the Credentials you received from Twitter after setting up your developer account
appname <- ""
key <- ""
secret <- ""
access_token <- ""
access_secret <- ""


# User the Credentials to create authorization token
twitter_token <- create_token(app = appname,
                              consumer_key = key,
                              consumer_secret = secret,
                              access_token = access_token,
                              access_secret = access_secret)


# Get timelines (the most recent 3200 tweets from BBC and CNN)
timeline <- get_timelines(c("cnn", "BBCWorld"), n = 3200 , check = T)

# Convert the timeline to data frame
timeline <- as.data.frame(timeline)

# Select the required columns
timeline <- timeline %>%
  select(status_id, created_at, user_id, name, screen_name,
         text, retweet_count, favorite_count, hashtags, media_url,
         media_type, retweet_text, source, is_retweet, lang, url,
         country, mentions_user_id, mentions_screen_name)


# Create date and time columns from created_at column
timeline <- timeline %>% mutate(date_time = created_at)
timeline$date <- as.Date(timeline$date_time)
timeline$time <- format(as.POSIXct(timeline$date_time) ,format = "%H:%M:%S") 
timeline$date_time <- NULL

# Filter the tweets for March 2021
german_trade_unions <- german_trade_unions %>% filter(date >= "2020-03-01" & date <= "2020-03-31")

# Extract the year from date
timeline$day <- format(timeline$date, "%d")

# Order variables
timeline <- timeline %>% select(status_id, created_at, date, time, everything())

# look for "Corona/Covid" in the tweet text
timeline$corona <- grepl("corona|covid", timeline$text)

# Count the occurrence of "Corona/Covid" by year for CNN and BBC
tbl_freq <- timeline %>% group_by(day, screen_name) %>%
  summarise(count = sum(corona == TRUE))

# plot the abs. frequency of "Corona/Covid"
ggplot(data=tbl_freq, aes(x=day, y=count, group=screen_name)) +
  geom_line(aes(linetype=screen_name, color=screen_name)) +
  geom_point(aes(color=screen_name)) +
  xlab("Month (03/2021)") +
  ylab("Abs. Frequency") +
  scale_color_manual(values = c("#ff0000", "#00ffff")) +
  scale_linetype_manual(values = c("dashed", "solid")) +
  theme_minimal()



# After plotting the abs. Frequency, let's plot the relative freq of corona occurrence 
# Count number of all tweets by year 
tbl_freq_total_tweets <- timeline %>% group_by(day, screen_name) %>%
  summarise(all_tweet = length(text))

# Add the total column to the table for relative frequency estimation
tbl_freq$total_tweet <- tbl_freq_total_tweets$all_tweet

# Estimate the proportion relative to all tweets per year
tbl_freq$rel_freq <- (tbl_freq$count / tbl_freq$total_tweet) * 100
tbl_rel_freq <- tbl_freq

# Plot the relative frequency of "Corona" occurrence
ggplot(data=tbl_rel_freq, aes(x=day, y=rel_freq, group=screen_name)) +
  geom_line(aes(linetype=screen_name, color=screen_name)) +
  geom_point(aes(color=screen_name)) +
  xlab("Month (03/2021)") +
  ylab("Rel. Frequency") +
  scale_color_manual(values = c("#ff0000", "#00ffff")) +
  scale_linetype_manual(values = c("dashed", "solid")) +
  theme_minimal()

# Write the data to excel workbook
write.xlsx(timeline, file = "timeline.xlsx",
           sheetName = "Sheet1", asTable = T)







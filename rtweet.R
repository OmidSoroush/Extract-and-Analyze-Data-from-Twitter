
# Install and load the required packages
library(rtweet)
library(plyr)
library(dplyr)
library(openxlsx)
library(tidyr)


# Insert the Credentials you received from Twitter after setting up developer account
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

# Order variables
timeline <- timeline %>% select(status_id, created_at, date, time, everything())


# Write the data in excel workbook
write.xlsx(timeline, file = "timeline.xlsx",
           sheetName = "Sheet1", asTable = T)







# Aim: create ical of all lectures and practicals of TDS

library(tidyverse)
devtools::install_github("ATFutures/calendar")

# Manual input ----
# get dates -----
# See https://ses.leeds.ac.uk/info/21630/timetabling/1004/teaching_week_patterns
# browseURL("https://ses.leeds.ac.uk/download/1557/1920_teaching_week_pattern")
w1_start = as.Date("2019-09-30")
week_num = c(1:11, paste0("C", 1:4), 12:22, paste0("E", 1:4), 23:30)
n_weeks = length(week_num)
week_commencing = seq(from = w1_start, by = "week", length.out = n_weeks)
weeks = tibble::data_frame(week_num, week_commencing)
# View(weeks)


# lectures ------------------------------------------------------

lecture1_description = c(
  "Introduction to transport data science",
  "The structure of transport data and data cleaning",
  "Routing",
  "Visualisation",
  "Professional issues and project work"
)

lecture_ids = c(
  "intro",
  "structure",
  "routing",
  "viz",
  "project"
)

lecture1_day_of_week = 2
lecture1_start_time = "13:00"
lecture1_end_time = "14:00"
lecture1 = tibble::tibble(week_num = as.character(c(14:16, 21:22)))
lecture1 = dplyr::inner_join(lecture1, weeks)
lecture1$date = lecture1$week_commencing + (lecture1_day_of_week - 1)
lecture1$DTSTART = lubridate::ymd_hm(paste(lecture1$date, lecture1_start_time)) 
lecture1$DTEND = lubridate::ymd_hm(paste(lecture1$date, lecture1_end_time))
lecture1$duration = (lecture1$DTEND - lecture1$DTSTART)
lecture1$SUMMARY = paste0("TDS Lecture ", 1:nrow(lecture1), ": ", lecture_ids)
lecture1$LOCATION = "Business School Maurice Keyworth SR (1.15)"
lecture1$DESCRIPTION = paste0(lecture1_description, " in ", lecture1$LOCATION)
nrow(lecture1)

# practical sessions ------------------------------------------------------

practical_ids = c(
  "structure",
  "cleaning",
  "accessing",
  "visualisation/ml",
  "project"
)
practical_descriptions = c(
  "The structure of transport data",
  "Data cleaning and and routing",
  "Accessing data from web sources",
  "Data visualization and machine learning",
  "Project work"
)

practical1_day_of_week = 3
practical1_start_time = "13:00"
practical1_end_time = "15:30"
practical1 = tibble::tibble(week_num = as.character(c(15:18, 23:24)))
practical1 = dplyr::inner_join(practical1, weeks)
practical1$date = practical1$week_commencing + (practical1_day_of_week - 1)
practical1$DTSTART = lubridate::ymd_hm(paste(practical1$date, practical1_start_time)) 
practical1$DTEND = lubridate::ymd_hm(paste(practical1$date, practical1_end_time))
practical1$duration = (practical1$DTEND - practical1$DTSTART)
practical1$SUMMARY = paste0("TDS Practical ", 1:nrow(practical1), ": ", practical_ids)
practical1$LOCATION = "West Teaching Lab Cluster (B.16)"
practical1$DESCRIPTION = paste0(practical_descriptions, " in ", practical1$LOCATION)
nrow(practical1) # there are 6 practicals

# seminars ------------------------------------------------------

seminar_ids = c(
  "mapping",
)
seminar_descriptions = c(
  "Mapping large datasets"
)

seminar1_day_of_week = 1
seminar1_start_time = "13:00"
seminar1_end_time = "16:00"
seminar1 = tibble::tibble(week_num = as.character(17))
seminar1 = dplyr::inner_join(seminar1, weeks)
seminar1$date = seminar1$week_commencing + (seminar1_day_of_week - 1)
seminar1$DTSTART = lubridate::ymd_hm(paste(seminar1$date, seminar1_start_time)) 
seminar1$DTEND = lubridate::ymd_hm(paste(seminar1$date, seminar1_end_time))
seminar1$duration = (seminar1$DTEND - seminar1$DTSTART)
seminar1$SUMMARY = paste0("TDS seminar ", 1:nrow(seminar1))
seminar1$LOCATION = "Institute for Transport Studies - 1.11"
seminar1$DESCRIPTION = paste0(seminar_descriptions, " in ", seminar1$LOCATION, 
                              ". See https://environment.leeds.ac.uk/transport/events/event/5963/mapping-human-population-a-data-science-approach"
                              )
nrow(seminar1) # there is 1 seminar

# deadlines ------------------------------------------------------

deadline_ids = c(
  "portfolio draft",
  "portfolio deadline"
)
deadline_descriptions = c(
  "Draft portfolio",
  "Deadline: coursework, 2pm"
)

# Deadline is 15th May: https://minerva.leeds.ac.uk/webapps/blackboard/content/listContentEditable.jsp?content_id=_6292071_1&course_id=_504933_1&mode=reset

deadline1_day_of_week = c(1, 5)
deadline1_start_time = "11:00"
deadline1_end_time = "11:30"
deadline1 = tibble::tibble(week_num = as.character(c(22, 25)))
deadline1 = dplyr::inner_join(deadline1, weeks)
deadline1$date = deadline1$week_commencing + (deadline1_day_of_week - 1)
deadline1$DTSTART = lubridate::ymd_hm(paste(deadline1$date, deadline1_start_time)) 
deadline1$DTEND = lubridate::ymd_hm(paste(deadline1$date, deadline1_end_time))
deadline1$duration = (deadline1$DTEND - deadline1$DTSTART)
deadline1$SUMMARY = paste0("TDS deadline ", 1:nrow(deadline1))
deadline1$LOCATION = "Institute for Transport Studies - 1.11"
deadline1$DESCRIPTION = deadline_descriptions

timetable = bind_rows(lecture1, practical1, seminar1, deadline1) 
timetable$UID = purrr::map_chr(1:nrow(timetable), ~ calendar::ic_guid())
timetable = timetable %>% 
  arrange(DTSTART) 

sum(timetable$duration) # 20 hours of contact time
ic = calendar::ical(timetable) 
calendar::ic_write(ic[1], "/tmp/test-tds.ics") # note: generates faulty calendar: bug in ic_read?



# file.edit("/tmp/test-tds.ics")
tt_min = dplyr::select(timetable, SUMMARY, DESCRIPTION, DTSTART, DTEND, LOCATION, UID)
# ic = calendar::ical(tt_min[1:2, ])
ic = calendar::ical(tt_min)
ic[1, ]
ical(ical_example)
ic

calendar::ic_write(ic, "tds-timetable.ics") # note: generates faulty calendar with ic[1, ]: bug in ic_read?
readLines("/tmp/test-tds.ics")
readr::write_csv(tt_min, "timetable.csv")

# from old script ---------------------------------------------------------

# day_of_week = 2 
# session_ids = c(
#   "intro",
#   "software",
#   "structure",
#   "cleaning",
#   "accessing",
#   "processing",
#   "viz",
#   "project",
#   "ml",
#   "prof"
#   )
# session_descriptions = c(
#   "Introduction to transport data science",
#   "Software for practical data science",
#   "The structure of transport data",
#   "Data cleaning and subsetting",
#   "Accessing data from web sources",
#   "Routing",
#   "Data visualization",
#   "Project work",
#   "Machine learning",
#   "Professional issues"
# )
# 
# library(rvest)
# # vignette("selectorgadget") # check how it works...
# u = "http://timetable.leeds.ac.uk/teaching/201920/reporting/Individual?objectclass=module&idtype=name&identifier=TRAN5340M01&template=SWSCUST+module+individual&days=1-7&periods=1-21&weeks=1-52"
# html = read_html(u)
# 
# tt_html = html_nodes(html, ".spreadsheet") %>% html_text()
# extract_column = function(x, n) {
#   nodes = html_nodes(x, paste0(".spreadsheet td:nth-child(", n, ")"))
#   html_text(nodes)[-1]
# }
# extract_column_name = function(x, n) {
#   nodes = html_nodes(x, paste0(".spreadsheet td:nth-child(", n, ")"))
#   html_text(nodes)[1]
# }
# 
# cols = c(1:3, 7:11)
# colum_names = purrr::map_chr(cols, ~ extract_column_name(html, .x))
# tt_list = purrr::map(cols, ~ extract_column(html, .x))
# names(tt_list) = colum_names
# tt_df = tibble::as_tibble(tt_list)
# tt_df$Weekday = day_of_week
# 
# x = tt_df$Weeks[1]
# extract_weeks = function(x) {
#   r_expression = paste0(
#     "c(",
#     gsub(pattern = "-", replacement = ":", x = x),
#     ")"
#     )
#   eval(parse(text = r_expression))
# }
# 
# extract_week_commencing = function(x) {
#   weeks_n = tibble::data_frame(week_num = as.character(extract_weeks(x)))
#   dplyr::inner_join(weeks_n, weeks)
# }
# extract_week_commencing(x)
# extract_attributes = function(tt_df) {
#   tt_i = extract_week_commencing(tt_df$Weeks[1])
#   tt_i$code = tt_df$`Module code (or codes if jointly taught)`[1] 
#   
#   tt_i$type = tt_df$`Type of activity`
#   tt_i$type = gsub(pattern = " 1| Based Learning 1", replacement = "", tt_i$type)
#   tt_i$type = gsub(pattern = "Computer", replacement = "Practical", tt_i$type)
#   
#   tt_i$LOCATION = tt_df$Location[1] 
#   tt_i$day_of_week = tt_df$Weekday[1] 
#   tt_i$DTSTART = lubridate::ymd_hm(paste(tt_i$week_commencing + day_of_week - 1, tt_df$Start[1])) 
#   tt_i$DTEND = lubridate::ymd_hm(paste(tt_i$week_commencing + day_of_week - 1, tt_df$End[1]))
#   tt_i$size = tt_df$Size[1]
#   tt_i$staff = tt_df$`Teaching staff`[1]
#   tt_i
# }
# 
# # iterate over each type of event 
# i = 1
# for(i in seq(nrow(tt_df))) {
#   tti = extract_attributes(tt_df[i, ])
#   if(i == 1) {
#     tt = tti
#   } else (
#     tt = rbind(tt, tti)
#   )
# }
# 
# tt$SUMMARY = paste0(
#   "TDS ",
#   tt$type,
#   ": ",
#   rep(session_ids, 2)
#   )
# tt$id = paste(rep(session_ids, 2), tt$type)
# tt$DESCRIPTION = paste0(rep(session_descriptions), ", ", gsub(pattern = " 1| Based Learning 1", replacement = "", tt$type))
# tt$staff = "Dr Robin Lovelace"
# tt$staff[grepl(pattern = "The structure of transport data, L|Project w", x = tt$DESCRIPTION)] = "Dr Richard Connors"
# tt$staff[grepl(pattern = "Routing", x = tt$DESCRIPTION)] = "Dr Malcolm Morgan"
# tt$DESCRIPTION = paste0(tt$DESCRIPTION, ", taught by: ", tt$staff)
# 
# tt = dplyr::arrange(tt, DTSTART)
# tt_min = dplyr::select(tt, SUMMARY, DESCRIPTION, DTSTART, DTEND, LOCATION, UID = id)
# tt_min
# submission_deadline = tt_min[1, ]
# submission_deadline$SUMMARY = "Deadline: report submission"
# submission_deadline$DESCRIPTION = "Hand-in deadline of portfolio of work"
# submission_deadline$DTSTART = lubridate::ymd_hm("2019-05-07 09:00")
# submission_deadline$DTEND = lubridate::ymd_hm("2019-05-07 17:00")
# submission_deadline$LOCATION = "ITS reception (40 University Road) and online"
# submission_deadline$UID = "submission"
# tt_min = rbind(tt_min, submission_deadline)
# ic = calendar::ical(tt_min)
# calendar::ic_write(ic, "tds-timetable.ics")
# readr::write_csv(ic, "timetable.csv")
# ic
# readLines("tds-timetable.ics")
# Test code ----
# html_node(tt_html)
# mod_code = html_nodes(html, ".spreadsheet td:nth-child(1)") %>% html_text()
# type = html_nodes(html, ".spreadsheet td:nth-child(2)") %>% html_text()
# location = html_nodes(html, ".spreadsheet td:nth-child(3)") %>% html_text()
# mod_code = html_nodes(html, ".spreadsheet td:nth-child(7)") %>% html_text()
# mod_code = html_nodes(html, ".spreadsheet td:nth-child(8)") %>% html_text()
# mod_code = html_nodes(html, ".spreadsheet td:nth-child(9)") %>% html_text()
# mod_code = html_nodes(html, ".spreadsheet td:nth-child(10)") %>% html_text()
# 
# weeks = html_nodes(html, "td:nth-child(9)") %>% 
#   html_table()

# # install required package:
# # First thought was to capture the data hosted at:
# # http://timetable.leeds.ac.uk/teaching/201819/reporting/individual;?objectclass=module&idtype=name&identifier=TRAN5340M01&&template=SWSCUST+module+Individual&days=1-7&weeks=1-52&periods=1-21
# # However, eventually I opted for a simpler approach: to create a .csv from a spreadsheet
# # This can be read-in as follows:
# timetable = readr::read_csv("timetable.csv")
# timetable$date = timetable$week_commencing + 1
# 
# # identify and create ical columns (on just one event):
# ical::properties_core
# names(timetable)
# 
# # start times for practicals
# start_time = "12:30"
# start_dt = paste0(timetable$date, start_time)
# DTSTART = lubridate::ymd_hm(start_dt)
# 
# # end times for practicals
# end_time = "13:30"
# end_dt = paste0(timetable$date, end_time)
# DTEND = lubridate::ymd_hm(end_dt)
# 
# SUMMARY = paste("TDS:", timetable$name, "lecture")
# DESCRIPTION = paste0(timetable$description, ". Taught by ", timetable$Person, ". Week number ", timetable$week_num)
# UID = sapply(1:nrow(timetable), function(x) ical::ic_guid())
# 
# ic = data.frame(UID, DTSTART, DTEND, SUMMARY, DESCRIPTION)
# 
# # should be able to write it directly:
# # ical::ic_write(ic[1, ], "timetable.ics")
# 
# # temp fix (to comment-out when ical is updated):
# ic_char = ical::ic_character(ic)
# ic_cal_begin = c("BEGIN:VCALENDAR", "PRODID:ical R package", "VERSION:2.0", 
#                  "CALSCALE:GREGORIAN", "METHOD:PUBLISH")
# ic_char = c(ic_cal_begin, ic_char)
# writeLines(ic_char, "timetable-lectures.ics")
# 
# # issues: does not have these prefixes (added manually): 
# # "BEGIN:VCALENDAR" 
# # "PRODID:-//Google Inc//Google Calendar 70.9054//EN"
# # "PRODID:ical R package"
# # "VERSION:2.0"
# # "CALSCALE:GREGORIAN"
# # "METHOD:PUBLISH"    - should comment-out:
# ic_cal_begin = c("BEGIN:VCALENDAR", "PRODID:ical R package", "VERSION:2.0", 
#                  "CALSCALE:GREGORIAN", "METHOD:PUBLISH")
# 
# # Aim: import calendar from web
# # library(rvest) # for webscraping
# # u = "http://timetable.leeds.ac.uk/teaching/201819/reporting/textspreadsheet;?objectclass=module&idtype=name&identifier=TRAN5340M01&&template=SWSCUST+module+Individual&days=1-7&weeks=1-52&periods=1-21"
# # other version
# # u = "http://timetable.leeds.ac.uk/teaching/201819/reporting/individual;?objectclass=module&idtype=name&identifier=TRAN5340M01&&template=SWSCUST+module+Individual&days=1-7&weeks=1-52&periods=1-21"
# # w14_start = as.Date("2019-01-28")
# # week_num = c(14:22, paste0("E", 1:4), 23:30)
# # n_weeks = length(w14_30)
# # week_commencing = seq(from = w14_start, by = "week", length.out = n_weeks)
# # weeks = data.frame(week_num, week_commencing)
# # weeks_teaching = c(15:17, 19:22, 23:25)
# # weeks = weeks[weeks$week_num %in% weeks_teaching, ]
# # readr::write_csv(weeks, "data/timetable-dates.csv")
# # edit manually
# 
# # scraping contents:
# # timetable_scraped = xml2::read_html(u) %>% 
# #   html_nodes("td:nth-child(9)") %>% 
# #   html_text()
# # html_table(header = TRUE, trim = TRUE, fill = TRUE)




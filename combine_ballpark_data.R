library(tidyverse)
gameinfo<-read_csv("gameinfo.csv") %>%
  reframe(gid, visteam, hometeam, site, starttime, attendance, 
          fieldcond, precip, sky, temp, winddir, windspeed,
          gametype, vruns, hruns, season)
capacity_data <- read_csv("capacity_data.csv") %>%
  reframe(capacity=Capacity, site=team_id) %>%
  filter(!duplicated(site))
test <- merge(gameinfo, capacity_data, 
              by="site", all.x=T) %>%
  reframe(site, gid, date=as.Date(substr(gid, 4, 12), format = "%Y%m%d"),
          visteam, hometeam, starttime, attendance, capacity,
          vruns, hruns, temp, fieldcond, precip, sky, winddir)
post_modern <- test %>%
  filter(date>as.Date("01/01/1995", format="%m/%d/%Y"))

ggplot(data=post_modern %>%
         filter(hometeam=="NYA"), aes(x=date, y=attendance/capacity)) +
  geom_point()
ggggg <- post_modern %>%
  filter(hometeam=="NYN")

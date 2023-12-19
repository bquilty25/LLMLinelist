# Function to generate timeline plot
generate_timeline_plot <- function(df) {
  #browser()
  df %>%
    pivot_longer(contains("date"),names_to="dates") %>%
    mutate(value=as.Date(value,format = "%d %B %Y"),
           dates = str_replace_all(dates, "_", " ")) %>%
    drop_na(value) %>%
    ggplot( aes(x = value, y = Name)) +
    geom_point(aes(colour=dates),size=2)+
    scale_x_date(breaks = "2 days",date_labels = "%d %b %y")+
    labs(x = "Date", y = "Name") +
    theme_minimal()+
    theme(legend.position = "bottom",legend.box = "vertical")+
    scale_color_brewer(name = "Events", palette = "Set2")+
    ggpubr::rotate_x_text(angle = 45)
}

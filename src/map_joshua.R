rm(list=ls())
library(plotly)
library(dplyr)
df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv')

# Compute the mean of life expectancy

data<- read.csv('/Users/joshualim/Desktop/mds/block4/lab/DSCI_532/dsci_532_group_04_R/data/processed/life_expectancy_data_processed.csv')
data_mean<- data %>% group_by(country) %>% summarize(avg= mean(life_expectancy,na.rm=TRUE))

country_tobe_replaced <- c("Bahamas", "Bolivia, Plurinational State of", "Brunei Darussalam", "Congo", "Côte d'Ivoire", "Czechia", "Democratic People's Republic of Korea", 
       "Democratic Republic of the Congo, Republic of the", "Gambia", "Iran, Islamic Republic of", "Korea, Republic of", "Lao People's Democratic Republic", "Myanmar",
       "North Macedonia", "Republic of Moldova", "Russian Federation", "Syrian Arab Republic", "United Kingdom of Great Britain and Northern Ireland",
       "United Republic of Tanzania", "United States of America", "Venezuela, Bolivarian Republic of", "Viet Nam" )
country_replaced <- c("Bahamas, The", "Bolivia", "Brunei", "Congo, Republic of the", "Cote d'Ivoire", "Czech Republic", "Korea, North", 
       "Congo, Democratic Republic of the", "Gambia, The", "Iran", "Korea, South", "Laos", "Burma", 
       "Macedonia", "Moldova", "Russia" , "Syria", "United Kingdom",
       "Tanzania", "United States", "Venezuela", "Vietnam")

for (i in 1:length(country_tobe_replaced)){
  data_mean$country= gsub(country_tobe_replaced[i], country_replaced[i], data_mean$country)
  data$country= gsub(country_tobe_replaced[i], country_replaced[i], data$country)
}

data_mean <- merge(x = data_mean, y = df[,c("COUNTRY","CODE")], by.x = "country", by.y= "COUNTRY" , all.x = TRUE )

# to check
#data_mean %>%  filter(is.na(CODE))

# Left join country with code
data <- merge(x = data, y = data_mean, by = "country", all.x = TRUE)

# light grey boundaries
l <- list(color = toRGB("grey"), width = 0.5)

# specify map projection/options
g <- list(
  showframe = FALSE,
  showcoastlines = FALSE,
  projection = list(type = 'Mercator')
)

fig <- plot_geo(data)

fig <- fig %>% add_trace(
  z = ~avg, color = ~avg, colors = 'Blues',
  text = ~country, locations = ~CODE, marker = list(line = l)
)

fig <- fig %>% colorbar(title = 'Average Life Expectancy')
fig <- fig %>% layout(
  title = 'Average Life Expectancy by Country',
  geo = g
)
fig

library(plotly)

library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)

app <- Dash$new()
app$layout(
  htmlDiv(
    list(
      dccGraph(figure=fig) 
    )
  )
)

app$run_server(debug=F)


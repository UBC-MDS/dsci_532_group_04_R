library(dash)
library(dashHtmlComponents)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(plotly)


dataset <- read_csv("data/processed/life_expectancy_data_processed.csv")


app = Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

card <- dbcCard(
  children = list(
    dbcCardBody(
      children = list(
        htmlH2("Life", className="display-6"),
        htmlH2("Expectancy", className="display-6"),
        htmlH2("Indicator", className="display-6"),
        htmlHr(),
        dbcLabel("Year Range"),
        dccRangeSlider(
          id = 'widget_g_year',
          min = 2000,
          max = 2015,
          step = 1,
          value = list(2000, 2015),
          marks = setNames(lapply(list(2000, 2005, 2010, 2015), 
                                  function(x) paste(x)), 
                           as.character(list(2000, 2005, 2010, 2015)))
        ) 
        )
)),style=list("width" = "18rem", 'background-color'='#f8f9fa'))

widget_style <- list('verticalAlign' = "bottom",'font-weight' = 'bold','font-size' = '14px')

dropdown_style <- list('verticalAlign' = "middle",
                       'shape' = 'circle',
                       'border-radius' = '36px', 
                       'background-color'='#E8E8E8',
                       'display'='inline-block', 
                       'width'="100%")

continent_widget <- htmlP('Select Continents:', className="card-text", style=widget_style)

continent_dropdown <- dccDropdown(
  id = 'widget_l_continent',
  options = purrr::map(unique(dataset$continent), function(c) list(label = c, value = c)),
  clearable = TRUE,
  searchable = TRUE,
  style = dropdown_style,
  multi = TRUE
)

status_widget <- htmlP('Select Color Axis:', className="card-text", style=widget_style)

status_dropdown <- dccRadioItems(
  id='widget_l_color_axis',
  options = list(list(label = "Continent", value = "continent"),
                 list(label = "Status", value = "status")
  ),
  value = 'continent',
  labelStyle = list('margin-left'="1em")
)

trend_card <- dbcCard(
  children = list(
    dbcCardHeader("Year-wise Trend", className="cursive",style=list('font-weight'='900')),
    dbcCardBody(
      children = list(
        dbcRow(children = list(dbcCol(continent_widget), dbcCol(continent_dropdown))),
        htmlBr(),
        dbcRow(children = list(dbcCol(status_widget), dbcCol(status_dropdown))),
        dccGraph(id="widget_o_year_wise_trend", style=list('border-width'= '0', 'width' = 500, 'height' = 500))
      )
    )
  ), style = list("width"=550, "height"=680)
)

country_widget <- htmlP('Select a Country:', className="card-text", style=widget_style)

country_dropdown <- dccDropdown(
  id='widget_l_country',
  value='Canada',
  options = purrr::map(unique(dataset$country), function(c) list(label = c, value = c)),
  clearable = FALSE,
  searchable = FALSE,
  style = dropdown_style
)

comparison_card <- dbcCard(
  children = list(
    dbcCardHeader("Country vs Continent vs Worldwide", className="cursive",style=list('font-weight'='900')),
    dbcCardBody(
      children = list(
        dbcRow(list(dbcCol(country_widget), dbcCol(country_dropdown))),
        htmlBr(),
        htmlBr(),
        dccGraph(id="widget_country_comparison", style=list('border-width'= '0', 'width' = 500, 'height' = 500))
      )
    )
  ), style = list("width"=550, "height"=680)
)

axis_widget <- htmlP('Select X-Axis:', className="card-text", style=widget_style)

axis_dropdown <- dccDropdown(
  id = "widget_l_multi_dim_x_axis",
  options = list(
    list(label = "Adult Mortality", value = "adult_mortality"),
    list(label = "Infant Deaths", value = "infant_deaths"),
    list(label = "Alcohol Consumption", value = "alcohol"),
    list(label = "Expenditure (%)", value = "percentage_expenditure"),
    list(label = "Hepatitis B", value = "hepatitis_B"),
    list(label = "Measles", value = "measles"),
    list(label = "BMI", value = "BMI"),
    list(label = "Deaths (below 5 yrs)", value = "under_five_deaths"),
    list(label = "Polio", value = "polio"),
    list(label = "Total Expenditure", value = "total_expenditure"),
    list(label = "Diphtheria", value = "diphtheria"),
    list(label = "HIV/Aids", value = "hiv_aids"),
    list(label = "GDP", value = "gdp"),
    list(label = "Population", value = "population"),
    list(label = "Schooling", value = "schooling")),
  value = "adult_mortality",
  clearable = FALSE,
  style = dropdown_style
)

color_widget <- htmlP('Select Color Axis:', className="card-text", style=widget_style)

color_dropdown <- dccDropdown(
  id = "widget_l_multi_dim_color_axis",
  options = list(list(label = "Continent", value = "continent"),
                 list(label = "Status", value = "status")),
  value = 'continent',
  clearable = FALSE,
  style = dropdown_style
)

effect_card <- dbcCard(
  children = list(
    dbcCardHeader("Influence of Other Factors", className="cursive",style=list('font-weight'='900')),
    dbcCardBody(
      children = list(
        dbcRow(list(dbcCol(axis_widget), dbcCol(axis_dropdown), dbcCol(color_widget), dbcCol(color_dropdown))),
        htmlBr(),
        dccGraph(id="widget_o_multi_dim_analysis", style=list('border-width'= '0', 'width' = 1000, 'height' = 500))
      )
    )
  )
)


app$layout(dbcContainer(
  children = list(
    dbcRow(list(card)),
    htmlBr(),
    dbcCardDeck(list(trend_card, comparison_card)),
    htmlBr(),
    dbcCardDeck(effect_card)
  )
))

app$callback(
  output("widget_o_year_wise_trend", "figure"),
  list(
    input("widget_g_year", "value"),
    input("widget_l_continent", "value"),
    input("widget_l_color_axis", "value")
  ),
  function(year_range,  in_continent, color_axis) {
    chosen_starting_year = year_range[1]
    chosen_ending_year = year_range[2]
    #color_axis <- enquo(color_axis)
    
    
    if (is_empty(in_continent) || is_null(in_continent[[1]])) {
      in_continent <- unique(dataset$continent)
    }
    
    plot_trend <- dataset %>%
      filter(year>={{chosen_starting_year}}, year<={{chosen_ending_year}}) %>%
      filter(continent %in% in_continent) %>%
      ggplot(aes(x=year, y=life_expectancy, color=!!sym(color_axis))) +
      geom_line(stat = "summary", fun=mean) +
      labs(x="Year", y="Life Expectancy (Mean)", color="") +
      theme(legend.position="bottom") +
      theme_bw() +
      ggthemes::scale_color_tableau() 
    
    
    ggplotly(plot_trend) %>% layout(legend = list(orientation = "h", x = 0.05, y = -0.2))
  }
)

app$callback(
  output("widget_country_comparison", "figure"),
  list(
    input("widget_g_year", "value"),
    input("widget_l_country", "value")
  ),
  function(year_range,  chosen_country) {
    chosen_starting_year = year_range[1]
    chosen_ending_year = year_range[2]
    sel_continent  <- dataset %>%
      filter(country == chosen_country) %>%
      select(continent) %>%
      unique() %>%
      pull()
    
    temp_df <- dataset %>%
      filter(year>={{chosen_starting_year}}, year<={{chosen_ending_year}}) %>%
      filter(country == chosen_country) %>%
      group_by(year) %>%
      summarise(mean_life_exp = mean(life_expectancy)) %>%
      ungroup() %>%
      mutate(label = chosen_country)
    
    temp_df <- dataset %>%
      filter(year>={{chosen_starting_year}}, year<={{chosen_ending_year}}) %>%
      filter(continent == sel_continent) %>%
      group_by(year) %>%
      summarise(mean_life_exp = mean(life_expectancy)) %>%
      ungroup() %>%
      mutate(label = sel_continent) %>%
      bind_rows(temp_df)
    
    temp_df <- dataset %>%
      filter(year>={{chosen_starting_year}}, year<={{chosen_ending_year}}) %>%
      group_by(year) %>%
      summarise(mean_life_exp = mean(life_expectancy)) %>%
      ungroup() %>%
      mutate(label = "Worldwide") %>%
      bind_rows(temp_df)
    
    plot_trend <- temp_df %>%
      ggplot(aes(x=year, y=mean_life_exp, color=label)) +
      geom_line(stat = "summary", fun=mean) +
      labs(x="Year", y="Life Expectancy (Mean)", color="") +
      theme_bw() +
      ggthemes::scale_color_tableau() +
      theme(legend.position="bottom")
    
    
    ggplotly(plot_trend) %>% layout(legend = list(orientation = "h", x = 0.05, y = -0.2))
  }
)

app$callback(
  output("widget_o_multi_dim_analysis", "figure"),
  list(
    input("widget_g_year", "value"),
    input("widget_l_multi_dim_x_axis", "value"),
    input("widget_l_multi_dim_color_axis", "value")
  ),
  function(year_range,  x_axis, color_axis) {
    
    labels = list(
      adult_mortality = "Adult Mortality",
      infant_deaths = "Infant Deaths",
      alcohol = "Alcohol Consumption",
      percentage_expenditure = "Expenditure (%)",
      hepatitis_B = "Hepatitis B",
      measles = "Measles",
      BMI = "BMI",
      under_five_deaths = "Deaths (below 5 yrs)",
      polio = "Polio",
      total_expenditure = "Total Expenditure",
      diphtheria = "Diphtheria",
      hiv_aids = "HIV/Aids",
      gdp = "GDP",
      population = "Population",
      schooling = "Schooling"
    )
    
    #print(x_axis)
    #print(labels[[x_axis]])
    
    chosen_ending_year = year_range[2]
    
    
    plot_multi_dim <- dataset %>%
      filter(year == chosen_ending_year) %>%
      ggplot(aes(x=!!sym(x_axis), y=life_expectancy, color=!!sym(color_axis))) +
      geom_point(size=3) +
      labs(x=labels[[x_axis]], y="Life Expectancy", color="") +
      theme_bw() +
      ggthemes::scale_color_tableau() +
      theme(legend.position="bottom")
    
    ggplotly(plot_multi_dim) %>% layout(legend = list(orientation = "h", x = 0.05, y = -0.2))
  }
)

app$run_server(debug = T)

library(dash)
library(dashHtmlComponents)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(dashCoreComponents)
#library(devtools)
#install_github('facultyai/dash-bootstrap-components@r-release')
library(dashBootstrapComponents)
library(plotly)

dataset <- read_csv("data/processed/life_expectancy_data_processed.csv")

# unique(dataset$continent)


  

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

app$layout(
  dbcContainer(
    list(
      dbcRow(
        list(
          dbcCol(
            htmlH5("Select year"),
            style = list('max-width' = '10%')
          ),
          dbcCol(
            dccRangeSlider(
              id = "widget_g_year",
              min = 2000,
              max = 2015,
              marks = list(
                "2000" = "2000",
                "2005" = "2005",
                "2010" = "2010",
                "2015" = "2015"
              ),
              value = list(2000, 2015)
            )
          )          
        )
      ),
      dbcRow(
        list(
          dbcCol(
            list(
              htmlH5("Select Continent(s)"),
              dccDropdown(
                id = "widget_l_continent",
                options = purrr::map(unique(dataset$continent), function(c) list(label = c, value = c)),
                multi = TRUE
              )              
            )
          ),
          dbcCol(
            list(
              htmlHeader("Select Color Axis"),
              dccRadioItems(
                id = "widget_l_color_axis",
                options = list(list(label = "Continent", value = "continent"),
                               list(label = "Status", value = "status")
                ),
                value = 'continent'        
              )              
            )
            
          )
        )
      ),
      dbcRow(
        dbcCol(
          dccGraph(id='widget_o_year_wise_trend')
        )
      ),

      dbcRow(
        list(
          dbcCol(
            dccDropdown(
              id = "widget_l_country",
              options = purrr::map(unique(dataset$country), function(c) list(label = c, value = c)),
              value = "Canada"
            ), style = list('max-width' = '50%')
          )
        )
      ),
      
      # dbcRow(
      #   htmlDiv(id = "widget_temp")
      # ),
      
      dbcRow(
        dbcCol(
          dccGraph(id='widget_country_comparison')
        )
      )
      

      
    ), style = list('max-width' = '85%')
  )
)


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
      theme_bw() +
      ggthemes::scale_color_tableau()
    
    
    ggplotly(plot_trend)
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
      ggthemes::scale_color_tableau()
    
    
    ggplotly(plot_trend)
  }
)

app$run_server(debug = T)

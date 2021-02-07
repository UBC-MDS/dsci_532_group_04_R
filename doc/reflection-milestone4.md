# Reflection

## Why R version was selected:

- We found dash core components are easier to control on R version compared to the python version.
- The R-version of our dashboard had more changes and up to date layout based on feedback received as it was built during milestone 3. Hence, it would have been slightly more time consuming to replicate them in the python version from milestone 2.

## Implemented/ Changes made based on feedback:

- Added DocString for all the functions.
- Added dashboard information at the bottom of the dashboard.
- Layout of the dashboard was modified to make the grids more symmetric.
- Improved the look and feel of the dashboard.
- Scatterplot
  - Added appropriate units for x-axis of the scatter-plot.
  - The scatter-plot uses the entire date range and averages the x and y axis feature values.
  - Removed the disclaimers as they were not relevant anymore.
  - The tooltip text shows country and average life expectancy.
  
- Interactive map
  - Resized to remove whitespaces.
  - Plot and legend title were removed as they were redundant.
  - The disclaimer on the map plot was removed as it was not relevant.
  - Fixed the scale of the color axis for fair comparison when different year range was selected.


## Known issues:

- Layout looks different for some machines with different resolution.
- The multi-select drop down for continent in trend graph does not display all the values selected. The users have to refer to the legends to see what values are selected.

## Areas of Improvement:

- Performance enhancement using the tips from Lecture 8

## Features not implemented

- We did not include the toggle button to collapse the global filter widget. This is because our final dashboard version does not have a global filter widget which takes up the entire left side of the dashboards. Instead, the global filter section takes up the top left position of the dashboard grid.

## Summary

- Based on feedback we received so far, we feel that it is easy to use our dashboard.
- Most of the feedback received were very helpful and made our app much more enhanced than we have planned.
- We have received multiple feedback for the scatter-plot and graph, however they were on top of the enhancements we were doing and helped making them more polished than the initial version

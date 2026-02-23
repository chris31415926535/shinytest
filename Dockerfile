# Base R Shiny image
FROM rocker/shiny

# Install R dependencies
#RUN R -e "install.packages(c('dplyr', 'DBI', 'RSQLite','DT', 'readr', 'dbplyr'))"
RUN R -e "install.packages(c('DT', 'dplyr', 'readr'))"

RUN R -e "install.packages(c('shinymanager', 'ggplot2'))"
RUN R -e "install.packages(c('plotly'))"
# Copy the Shiny app code
# COPY data data
COPY app.R app.R
#COPY . .

# Expose the application port
EXPOSE 8080

# Run the R Shiny app
CMD ["Rscript", "app.R"]

FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages (added 'dotenv' and 'digest')
RUN R -e "install.packages(c('shiny', 'shinyjs', 'DBI', 'RPostgres', 'pool', 'dotenv', 'digest'), repos='https://cloud.r-project.org/')"

# Copy app files
WORKDIR /srv/shiny-server
COPY . .

# Expose port
EXPOSE 3838

# Run app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host='0.0.0.0', port=3838)"]
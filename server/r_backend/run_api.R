# helper script to start the plumber api
# run with: Rscript server/r_backend/run_api.R
library(plumber)

# Set working directory to the r_backend directory
setwd('server/r_backend')

api_path <- 'api.R'
pr <- plumber::plumb(api_path)
port <- as.integer(Sys.getenv('R_API_PORT', '8000'))
cat('Starting R plumber API on port', port, '\n')
pr$run(host='0.0.0.0', port=port)

# PDF Skill Extractor & Job Recommender

[![License](https://img.shields.io/github/license/mukund58/Job-Recommender)](LICENSE)
[![Top Language](https://img.shields.io/github/languages/top/mukund58/Job-Recommender)](https://github.com/mukund58/Job-Recommender)
[![Repository Size](https://img.shields.io/github/repo-size/mukund58/Job-Recommender)](https://github.com/mukund58/Job-Recommender)
[![Last Commit](https://img.shields.io/github/last-commit/mukund58/Job-Recommender)](https://github.com/mukund58/Job-Recommender/commits)

## Overview
PDF Skill Extractor & Job Recommender is a web application that extracts text and technical skills from uploaded PDF resumes and returns personalized job recommendations using natural language processing and machine learning techniques. The app displays job recommendations with match scores, matched skills, and posting dates.

## Architecture

1. **Resume Upload (Frontend - React)**

   * Users upload their resume in PDF format through the React interface.
   * **`pdf.js`** is used to extract text content from the uploaded PDF.

2. **Skill Extraction**

   * The extracted text is matched against a predefined skills database to identify relevant technical skills.

3. **API Request to Backend**

   * The React frontend sends a **POST** request to the **R Plumber API** endpoint `/recommend`, containing the extracted skills as JSON data.

4. **Job Matching Logic (Backend - R Plumber API)**

   * The backend processes the skills and matches them against a job dataset.
   * Calculates match scores based on skill relevance.
   * Computes posted dates by parsing relative time strings and adjusting with scrape timestamps.

5. **Response Generation**

   * The backend returns a structured JSON response with recommended jobs, scores, matched skills, and calculated posted dates.

6. **Display Recommendations (Frontend)**

   * The frontend displays job recommendations with expandable descriptions, match scores, matched skills, and "time ago" posted dates.

## Key Features
- Client-side PDF text extraction using pdf.js
- Automatic detection of technical skills from resume content using a comprehensive skills database
- Job recommendation engine that ranks results by skill match scores
- Responsive user interface built with React and Tailwind CSS
- R-based backend (Plumber) for data processing and recommendation logic
- Detailed match results including scores, matched skills, job metadata, and posting dates
- Intelligent text formatting for job descriptions with expand/collapse functionality

## Technology Stack
### Frontend
- React 19.1.1
- Vite
- Tailwind CSS
- pdf.js

### Backend
- R with Plumber
- dplyr, purrr, tibble, stringr, lubridate, jsonlite

## Prerequisites
- Node.js v18 or later (includes npm)
- R v4.0 or later
- Required R packages: plumber, jsonlite, dplyr, purrr, tibble, stringr, lubridate

### Installing Dependencies
#### On Ubuntu/Debian (apt):
```bash
sudo apt update
sudo apt install nodejs npm r-base
```

#### On Arch Linux (pacman):
```bash
sudo pacman -Syu
sudo pacman -S nodejs npm r
```

#### On macOS (Homebrew):
```bash
brew install node r
```

#### On Windows:
- Download and install Node.js from [nodejs.org](https://nodejs.org/)
- Download and install R from [cran.r-project.org](https://cran.r-project.org/)

## Installation
1. Clone the repository
   ```bash
   git clone https://github.com/mukund58/Job-Recommender.git
   cd Job-Recommender
   ```

2. Install Node.js dependencies
   ```bash
   npm install
   ```

3. Install R packages
   Open an R session and run:
   ```r
   install.packages(c("plumber", "jsonlite", "dplyr", "purrr", "tibble", "stringr", "lubridate"))
   ```

## Usage
Start the R API server:
```bash
npm run serve-r-api
```
The Plumber API runs on port 8000.

Start the frontend development server:
```bash
npm run dev
```
Open http://localhost:5173 in your browser.

### Typical Workflow
1. Upload a PDF resume through the user interface.
2. The application extracts text and identifies skills from the predefined database.
3. Submit detected skills to obtain ranked job recommendations.
4. Review detailed matches, scores, and posting dates.

## API
### POST /recommend
- **Request body (JSON):**
  ```json
  { "skills": ["python", "react", "sql"] }
  ```
- **Response (JSON):** List of recommended jobs with scores, matched skills, and posted dates. Example:
  ```json
  {
    "results": [
      {
        "title_clean": "Data Scientist",
        "company_name": "Tech Corp",
        "location": "San Francisco, CA",
        "posted_date": "2023-08-03 12:00:13",
        "score": 85,
        "matches": 3,
        "matched_skills": ["python", "sql", "machine learning"],
        "description": "Full job description...",
        "tags": "Data Science, python, sql",
        "job_category": "Data Science",
        "seniority_level": "Senior",
        "remote_type": "Remote",
        "employment_type": "Full-time",
        "salary_range": "$100k - $150k"
      }
    ]
  }
  ```

## Project Structure
```
Job-Recommender/
├── public/
├── src/
│   ├── components/
│   │   ├── ResumeUploader.jsx
│   │   └── Recommendations.jsx
│   ├── App.jsx
│   ├── skills.json
│   └── ...
├── server/
│   └── r_backend/
│       ├── data/
│       │   └── enhanced_jobs_step3.json
│       ├── api.R
│       └── ...
├── package.json
├── vite.config.js
└── README.md
```

## Contributing
Contributions are welcome. Please follow the standard workflow:
1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Commit changes with clear messages.
4. Push the branch and open a Pull Request for review.

## Acknowledgments
- pdf.js
- The R community and CRAN packages
- Tailwind CSS
- React ecosystem

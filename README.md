# PDF Skill Extractor & Job Recommender

[![Build Status](https://img.shields.io/github/actions/workflow/status/mukund58/Job-Recommender/ci.yml?branch=main&label=build&logo=github&color=blue)](https://github.com/mukund58/Job-Recommender/actions)
[![Release](https://img.shields.io/github/v/release/mukund58/Job-Recommender?color=orange)](https://github.com/mukund58/Job-Recommender/releases)
[![License](https://img.shields.io/github/license/mukund58/Job-Recommender)](LICENSE)
[![Top Language](https://img.shields.io/github/languages/top/mukund58/Job-Recommender)](https://github.com/mukund58/Job-Recommender)
[![Repository Size](https://img.shields.io/github/repo-size/mukund58/Job-Recommender)](https://github.com/mukund58/Job-Recommender)
[![Last Commit](https://img.shields.io/github/last-commit/mukund58/Job-Recommender)](https://github.com/mukund58/Job-Recommender/commits)

Overview
--------
PDF Skill Extractor & Job Recommender is a web application that extracts text and technical skills from uploaded PDF resumes and returns personalized job recommendations using natural language processing and machine learning techniques.

Key features
------------
- Client-side PDF text extraction (pdf.js)
- Automatic detection of technical skills from resume content
- Job recommendation engine that ranks results by skill relevance and weighting
- Responsive user interface implemented with React and Tailwind CSS
- R-based backend (Plumber) for data processing and recommendation logic
- Detailed match results including scores, matched skills, and job metadata

Technology stack
----------------
Frontend
- React 19
- Vite
- Tailwind CSS
- pdf.js

Backend
- R with Plumber
- tidyverse, stringr, tm, jsonlite, purrr

Prerequisites
-------------
- Node.js v18 or later
- R v4.0 or later
- Required R packages: plumber, jsonlite, readr, dplyr, stringr, tm, tidyverse, purrr

Installation
------------
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
   install.packages(c("plumber", "jsonlite", "readr", "dplyr", "stringr", "tm", "tidyverse", "purrr"))
   ```

Optional: regenerate job data
-----------------------------
To regenerate the processed job datasets, execute the preprocessing scripts in the following order from the project root:
```bash
Rscript server/r_backend/job_Recommendation.R
Rscript server/r_backend/NLPSection.R
Rscript server/r_backend/analytics_fields.R
Rscript server/r_backend/search_optimization.R
```

Usage
-----
Start the R API server:
```bash
npm run serve-r-api
```
The Plumber API defaults to port 8000.

Start the frontend development server:
```bash
npm run dev
```
Open http://localhost:5173 in your browser.

Typical workflow
1. Upload a PDF resume through the user interface.
2. The application extracts text and identifies skills.
3. Submit detected skills to obtain ranked job recommendations.
4. Review detailed matches and scores.

API
---
POST /recommend
- Request body (JSON):
  ```json
  { "skills": ["python", "react", "sql"] }
  ```
- Response (JSON): list of recommended jobs with scores and matched skills. Example:
  ```json
  {
    "results": [
      {
        "title_clean": "Data Scientist",
        "company_name": "Tech Corp",
        "location": "San Francisco, CA",
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

Project structure
-----------------
```
Job-Recommender/
├── public/
│   └── skills.json
├── src/
│   ├── components/
│   │   ├── ResumeUploader.jsx
│   │   └── Recommendations.jsx
│   ├── App.jsx
│   └── skills.json
├── server/
│   └── r_backend/
│       ├── data/
│       ├── api.R
│       ├── job_Recommendation.R
│       ├── NLPSection.R
│       ├── analytics_fields.R
│       └── search_optimization.R
├── package.json
├── vite.config.js
└── README.md
```

Contributing
------------
Contributions are welcome. Please follow the standard workflow:
1. Fork the repository.
2. Create a feature branch: git checkout -b feature/your-feature.
3. Commit changes with clear messages.
4. Push the branch and open a Pull Request for review.

License
-------
This project is licensed under the MIT License. See the LICENSE file for details.

Acknowledgments
---------------
- pdf.js
- The R community and CRAN packages
- Tailwind CSS
- React ecosystem

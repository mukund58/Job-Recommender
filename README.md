# PDF Skill Extractor & Job Recommender

A modern web application that extracts text and skills from uploaded PDF resumes and provides personalized job recommendations using machine learning and NLP techniques.

## 🚀 Features

- **PDF Text Extraction**: Client-side PDF parsing using pdf.js
- **Skill Detection**: Automatic identification of technical skills from resume text
- **Job Recommendations**: AI-powered job matching based on extracted skills
- **Interactive UI**: Clean, responsive interface built with React and Tailwind CSS
- **Advanced Scoring**: Weighted skill matching with frequency-based scoring
- **Detailed Insights**: Match scores, matched skills, and job details
- **R Backend**: Robust data processing and recommendation engine

## 🛠 Tech Stack

### Frontend
- **React 19** - UI framework
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **pdf.js** - PDF parsing library

### Backend
- **R with Plumber** - REST API framework
- **tidyverse** - Data manipulation
- **stringr** - String processing
- **tm** - Text mining
- **jsonlite** - JSON handling

## 📋 Prerequisites

- **Node.js** (v18 or higher)
- **R** (v4.0 or higher)
- **R packages**: plumber, jsonlite, readr, dplyr, stringr, tm, tidyverse, purrr

## 🔧 Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd PdfExtracter
```

### 2. Install Node.js Dependencies
```bash
npm install
```

### 3. Install R Packages
Open R console and install required packages:
```r
install.packages(c("plumber", "jsonlite", "readr", "dplyr", "stringr", "tm", "tidyverse", "purrr"))
```

### 4. Prepare Data (Optional)
If you need to regenerate the job data:

Run the preprocessing scripts in order:
```bash
# From project root
Rscript server/r_backend/job_Recommendation.R
Rscript server/r_backend/NLPSection.R
Rscript server/r_backend/analytics_fields.R
Rscript server/r_backend/search_optimization.R
```

This will process raw job data into the enhanced datasets used by the API.

## 🚀 Usage

### Start the R API Server
```bash
npm run serve-r-api
```
This starts the Plumber API on port 8000.

### Start the React Frontend
In a new terminal:
```bash
npm run dev
```
Open [http://localhost:5173](http://localhost:5173) in your browser.

### Using the Application
1. Upload a PDF resume
2. The app extracts text and detects skills automatically
3. Click to get job recommendations
4. View personalized job matches with scores and details

## 📡 API Endpoints

### POST /recommend
Send detected skills to get job recommendations.

**Request:**
```json
{
  "skills": ["python", "react", "sql"]
}
```

**Response:**
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

## 📁 Project Structure

```
PdfExtracter/
├── public/
│   └── skills.json          # Skill keywords for detection
├── src/
│   ├── components/
│   │   ├── ResumeUploader.jsx    # PDF upload and extraction
│   │   └── Recommendations.jsx   # Job recommendations display
│   ├── App.jsx               # Main application component
│   └── skills.json           # Fallback skills data
├── server/
│   └── r_backend/
│       ├── data/             # Processed job data files
│       ├── api.R             # Plumber API endpoints
│       ├── job_Recommendation.R    # Data preprocessing
│       ├── NLPSection.R      # NLP feature extraction
│       ├── analytics_fields.R     # Business analytics
│       └── search_optimization.R  # UI optimization
├── package.json
├── vite.config.js
└── README.md
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- pdf.js for PDF processing
- R community for data science tools
- Tailwind CSS for styling
- React ecosystem for frontend development
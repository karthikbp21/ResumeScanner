# README

Looking at your Rails application, here's a comprehensive summary of what it does:
📋 Resume AI Assistant - Candidate Screening System
Primary Purpose
This is an AI-powered recruitment tool that automates resume screening and candidate evaluation for a Physics Assistant Professor position.
Core Functionality
1. Resume Processing Pipeline
   Upload: HR can upload multiple PDF resumes through a web interface
   Text Extraction: Uses PDF::Reader to extract text content from uploaded resumes
   AI Analysis: Leverages OpenAI GPT-3.5-turbo to analyze and structure candidate data
   Storage: Saves structured candidate information to a MySQL database

2. AI-Powered Data Extraction
   The system extracts these fields from resumes:
   Personal Info (Name, Email, Phone, Gender, Location)
   Professional Info (Experience years, Education, Skills, Domain)
   Employment (Current employer)
   AI Assessment (Strong fit / Needs review / Not a fit)
   Human-readable summary

3. Intelligent Search & Filtering
   Natural Language Queries: HR can ask questions like "candidates with 5+ years experience and strong rating"
   AI Query Processing: Uses GPT to understand queries and return matching candidate IDs
   Real-time Results: Uses Turbo Streams for dynamic table updates without page refresh

4. Data Export
   Excel Download: Exports all candidate data to Excel format for offline analysis
   Technical Architecture
   Backend (Rails)
   Controllers: Handle web requests and coordinate between services
   Background Jobs: Process resumes asynchronously using Rails ActiveJob
   Services:
   GptQueryAgentService: Processes search queries
   GptParserService: Parses AI responses into structured data
   Models: Simple Candidate model for data persistence
   Frontend
   Bootstrap UI: Clean, responsive interface
   Turbo Streams: Real-time table updates for search results
   File Upload: Multi-file PDF upload with progress indicators
   AI Integration
   OpenAI GPT-3.5-turbo: For resume analysis and query processing
   Custom Prompts: Structured prompts for consistent data extraction
   Error Handling: Manages API rate limits and failures
   User Workflow
   Upload Resumes → System extracts and analyzes content
   View Candidates → See all processed candidates in a table
   Search/Filter → Use natural language to find specific candidates
   Export Data → Download results to Excel for further analysis
   Key Features
   ✅ Automated Resume Screening: No manual data entry required
   ✅ AI-Powered Matching: Smart candidate evaluation and fit assessment
   ✅ Natural Language Search: Intuitive query interface
   ✅ Real-time Updates: Dynamic filtering without page reloads
   ✅ Export Capabilities: Easy data export for reporting
   Current Job Posting Context
   The system is specifically configured for hiring an Assistant Professor of Physics with requirements for:
   PhD in Physics
   Teaching and research experience
   Interdisciplinary collaboration interest
   This is essentially a smart ATS (Applicant Tracking System) that uses AI to automate the initial resume screening process, making recruitment more efficient for academic positions.


To summarise the key components what this Rails application does:
This is a smart hiring assistant that helps HR teams find the best candidates for a Physics Professor job without manually reading through hundreds of resumes.
Key Features

📄 Smart Resume Processing
HR uploads PDF resumes (multiple files at once)
The system automatically reads and understands what's in each resume
Extracts important information like name, experience, skills, education
Gives each candidate a rating: "Strong Fit", "Needs Review", or "Not a Fit"

🔍 Intelligent Search
Instead of filtering through checkboxes, HR can ask questions in plain English
Examples: "Show me candidates with more than 5 years experience" or "Find people with PhD in Physics"
The system understands the question and shows matching candidates instantly

📊 Easy Viewing & Export
All candidates are displayed in a clean table format
Shows key info at a glance: name, experience, skills, rating, summary
Can download all data to Excel for reports or sharing with colleagues

⚡ Time-Saving Benefits
No Manual Data Entry: System reads resumes automatically
No Reading Every Resume: AI creates summaries for quick review
Smart Filtering: Find exactly who you're looking for with simple questions
Instant Results: See filtered candidates immediately without page reloads

Perfect For
HR departments handling large volumes of applications
Academic institutions hiring faculty
Any organization wanting to speed up initial resume screening

Bottom Line
This application turns the tedious task of manually reviewing resumes into a quick, intelligent process where HR can focus on the best candidates rather than spending hours reading through every application.

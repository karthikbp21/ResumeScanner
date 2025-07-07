class CandidateSummaryAgentJob < ApplicationJob
  queue_as :default

  def perform(resume_path, text)
    p "Processing resume: #{resume_path}"
    ENV['OPENAI_API_KEY'] = "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"
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    prompt = <<~PROMPT
      You are an AI assistant for HR. Extract the following fields from the resume and return your response strictly in valid JSON format:

      {
        "name": "",
        "email": "",
        "phone": "",
        "gender": "",
        "location": "",
        "experience_years": 0.0,
        "education": "",
        "skills": "",
        "domain": "",
        "current_employer": "",
        "fit_rating": "",
        "summary": ""
      }

      Extraction instructions for each field:
      - "name": Extract the full professional name. If multiple names or titles are present, include only the main professional name.
      - "email": Extract the primary professional email. If multiple, prefer the one associated with academic or work domains.
      - "phone": Extract the main contact phone number, in international format if available.
      - "gender": Extract if explicitly mentioned or can be inferred with high confidence, otherwise return an empty string.
      - "location": Extract the current location. If multiple, prefer the most recent or current city/state/country.
      - "experience_years":
        - Sum the total duration (in years, including partial years as decimals, e.g., 9.5) of all non-overlapping professional positions, including postdoctoral, professorship, and any other relevant roles.
        - Calculate each period as (end year - start year), using the current year and month (July 2025) for positions marked as "Present". For example, if a job started in mid-2018 and is still ongoing as of July 2025, count it as 7.5 years.
        - If only years are given, assume the job started and ended mid-year (e.g., 2016–2018 = 2.0 years). If months are given, calculate more precisely (e.g., Jan 2016–Jun 2018 = 2.5 years).
        - Return the result as a float (e.g., 9.5).
      - "education": List all degrees, certifications, and ongoing education with year and institution. If ongoing, mark as 'in progress'. comma-separated of objects with degree, year, and institution.
      - "skills": List all technical and soft skills separately if possible. If proficiency is mentioned, include it. comma-separated.
      - "domain": List all domains/subject areas mentioned, separated by commas. comma-separated.
      - "current_employer": Extract the current main employer. If self-employed or freelance, state as such.
      - "fit_rating": Based on the job description, rate the candidate as 'Strong fit', 'Needs review', or 'Not a fit'.
      - "summary": Extract a concise summary of the candidate’s profile, or generate one if not explicitly present.
      - If the resume does not contain a field, return an empty string.
      - Format the response strictly as valid JSON.

      Resume:
      #{text.truncate(3000)}
    PROMPT
    
    response = client.chat(parameters: {
      model: "gpt-4", # use gpt-3.5-turbo if needed
      messages: [
        { role: "user", content: prompt }
      ],
      temperature: 0.3
    })

    gpt_output = response.dig("choices", 0, "message", "content")
    parsed = GptParserService.new(gpt_output).parse
    p "Parsed candidate data: #{parsed.inspect}"
    Candidate.create!(parsed)
  rescue => e
    Rails.logger.error "CandidateSummaryAgentJob failed: #{e.message}"
  end
end

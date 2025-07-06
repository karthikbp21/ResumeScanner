class CandidateSummaryAgentJob < ApplicationJob
  queue_as :default

  def perform(resume_path, text)
    p "Processing resume: #{resume_path}"
    ENV['OPENAI_API_KEY'] = "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"
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    prompt = <<~PROMPT
      You are an AI assistant for HR. Extract the following fields from the resume:
      - Name
      - Email
      - Phone
      - Gender (if inferable)
      - Location
      - Total experience in years
      - Highest education
      - Key skills
      - Domain/Subject area
      - Current employer (if any)
      - Fit rating (Strong fit / Needs review / Not a fit)
      - One-paragraph human-readable summary

      Resume:
      #{text.truncate(3000)}
    PROMPT
    
    response = client.chat(parameters: {
      model: "gpt-3.5-turbo",
      messages: [
        { role: "user", content: prompt }
      ],
      temperature: 0.4
    })

    content = response.dig("choices", 0, "message", "content")
    parsed = GptParserService.new(content).parse

    p "Parsed candidate data: #{parsed.inspect}"
    Candidate.create!(parsed)
  end
end

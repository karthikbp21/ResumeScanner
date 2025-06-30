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

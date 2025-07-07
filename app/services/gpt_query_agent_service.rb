class GptQueryAgentService
  def initialize(prompt)
    @prompt = prompt
  end

  def run
    p "Running GPT query with prompt: #{@prompt}"
    all_data = Candidate.all.map(&:attributes).to_json

    query = <<~QUERY
      You are an AI assistant for HR. You have access to the following candidate data as an array of hashes (each hash represents a candidate, with fields such as name, email, phone, gender, location, experience_years, education, skills, domain, current_employer, fit_rating, summary, work_experience, etc). Some fields may be arrays or objects (e.g. work_experience).

      DATA:
      #{all_data}

      Given this user query: "#{@prompt}", return an array of IDs of matching candidates only.

      Instructions:
      - Use all available fields for filtering, including arrays and objects (e.g. work_experience).
      - For array fields , match if any element in the array satisfies the query condition.
      - For work_experience, match if any job/position in the array matches the query (e.g., by title, employer, years, description, etc).
      - For numeric fields (like experience_years), support queries like "> 5 years", "at least 10 years", etc.
      - For text fields, support partial and case-insensitive matches.
      - If the query is ambiguous, return candidates that best match the intent.
      - Output ONLY a Ruby array of IDs like: [1, 4, 7] (no explanation, no extra text).
      - If no candidates match, return an empty array [].
    QUERY
    ENV['OPENAI_API_KEY'] = "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"
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    begin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [ { role: "user", content: query } ],
          temperature: 0.3
        }
      )

      content = response.dig("choices", 0, "message", "content")

      ids = JSON.parse(content.gsub("=>", ":")) rescue []
      ids.is_a?(Array) ? ids : []
    rescue Faraday::TooManyRequestsError => e
      Rails.logger.error "[GPTQueryAgentService] Rate limited (429): #{e.message}"
      []
    rescue Faraday::ResourceNotFound => e
      Rails.logger.error "[GPTQueryAgentService] Invalid model or endpoint (404): #{e.message}"
      []
    rescue => e
      Rails.logger.error "[GPTQueryAgentService] Unexpected error: #{e.message}"
      []
    end
  end
end

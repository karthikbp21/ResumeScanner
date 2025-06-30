class GptQueryAgentService
  def initialize(prompt)
    @prompt = prompt
  end

  def run
    all_data = Candidate.all.map(&:attributes).to_json

    query = <<~QUERY
      You are an AI assistant with access to the following candidate data:
      #{all_data}

      Given this user query: "#{@prompt}", return an array of IDs of matching candidates only.
      Output ONLY a Ruby array of IDs like: [1, 4, 7]
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

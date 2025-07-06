class GptQueryAgentService
  def initialize(prompt)
    @prompt = prompt
  end

  def run
    p "Running GPT query with prompt: #{@prompt}"
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

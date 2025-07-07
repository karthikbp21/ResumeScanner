class GptParserService
  def initialize(gpt_output)
    @output = gpt_output
  end

  def parse
    json_text = extract_json(@output)
    JSON.parse(json_text, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error("GPTParserService JSON parsing failed: #{e.message}")
    {}
  end

  private

  def extract_json(text)
    text[/\{.*\}/m] || "{}"
  end
end
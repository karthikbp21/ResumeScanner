class ResumeScreeningAgentJob < ApplicationJob
  queue_as :default

  def perform(*args)
    p "Starting resume screening job..."
    Dir.glob(Rails.root.join("storage/resumes/*.pdf")).each do |resume_path|
      text = extract_text_from_pdf(resume_path)
      CandidateSummaryAgentJob.perform_later(resume_path, text)
    end
  end

  private

  def extract_text_from_pdf(path)
    reader = PDF::Reader.new(path)
    reader.pages.map(&:text).join("\n")
  rescue => e
    Rails.logger.error "Failed to extract text: #{e.message}"
    ""
  end
end

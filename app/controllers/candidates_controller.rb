class CandidatesController < ApplicationController
  def index
    @candidates = Candidate.all
    @resume_count = Dir.glob(Rails.root.join("storage/resumes/*.pdf")).count
  end

  def scan_resumes
    ResumeScreeningAgentJob.perform_later
    redirect_to candidates_path, notice: "Scanning resumes..."
  end

  def download_excel
    @candidates = Candidate.all
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="candidates.xlsx"'
      }
    end
  end

  def query
    prompt = params[:prompt]
    filtered_ids = GPTQueryAgentService.new(prompt).run

    if filtered_ids.blank?
      flash[:alert] = "No results found or OpenAI limit reached. Try again later."
    end

    @candidates = Candidate.where(id: filtered_ids)
    render :index
  end
end

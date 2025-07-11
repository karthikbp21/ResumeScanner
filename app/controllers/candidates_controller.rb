class CandidatesController < ApplicationController
  def index
    @candidates = Candidate.all
    @resume_count = Dir.glob(Rails.root.join("storage/resumes/*.pdf")).count
  end

  def scan_resumes
    p "Starting resume scanning job..."
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

  # def query
  #   # prompt = params[:prompt]
  #   # filtered_ids = GptQueryAgentService.new(prompt).run
  #   #
  #   # if filtered_ids.blank?
  #   #   flash[:alert] = "No results found or OpenAI limit reached. Try again later."
  #   # end
  #   #
  #   # @candidates = Candidate.where(id: filtered_ids)
  #   # render :index
  #
  #
  #   prompt = params[:prompt]
  #   filtered_ids = GptQueryAgentService.new(prompt).run
  #   if filtered_ids.blank?
  #     flash[:alert] = "No results found or OpenAI limit reached. Try again later."
  #   end
  #   @candidates = Candidate.where(id: filtered_ids)
  #
  #   respond_to do |format|
  #     format.turbo_stream
  #     format.html { render :index }
  #   end
  # end

  def query
    prompt = params[:prompt].to_s.strip
    p "Received query: #{prompt}"

    if prompt.blank?
      @candidates = Candidate.all
    else
      filtered_ids = GptQueryAgentService.new(prompt).run
      p "Filtered IDs returned: #{filtered_ids.inspect}"
      if filtered_ids.blank?
        flash[:alert] = "No results found or OpenAI limit reached. Try again later."
        @candidates = Candidate.none
      else
        @candidates = Candidate.where(id: filtered_ids)
      end
      p "Final candidates count: #{@candidates.count}"
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  def upload_resumes
    if params[:resumes].present?
      params[:resumes].each do |uploaded_file|
        filename = uploaded_file.original_filename
        save_path = Rails.root.join("storage", "resumes", filename)
        File.open(save_path, "wb") { |f| f.write(uploaded_file.read) }
      end
      ResumeScreeningAgentJob.perform_later
      flash[:notice] = "Uploaded and scanning resumes..."
    else
      flash[:alert] = "Please select at least one PDF file."
    end
    redirect_to candidates_path
  end
end

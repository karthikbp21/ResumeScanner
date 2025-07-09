class CandidatesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:upload_resumes, :query]

  def index

    @candidates = Candidate.all
    Rails.logger.info "Candidates fetched: "+ @candidates.inspect
    @resume_count = Dir.glob(Rails.root.join("storage/resumes/*.pdf")).count

    respond_with_candidates
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
      format.json { render json: @candidates }
    end
  end

  def upload_resumes
    Rails.logger.info "Incoming parameters: "+ params.inspect
    if params[:resumes].present?
      begin
        params[:resumes].each do |uploaded_file|
          filename = uploaded_file.original_filename
          save_path = Rails.root.join("storage", "resumes", filename)

          # Ensure the directory exists
          FileUtils.mkdir_p(Rails.root.join("storage", "resumes"))

          # Validate file type
          unless uploaded_file.content_type == "application/pdf"
            flash[:alert] = "Invalid file type. Only PDF files are allowed."
            next
          end

          # Save the file
          File.open(save_path, "wb") { |f| f.write(uploaded_file.read) }
        end
        ResumeScreeningAgentJob.perform_later
        flash[:notice] = "Uploaded and scanning resumes..."
        Rails.logger.info "Redirecting to candidates_path after successful upload"
        render json: Candidate.all
      rescue => e
        Rails.logger.error "Error processing uploaded file: #{e.message}"
        flash[:alert] = "Failed to process uploaded file. Please try again."
      end
    else
      flash[:alert] = "Please select at least one PDF file."
    end
  end

  private

  def respond_with_candidates
    respond_to do |format|
      format.html
      format.json { render json: @candidates }
    end
  end
end

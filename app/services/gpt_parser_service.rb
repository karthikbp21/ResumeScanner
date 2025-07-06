class GptParserService
  def initialize(gpt_output)
    @output = gpt_output
  end

  def parse
    {
      name: extract(/-?\s*Name:\s*(.*)/),
      email: extract(/-?\s*Email:\s*(.*)/),
      phone: extract(/-?\s*Phone:\s*(.*)/),
      gender: extract(/-?\s*Gender:\s*(.*)/),
      location: extract(/-?\s*Location:\s*(.*)/),
      experience_years: extract(/-?\s*Total experience.*?:\s*(\d+)/).to_i,
      education: extract(/-?\s*(Highest education|Education):\s*(.*)/, 2),
      skills: extract(/-?\s*(Key skills|Skills):\s*(.*)/, 2),
      domain: extract(/-?\s*(Domain|Domain\/Subject area):\s*(.*)/, 2),
      current_employer: extract(/-?\s*(Current employer|Employer):\s*(.*)/, 2),
      fit_rating: extract(/-?\s*Fit rating:\s*(.*)/),
      summary: extract(/Summary:\s*(.*)/m)
    }
  end

  def extract(regex, capture_group = 1)
    @output.match(regex)&.captures&.[](capture_group - 1)&.strip
  end
end
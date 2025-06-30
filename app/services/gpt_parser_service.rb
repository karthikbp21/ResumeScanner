class GptParserService
  def initialize(gpt_output)
    @output = gpt_output
  end

  def parse
    {
      name: extract(/Name: (.*)/),
      email: extract(/Email: (.*)/),
      phone: extract(/Phone: (.*)/),
      gender: extract(/Gender: (.*)/),
      location: extract(/Location: (.*)/),
      experience_years: extract(/Total experience.*: (\d+)/).to_i,
      education: extract(/Education: (.*)/),
      skills: extract(/Skills: (.*)/),
      domain: extract(/Domain: (.*)/),
      current_employer: extract(/Employer: (.*)/),
      fit_rating: extract(/Fit rating: (.*)/),
      summary: extract(/Summary: (.*)/m)
    }
  end

  def extract(regex)
    @output.match(regex)&.captures&.first&.strip
  end
end
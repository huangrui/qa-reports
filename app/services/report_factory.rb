module ReportFactory

  def self.create(params)
    generate_title(params)
    generate_environment_txt(params)
    parse_result_files(params)

    MeegoTestSession.new(params)
  end

  private

  def self.generate_title(params)
    tested_at = DateTime.parse(params[:tested_at]).strftime('%Y-%m-%d')
    title_values = [params[:target], params[:hwproduct], params[:testtype], tested_at]
    params[:title] ||= "%s Test Report: %s %s %s" % title_values
  end

  def self.generate_environment_txt(params)
    params[:environment_txt] ||= "* Hardware: " + params[:hwproduct]
  end

  def self.parse_result_files(params)
    result_files = params[:uploaded_files]
    params[:uploaded_files] = nil
    params[:meego_test_sets_attributes] = []

    result_files.each do |file|
      params[:meego_test_sets_attributes] += ResultFileParser.parse_csv(file)
    end
  end

end
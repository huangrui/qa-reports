require 'fileutils'

module ReportFactory

  def self.create(params)
    generate_title(params)
    generate_environment_txt(params)
    parse_result_files(params)
    save_result_files(params)

    MeegoTestSession.new(params)
  end

  private

  def self.generate_title(params)
    tested_at = DateTime.parse(params[:tested_at]).strftime('%Y-%m-%d')
    title_values = [params[:target], params[:hardware], params[:testtype], tested_at]
    params[:title] ||= "%s Test Report: %s %s %s" % title_values
  end

  def self.generate_environment_txt(params)
    params[:environment_txt] ||= "* Hardware: " + params[:hardware]
  end

  def self.parse_result_files(params)
    test_cases = {}

    params[:uploaded_files].each do |file|
      new_test_cases = ResultFileParser.parse_csv(file)

      new_test_cases.each do |feature, tcs|
        test_cases[feature] ||= {}
        test_cases[feature].merge!(tcs)
      end
    end

    test_sets = []
    test_cases.each do |feature, test_cases|
      test_sets << {:feature => feature, :meego_test_cases_attributes => test_cases}
    end

    params[:meego_test_sets_attributes] = test_sets
  end

  def self.save_result_files(params)
    test_result_files = []

    params[:uploaded_files].each do |tmpfile|
      result_file = generate_file_destination_path(tmpfile.original_filename)
      FileUtils.move tmpfile, result_file
      test_result_files << {:path => result_file}
    end

    params[:test_result_files_attributes] = test_result_files
  end

  def self.generate_file_destination_path(original_filename)
    datepart = Time.now.strftime("%Y%m%d")
    dir      = File.join(MeegoTestSession::RESULT_FILES_DIR, datepart)
    FileUtils.mkdir_p(dir)

    filename     = ("%06i-" % Time.now.usec) + sanitize_filename(original_filename)
    path_to_file = File.join(dir, filename)
  end

  def self.sanitize_filename(filename)
    filename.gsub(/[^\w\.\_\-]/, '_')
  end
end

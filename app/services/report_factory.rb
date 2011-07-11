require 'fileutils'
require 'result_file_parser'

module ReportFactory

  def self.create(params)
    generate_title(params)
    parse_result_files(params)
    save_result_files(params)

    test_session = MeegoTestSession.new(params)
    copy_template_values(test_session)
    #generate_environment_txt
    test_session
  end

  private

  def self.generate_title(params)
    tested_at = DateTime.parse(params[:tested_at]).strftime('%Y-%m-%d')
    title_values = [params[:target], params[:product], params[:testset], tested_at]
    params[:title] ||= "%s Test Report: %s %s %s" % title_values
  end

  def self.parse_result_files(params)
    test_cases = {}

    params[:uploaded_files].each do |file|
      begin
        if file.path =~ /.csv$/i
          new_test_cases = ResultFileParser.parse_csv(file.open)
        else
          new_test_cases = ResultFileParser.parse_xml(file.open)
        end
      rescue => e
        Rails.logger.error "ERROR in file parsing"
        Rails.logger.error file.name
        Rails.logger.error e
        Rails.logger.error e.backtrace
        #TODO: Raise error and catch at controller
      end

      new_test_cases.each do |feature, tcs|
        test_cases[feature] ||= {}
        test_cases[feature].merge!(tcs)
      end
    end

    features = []
    test_cases.each do |feature, test_cases|
      features << {:name => feature, :meego_test_cases_attributes => test_cases}
    end

    params[:features_attributes] = features
  end

  # TODO: This should be handled with paperclip
  def self.save_result_files(params)
    test_result_files = []

    params[:uploaded_files].each do |tmpfile|
      result_file_path = generate_file_destination_path(tmpfile.original_filename)
      FileUtils.move tmpfile.path, result_file_path
      test_result_files << {:path => result_file_path}
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

  def self.copy_template_values(test_session)
    # See if there is a previous report with the same test target and type
    prev = test_session.prev_session
    if prev
      test_session.objective_txt     = prev.objective_txt if test_session.objective_txt.empty?
      test_session.build_txt         = prev.build_txt if test_session.build_txt.empty?
      test_session.environment_txt   = prev.environment_txt if test_session.environment_txt.empty?
      test_session.qa_summary_txt    = prev.qa_summary_txt if test_session.qa_summary_txt.empty?
      test_session.issue_summary_txt = prev.issue_summary_txt if test_session.issue_summary_txt.empty?
    end

    test_session.generate_defaults!
  end

  def self.generate_environment_txt(params)
    params[:environment_txt] ||= "* Hardware: " + params[:hardware]
  end
end

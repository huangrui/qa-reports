require 'fileutils'
require 'result_file_parser'

class ReportFactory

  def create(params)
    @errors = {}

    begin
      generate_title(params)
      parse_result_files(params)
      save_result_files(params)

      test_session = MeegoTestSession.new(params)
      copy_template_values(test_session)
      #generate_environment_txt
    rescue
      test_session = MeegoTestSession.new(params)

      #test_session.errors.add(:uploaded_files, "You can only upload files with the extension .xml or .csv")
      @errors.each { |attribute, message| test_session.errors.add(attribute, message) }
    end

    test_session
  end

  private

  def generate_title(params)
    params[:tested_at] ||= Time.now
    tested_at = DateTime.parse(params[:tested_at]).strftime('%Y-%m-%d')
    title_values = [params[:target], params[:product], params[:testset], tested_at]
    params[:title] ||= "%s Test Report: %s %s %s" % title_values
  end

  def parse_result_files(params)
    test_cases = {}
    #raise "No result files" unless params[:uploaded_files]

    params[:uploaded_files].each do |file|
      if file.original_filename =~ /.csv$/i
        new_test_cases = ResultFileParser.parse_csv(file.open)
      elsif file.original_filename =~ /.xml$/i
        new_test_cases = ResultFileParser.parse_xml(file.open)
      else
        Rails.logger.error "ERROR in file parsing: " + file.original_filename
        @errors[:uploaded_files] = "You can only upload files with the extension .xml or .csv"
        raise "You can only upload files with the extension .xml or .csv"
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
  def save_result_files(params)
    test_result_files = []

    params[:uploaded_files].each do |tmpfile|
      result_file_path = generate_file_destination_path(tmpfile.original_filename)
      FileUtils.move tmpfile.path, result_file_path
      test_result_files << {:path => result_file_path}
    end

    params[:test_result_files_attributes] = test_result_files
  end

  def generate_file_destination_path(original_filename)
    datepart = Time.now.strftime("%Y%m%d")
    dir      = File.join(MeegoTestSession::RESULT_FILES_DIR, datepart)
    FileUtils.mkdir_p(dir)

    filename     = ("%06i-" % Time.now.usec) + sanitize_filename(original_filename)
    path_to_file = File.join(dir, filename)
  end

  def sanitize_filename(filename)
    filename.gsub(/[^\w\.\_\-]/, '_')
  end

  def copy_template_values(test_session)
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

  def generate_environment_txt(params)
    params[:environment_txt] ||= "* Hardware: " + params[:hardware]
  end
end

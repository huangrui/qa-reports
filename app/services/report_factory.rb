require 'fileutils'
require 'xml_result_file_parser'
require 'csv_result_file_parser'
require 'parse_error'

class ReportFactory

  def build(params)
    @errors = {}

    begin
      generate_title(params)
      parse_result_files(params)
      save_result_files(params)

      test_session = MeegoTestSession.new(params)
      build_test_case_associations(test_session)
      copy_template_values(test_session)
      #generate_environment_txt
    rescue ParseError => e
      Rails.logger.error "ERROR IN FILE PARSING: " + e.filename
      Rails.logger.error "ERROR MESSAGE: " + e.message
      test_session = MeegoTestSession.new(params)
      test_session.errors.add(:uploaded_files, e.message)
    end

    test_session
  end

  private

  def generate_title(params)
    params[:tested_at] = Time.now.to_s unless params[:tested_at].present?

    tested_at = DateTime.parse(params[:tested_at]).strftime('%Y-%m-%d')
    title_values = [params[:target], params[:product], params[:testset], tested_at]
    params[:title] ||= "%s Test Report: %s %s %s" % title_values
  end

  def parse_result_files(params)
    test_cases = {}
    #raise "No result files" unless params[:uploaded_files]

    params[:uploaded_files].each do |file|
      if file.original_filename =~ /.csv$/i
        new_test_cases = CSVResultFileParser.new.parse(file.open)
      elsif file.original_filename =~ /.xml$/i
        begin
          new_test_cases = XMLResultFileParser.new.parse(file.open)
        rescue Nokogiri::XML::SyntaxError => e
          raise ParseError.new(file.original_filename), file.original_filename + ": " + e.message
        end
      else
        raise ParseError.new(file.original_filename), "You can only upload files with the extension .xml or .csv"
      end

      raise ParseError.new(file.original_filename), file.original_filename + " didn't contain any valid test cases" if new_test_cases.empty?

      new_test_cases.each do |feature, tcs|
        test_cases[feature] ||= {}
        test_cases[feature].merge!(tcs)
      end
    end

    # Merge results from the new file with the existing results
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

  def build_test_case_associations(test_session)
    #TODO: This association could be thrown away and navigated through features
    test_session.features.each do |feature|
      feature.meego_test_cases.each { |tc| tc.meego_test_session = test_session }
    end
  end

  def copy_template_values(test_session)
    prev = test_session.prev_session

    if prev
      test_session.objective_txt     = prev.objective_txt     if test_session.objective_txt.empty?
      test_session.build_txt         = prev.build_txt         if test_session.build_txt.empty?
      test_session.environment_txt   = prev.environment_txt   if test_session.environment_txt.empty?
      test_session.qa_summary_txt    = prev.qa_summary_txt    if test_session.qa_summary_txt.empty?
      test_session.issue_summary_txt = prev.issue_summary_txt if test_session.issue_summary_txt.empty?

      #Copy test case comments from previous test report in case the test case result hasn't changed
      test_session.features.each do |feature|
        feature.meego_test_cases.each do |tc|
          prev_tc = prev.test_case_by_name(feature.name, tc.name)

          if prev_tc and tc.result == prev_tc.result and tc.comment.blank?
            tc.comment = prev_tc.comment
          end
        end
      end
    end

    test_session.generate_defaults!
  end

  def generate_environment_txt(params)
    params[:environment_txt] ||= "* Hardware: " + params[:hardware]
  end
end

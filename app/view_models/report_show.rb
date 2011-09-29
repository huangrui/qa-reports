class ReportShow < SummaryShow

  delegate :created_at, :failed,  :id,     :measured, :na,         :passed,
           :product,    :release, :target, :title,    :test_cases, :testset,
           :max_feature_cases,    :build_id,
           :to => :@report

  def initialize(report)
    @report = report
    super(@report)
  end

  def features
    @features ||= @report.features.map { |feature| FeatureShow.new(feature) }
  end

  def non_empty_features
    @non_empty_features ||= @report.non_empty_features.map { |feature| FeatureShow.new(feature) }
  end

end

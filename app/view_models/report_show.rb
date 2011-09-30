class ReportShow < SummaryShow

  delegate :build_id, :created_at, :max_feature_cases, :product, :release, :target, :title,
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

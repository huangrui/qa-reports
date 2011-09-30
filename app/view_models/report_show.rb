class ReportShow < SummaryShow

  delegate :build_id, :created_at, :max_feature_cases, :product, :release, :target, :testset, :title,
           :to => :@report

  def initialize(report, build_diff=[])
    super(report, build_diff)
  end

  def features
    @features ||= @report.features.map { |feature| FeatureShow.new(feature, @build_diff) }
  end

  def non_empty_features
    @non_empty_features ||= @report.non_empty_features.map { |feature| FeatureShow.new(feature, @build_diff) }
  end

end

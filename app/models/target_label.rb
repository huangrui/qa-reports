class TargetLabel < ActiveRecord::Base
  def self.labels
    find(:all, :select => "normalized").map(&:normalized)
  end

  def self.first_label
    first(:conditions => ["sort_order = 0"], :select => "label").label
  end
end

class Profile < ActiveRecord::Base
  def self.names
    order("sort_order ASC").select(:label).map(&:label)
  end

  def self.labels
    find(:all, :select => "normalized").map(&:normalized)
  end

  def self.first_label
    first(:conditions => ["sort_order = 0"], :select => "label").label
  end
end

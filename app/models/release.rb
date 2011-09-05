class Release < ActiveRecord::Base

  scope :in_sort_order, order("sort_order ASC")

  def self.release_versions
    find(:all, :order => "sort_order ASC", :select => "name").map(&:name)
  end

  def self.latest
    in_sort_order.first
  end

end

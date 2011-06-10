class VersionLabel < ActiveRecord::Base

  scope :in_sort_order, order("sort_order ASC")

  def self.versions
    find(:all, :select => "normalized").map(&:normalized)
  end

  def self.latest
    in_sort_order.first
  end
end

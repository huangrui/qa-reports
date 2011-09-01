class Release < ActiveRecord::Base

  scope :in_sort_order, order("sort_order ASC")

  def self.release_versions
    find(:all, :order => "sort_order ASC", :select => "name").map(&:name)
  end

  def self.latest
    in_sort_order.first
  end

  def label
    read_attribute(:name)
  end

  def label=(value)
    write_attibute(:name, value)
  end

  def normalized
    read_attribute(:name).downcase
  end

 def normalized=(value)
     write_attribute(:normalized, value)
 end

end

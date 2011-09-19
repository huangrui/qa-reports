class AddDefaultLabels < ActiveRecord::Migration

  class VersionLabel < ActiveRecord::Base
  end

  def self.up
    vl = VersionLabel.find_by_label("1.2")
    unless vl
      VersionLabel.create! :label => "1.2", :normalized => "1.2", :sort_order => 0
    end

    vl = VersionLabel.find_by_label("1.1")
    unless vl
      VersionLabel.create! :label => "1.1", :normalized => "1.1", :sort_order => 1
    end

    vl = VersionLabel.find_by_label("1.0")
    unless vl
      VersionLabel.create! :label => "1.0", :normalized => "1.0", :sort_order => 2
    end

    tl = Profile.find_by_label("Core")
    unless tl
      Profile.create! :label => "Core", :normalized => "core", :sort_order => 0
    end

    tl = Profile.find_by_label("Handset")
    unless tl
      Profile.create! :label => "Handset", :normalized => "handset", :sort_order => 1
    end

    tl = Profile.find_by_label("Netbook")
    unless tl
      Profile.create! :label => "Netbook", :normalized => "netbook", :sort_order => 2
    end

    tl = Profile.find_by_label("IVI")
    unless tl
      Profile.create! :label => "IVI", :normalized => "ivi", :sort_order => 3
    end

    tl = Profile.find_by_label("SDK")
    unless tl
      Profile.create! :label => "SDK", :normalized => "sdk", :sort_order => 4
    end
  end

  def self.down
    VersionLabel.find(:first, :conditions => {:label => "1.2"}).destroy
    VersionLabel.find(:first, :conditions => {:label => "1.1"}).destroy
    VersionLabel.find(:first, :conditions => {:label => "1.0"}).destroy

    Profile.find(:first, :conditions => {:label => "Core"}).destroy
    Profile.find(:first, :conditions => {:label => "Handset"}).destroy
    Profile.find(:first, :conditions => {:label => "Netbook"}).destroy
    Profile.find(:first, :conditions => {:label => "IVI"}).destroy
    Profile.find(:first, :conditions => {:label => "SDK"}).destroy
  end

end

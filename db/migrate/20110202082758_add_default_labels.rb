class AddDefaultLabels < ActiveRecord::Migration
  def self.up
    VersionLabel.create! :label => "1.2", :normalized => "1.2", :sort_order => 0
    VersionLabel.create! :label => "1.1", :normalized => "1.1", :sort_order => 1
    VersionLabel.create! :label => "1.0", :normalized => "1.0", :sort_order => 2

    TargetLabel.create! :label => "Core", :normalized => "core", :sort_order => 0
    TargetLabel.create! :label => "Handset", :normalized => "handset", :sort_order => 1
    TargetLabel.create! :label => "Netbook", :normalized => "netbook", :sort_order => 2
    TargetLabel.create! :label => "IVI", :normalized => "ivi", :sort_order => 3
    TargetLabel.create! :label => "SDK", :normalized => "sdk", :sort_order => 4
  end

  def self.down
    VersionLabel.find(:first, :conditions => {:label => "1.2"}).destroy
    VersionLabel.find(:first, :conditions => {:label => "1.1"}).destroy
    VersionLabel.find(:first, :conditions => {:label => "1.0"}).destroy

    TargetLabel.find(:first, :conditions => {:label => "Core"}).destroy
    TargetLabel.find(:first, :conditions => {:label => "Handset"}).destroy
    TargetLabel.find(:first, :conditions => {:label => "Netbook"}).destroy
    TargetLabel.find(:first, :conditions => {:label => "IVI"}).destroy
    TargetLabel.find(:first, :conditions => {:label => "SDK"}).destroy
  end

end

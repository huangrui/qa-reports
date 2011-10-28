class RenameHardwareAndTestypeDataCaseSensitively < ActiveRecord::Migration
  def self.up
    # a little house-keeping while we're at it
    MeegoTestSession.delete_all "published = false AND created_at < '#{Time.local 2011, 6, 28}'"

    hardware_mapping = {
      'ia aava' => 'IA-Aava',
      'ia-russellville' => 'IA-Russellville',
      'n900' => 'N900',
      'pinetrail' => 'Pinetrail',
      'netbook' => 'Netbook',
      'ivi' => 'IVI',
      'icdk' => 'iCDK',
      'ncdk' => 'nCDK',
      'handset' => 'Handset',
      'crownbay' => 'Crownbay',
      'netbook run_env' => 'Netbook run_env',
      'northville' => 'Northville',
      'n900ce' => 'N900CE',
      'crossville-st' => 'Crossville-ST',
      'ml7213' => 'ML7213',
      'crossville-oki' => 'Crossville-OKI',
      'tablet' => 'Tablet',
      'ubuntu 10,10 - x86' => 'Ubuntu 10,10 - x86',
      'n900-test' => 'N900-Test',
      'oaktrail' => 'Oaktrail',
      'ecs s10ot3' => 'ECS S10OT3',
      'pinetrail_tablet' => 'Pinetrail_Tablet',
      'exopc-all' => 'ExoPC-All',
      'netbook-all' => 'Netbook-All',
      'netbook-eeepc1005pe-all' => 'Netbook-EeePC1005PE-All',
      'tablet-exopc-all' => 'Tablet-ExoPC-All'
    }

    testtype_mapping = {
      'acceptance' => 'Acceptance',
      'sanity' => 'Sanity',
      'basic feature' => 'Basic Feature',
      'dataflow' => 'Dataflow',
      'sanity - automated' => 'Sanity - Automated',
      'sample report' => 'Sample Report',
      'nightly - automated' => 'Nightly - Automated',
      'system functional' => 'System Functional',
      'sanity:testing' => 'Sanity:testing',
      'extended feature' => 'Extended Feature',
      'key feature' => 'Key Feature',
      'hourly - automated' => 'Hourly - Automated',
      'nightly-automated' => 'Nightly - Automated',
      'installation' => 'Installation',
      'milestone' => 'Milestone',
      'functional' => 'Functional',
      'auto' => 'Auto',
    }

    # map unlisted hardwares as 'hardware name' => 'Hardware Name'
    unmapped_hardwares = MeegoTestSession.select('distinct hardware').where('hardware NOT IN (?)', hardware_mapping.keys).map &:hardware
    extra_mappings = Hash[ unmapped_hardwares.map {|hardware| [hardware.downcase, hardware.gsub(/\b\w/) { $&.upcase }] } ]
    hardware_mapping.merge! extra_mappings

    # map unlisted testtypes as 'testtype name' => 'Testtype Name'
    unmapped_testtypes = MeegoTestSession.select('distinct testtype').where('testtype NOT IN (?)', testtype_mapping.keys).map &:testtype
    extra_mappings = Hash[ unmapped_testtypes.map {|testtype| [testtype.downcase, testtype.gsub(/\b\w/) { $&.upcase }] } ]
    testtype_mapping.merge! extra_mappings

    # update to db

    hardware_mapping.each do |old_name, new_name|
      MeegoTestSession.update_all "hardware = '#{new_name}'", :hardware => old_name
    end

    testtype_mapping.each do |old_name, new_name|
      MeegoTestSession.update_all "testtype = '#{new_name}'", :testtype => old_name
    end
  end

  def self.down
    downcase_all :hardware
    downcase_all :testtype
  end

  def self.downcase_all(attribute)
    current = MeegoTestSession.select("distinct #{attribute}").map &attribute
    mappings = Hash[ current.map {|item| [item, item.downcase] } ]

    mappings.each do |old_name, new_name|
      MeegoTestSession.update_all "#{attribute} = '#{new_name}'", attribute => old_name
    end
  end
end

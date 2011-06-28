class RenameHardwareAndTestypeDataCaseSensitively < ActiveRecord::Migration
  def self.up
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

    # a little house-keeping while we're at it
    MeegoTestSession.delete_all "published = false AND created_at < '#{Time.local 2011, 6, 28}'"

    # process until no new reports were submitted while processing
    begin_time = Time.at 0

    while MeegoTestSession.where('created_at >= ?', begin_time).count > 0
      prev_time = begin_time
      begin_time = Time.now
      sessions = MeegoTestSession.where('created_at >= ?', prev_time)

      sessions.each do |session|
        hardware = session.hardware
        session.hardware = hardware_mapping[hardware.downcase] || hardware.gsub(/\b\w/) { $&.upcase }
        testtype = session.testtype
        session.testtype = testtype_mapping[testtype.downcase] || testtype.gsub(/\b\w/) { $&.upcase }
        session.save!
      end

    end
  end

  def self.down
    MeegoTestSession.all.each do |session|
      session.hardware.downcase!
      session.testtype.downcase!
      session.save!
    end
  end
end

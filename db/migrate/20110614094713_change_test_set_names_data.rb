class ChangeTestSetNamesData < ActiveRecord::Migration

  def self.up
    mappings = {
      'acceptance-auto-test' => {:test_set => 'Acceptance'},
      'acceptance for developer edition' => {:test_set => 'Acceptance', :hw_suffix => '_CE'},
      'basic feature testing' => {:test_set => 'Basic Feature'},
      'data flow for developer edition' =>  {:test_set => 'Dataflow', :hw_suffix => '_CE'},
      'de-feature' => {:test_set => 'Key Feature', :hw_suffix => '_CE'},
      'de-sanity' => {:test_set => 'Sanity', :hw_suffix => '_CE'},
      'full feature testing' =>  {:test_set => 'Extended Feature'},
      'fullpass' =>  {:test_set => 'Milestone'},
      'key basic feature' =>  {:test_set => 'Basic Feature'},
      'key basic feature for developer edition' =>  {:test_set => 'Basic Feature', :hw_suffix => '_CE'},
      'sanity-auto-test' => {:test_set => 'Sanity'},
      'sanity for developer edition' =>  {:test_set => 'Sanity', :hw_suffix => '_CE'},
      'system function' =>  {:test_set => 'System Functional'},
      'update system function' =>  {:test_set => 'System Functional'},
      'update sanity' =>  {:test_set => 'Sanity'},
      'updated sanity' =>  {:test_set => 'Sanity'},
      'use case testing for developer edition' =>  {:test_set => 'Key Feature', :hw_suffix => '_CE'},
      'winxp 32bit ia32 basic' =>  {:test_set => 'Basic Feature'}
    }

    MeegoTestSession.where(:testtype => mappings.keys).each do |s|
      mapping = mappings[s.testtype.downcase]
      s.testtype = mapping[:test_set]
      hw_suffix = mapping[:hw_suffix]
      s.hardware += hw_suffix unless hw_suffix.nil?
      s.save
    end

    MeegoTestSession.where(:hardware => 'N900de').each do |s|
      s.hardware = 'N900_CE'
      s.save
    end

    # Not to be processed:
    #'Sanity-automated'
    #'Sanity:testing'
    #'Sanity - automated'
    #'Hourly - automated'
    #'Nightly-automated'
    #'Sample report'
    #'Installation'
  end

  def self.down
  end
end

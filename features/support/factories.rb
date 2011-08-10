FactoryGirl.define do
  sequence :email do |n| 
    "john.longbottom#{n}@meego.com"
  end

  sequence :authentication_token do |n| 
    n.to_s
  end

  factory :user, :aliases => [:author, :editor] do
    name                  "John Longbottom"
    email
    password              "secret"
    password_confirmation "secret"
    authentication_token
  end

  factory :release, :class => VersionLabel, :aliases => [:version_label] do
    label      "1.3"
    normalized "1.3"
    sort_order  0
  end

  factory :feature do
    name "Bluetooth"
  end

  factory :test_case, :class => MeegoTestCase do
    name   "Bluetooth file transfer"
    result MeegoTestCase::PASS
  end

  factory :test_report, :class => MeegoTestSession do
    after_build { |report| FactoryGirl.build(:feature, :meego_test_session => report)}
    author
    editor
    version_label
    title           "N900 Test Report"
    target          "Handset"
    testset         "Acceptance"
    product         "N900"
    published       true
    tested_at       "2011-08-06"
    uploaded_files  "result.csv"
  end
end

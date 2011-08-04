Meegoqa::Application.routes.draw do
  devise_for :users, :controllers => { :sessions => "users/sessions" }  , :path_names => { :sign_up => "#{DeviseRegistrationConfig::URL_TOKEN}/register" }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  match '/upload_post' => 'upload#upload', :via => "post"
  match '/upload_report' => 'upload#upload_report', :via => "post"
  match '/upload_attachment' => 'upload#upload_attachment', :via => "post"

  match '/api/import' => 'api#import_data', :via => "post"
  match '/api/get_token' => 'api#get_token', :via => "get"
  match '/api/update/:id' => 'api#update_result', :via => "post"
  match '/api/reports' => 'api#reports_by_limit_and_time', :via => "get"

  match '/finalize' => 'reports#preview', :via => "get"
  match '/finalize/download' => 'csv_export#export_report', :via => "get"
  match '/publish' => 'reports#publish', :via => "post"

  match '/ajax_update_tested_at' => 'reports#update_tested_at', :via => "post"
  match '/ajax_update_txt' => 'reports#update_txt', :via => "post"
  match '/ajax_update_title' => 'reports#update_title', :via => "post"
  match '/ajax_update_comment' => 'meego_test_cases#update_case_comment', :via => "post"
  match '/ajax_update_result' => 'meego_test_cases#update_case_result', :via => "post"
  match '/ajax_remove_attachment' => 'reports#remove_attachment', :via => "post"
  match '/ajax_update_category' => 'reports#update_category', :via => "post"
  match '/ajax_remove_testcase' => 'reports#remove_testcase', :via => "post"
  match '/ajax_restore_testcase' => 'reports#restore_testcase', :via => "post"

  match '/fetch_bugzilla_data' => 'reports#fetch_bugzilla_data', :via => "get"
  match '/dashboard_export' => 'index#dashboard_export', :via => "get"

  # For submit the comments of features
  match '/ajax_update_feature_comment' => 'reports#update_feature_comment', :via => "post"

  # For submit the grading of features
  match '/ajax_update_feature_grading' => 'reports#update_feature_grading', :via => "post"

  # to test exception notifier
  match '/raise_exception' => 'exceptions#index' unless Rails.env.production?

  # Shortcut by report ID
  match '/reports/:id' => 'reports#redirect_by_id', :via => "get"

  match '/reports/:id/compare/:compare_id' => 'session_comparison#show', :via => "get", :as => :session_comparison

  # Constraint to allow a dot (.) in release vesion
  constraints(:release_version => /[a-zA-Z0-9._-]+/, :id => /[0-9]+/) do
    match '(/:release_version(/:target(/:testset(/:product))))/upload' => 'upload#upload_form', :via => "get", :as => :upload_form
    match '(/:release_version(/:target(/:testset(/:product))))/product' => 'products#index', :via => "get", :as => :products
    match '(/:release_version(/:target(/:testset(/:product))))/testset' => 'test_sets#index', :via => "get", :as => :test_types

    match '/:release_version/:target/:testset/:product/csv' => 'csv_export#export', :via => "get"
    match '/:release_version/:target/:testset/csv' => 'csv_export#export', :via => "get"
    match '/:release_version/:target/csv' => 'csv_export#export', :via => "get"

    match '/:release_version/:target/:testset/:product/rss' => 'rss#rss', :via => "get"
    match '/:release_version/:target/:testset/rss' => 'rss#rss', :via => "get"
    match '/:release_version/:target/rss' => 'rss#rss', :via => "get"
    match '/:release_version/rss' => 'rss#rss', :via => "get"

    match '/:release_version/:target/:testset/compare/:comparetestset' => 'comparison_reports#show', :via => "get", :as => :branch_comparison

    match '/:release_version/:target(/:testset(/:product))/report_list(/:page)' => 'report_groups#report_page', :via => "get", :as => :report_list

    match '/:release_version/:target/:testset/:product/:id' => 'reports#view', :via => "get"
    match '/:release_version/:target/:testset/:product/:id/edit' => 'reports#edit', :via => "get"
    match '/:release_version/:target/:testset/:product/:id/download' => 'csv_export#export_report', :via => "get"
    match '/:release_version/:target/:testset/:product/:id/delete' => 'reports#delete', :via => "post"
    match '/:release_version/:target/:testset/:product/:id/print' => 'reports#print', :via => "get"

    match '/:release_version' => 'index#index', :via => "get"

    match '/:release_version/:target' => 'report_groups#show', :via => "get", :as => :profile_report
    match '/:release_version/:target/:testset' => 'report_groups#show', :via => "get", :as => :testset_report
    match '/:release_version/:target/:testset/:product' => 'report_groups#show', :via => "get", :as => :product_report
  end


  root :to => "index#index"
end

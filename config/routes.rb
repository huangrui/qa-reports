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

  match '/finalize' => 'reports#preview', :via => "get"
  match '/finalize/download' => 'csv_export#export_report', :via => "get"
  match '/publish' => 'reports#publish', :via => "post"

  match '/ajax_update_tested_at' => 'reports#update_tested_at', :via => "post"

  match '/ajax_update_txt' => 'reports#update_txt', :via => "post"
  match '/ajax_update_title' => 'reports#update_title', :via => "post"
  match '/ajax_update_comment' => 'reports#update_case_comment', :via => "post"
  match '/ajax_update_result' => 'reports#update_case_result', :via => "post"
  match '/ajax_remove_attachment' => 'reports#remove_attachment', :via => "post"
  match '/ajax_update_category' => 'reports#update_category', :via => "post"
  
  match '/fetch_bugzilla_data' => 'reports#fetch_bugzilla_data', :via => "get"

  # For submit the comments of features
  match '/ajax_update_feature_comment' => 'reports#update_feature_comment', :via => "post"

  # For submit the grading of features
  match '/ajax_update_feature_grading' => 'reports#update_feature_grading', :via => "post"

  # to test exception notifier
  match '/raise_exception' => 'exceptions#index' unless Rails.env.production?

  

  # Constraint to allow a dot (.) in release vesion
  constraints(:release_version => /[a-zA-Z0-9._-]+/) do
    match '(/:release_version(/:target(/:testtype(/:hwproduct))))/upload' => 'upload#upload_form', :via => "get", :as => :upload_form
    match '(/:release_version(/:target(/:testtype(/:hwproduct))))/hardware' => 'hardwares#index', :via => "get", :as => :hardwares
    match '(/:release_version(/:target(/:testtype(/:hwproduct))))/testtype' => 'test_types#index', :via => "get", :as => :test_types
    

    match '/:release_version/:target/:testtype/:hwproduct/csv' => 'csv_export#export', :via => "get"
    match '/:release_version/:target/:testtype/csv' => 'csv_export#export', :via => "get"
    match '/:release_version/:target/csv' => 'csv_export#export', :via => "get"

    match '/:release_version/:target/:testtype/:hwproduct/rss' => 'rss#rss', :via => "get"
    match '/:release_version/:target/:testtype/rss' => 'rss#rss', :via => "get"
    match '/:release_version/:target/rss' => 'rss#rss', :via => "get"
    match '/:release_version/rss' => 'rss#rss', :via => "get"
    
    match '/:release_version/:target/:testtype/compare/:comparetype' => 'comparison_reports#show', :via => "get", :as => :comparison_report

    match '/:release_version/:target/:testtype/:hwproduct/:id' => 'reports#view', :via => "get"
    match '/:release_version/:target/:testtype/:hwproduct/:id/edit' => 'reports#edit', :via => "get"
    match '/:release_version/:target/:testtype/:hwproduct/:id/download' => 'csv_export#export_report', :via => "get"
    match '/:release_version/:target/:testtype/:hwproduct/:id/delete' => 'reports#delete', :via => "post"
    match '/:release_version/:target/:testtype/:hwproduct/:id/print' => 'reports#print', :via => "get"
    match '/:release_version/:target/:testtype/:hwproduct' => 'index#filtered_list', :via => "get", :as => :hardware_report
    match '/:release_version/:target/:testtype' => 'index#filtered_list', :via => "get", :as => :test_type_report
    match '/:release_version/:target' => 'index#filtered_list', :via => "get", :as => :profile_report
    match '/:release_version' => 'index#index', :via => "get"

    match '/:release_version/:target' => 'report_groups#show', :via => "get", :as => :profile_report
    match '/:release_version/:target/:testtype' => 'report_groups#show', :via => "get", :as => :test_type_report
    match '/:release_version/:target/:testtype/:hwproduct' => 'report_groups#show', :via => "get", :as => :hardware_report
  end


  root :to => "index#index"
end

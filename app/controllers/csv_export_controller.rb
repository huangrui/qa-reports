require 'csv_generator'

class CsvExportController < ApplicationController

  def export
    csv = CsvGenerator::generate_csv(
            VersionLabel.where(:normalized => @selected_release_version.downcase).first().id,
            params[:target],
            params[:testtype],
            params[:hwproduct]
    )

    send_data csv, :type => "text/plain", :filename=>"entries.csv", :disposition => 'attachment'
  end

  def export_report
    csv = CsvGenerator::generate_csv_report(
            VersionLabel.where(:normalized => @selected_release_version.downcase).first().id,
            params[:target],
            params[:testtype],
            params[:hwproduct],
            params[:id]
    )

    send_data csv, :type => "test/plain", :filename=>"report.csv", :disposition => 'attachment'
  end
end

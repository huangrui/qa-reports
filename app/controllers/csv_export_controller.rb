require 'csv_generator'

class CsvExportController < ApplicationController
  def export
    csv = CsvGenerator::generate_csv(
            release.name,
            params[:target],
            params[:testset],
            params[:product]
    )

    send_data csv, :type => "text/plain", :filename=>"entries.csv", :disposition => 'attachment'
  end

  def export_report
    csv = CsvGenerator::generate_csv_report(
            release.name,
            params[:target],
            params[:testset],
            params[:product],
            params[:id]
    )

    send_data csv, :type => "text/plain", :filename=>"report.csv", :disposition => 'attachment'
  end
end

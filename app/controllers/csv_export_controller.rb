require 'csv_generator'

class CsvExportController < ApplicationController
  def export
    csv = CsvGenerator::generate_csv(
            @selected_release_version,
            params[:target],
            params[:testtype],
            params[:hardware]
    )

    send_data csv, :type => "text/plain", :filename=>"entries.csv", :disposition => 'attachment'
  end

  def export_report
    csv = CsvGenerator::generate_csv_report(
            @selected_release_version,
            params[:target],
            params[:testtype],
            params[:hardware],
            params[:id]
    )

    send_data csv, :type => "test/plain", :filename=>"report.csv", :disposition => 'attachment'
  end
end

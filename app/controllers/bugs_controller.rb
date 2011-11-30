class BugsController < ApplicationController

  caches_action :fetch_bugzilla_data,
                :cache_path => Proc.new { |controller| controller.bugzilla_cache_key },
                :expires_in => 1.hour

  # Rui fetch API for bugzilla, and translate to JIRA
  def fetch_bugzilla_data
    ids       = params[:bugids]
    idss = ids[0].split(',')

    uris = []
    contents = []

    idss.each { |id| uris << (BUGZILLA_CONFIG['uri'] + id) }

    uris.each do |uri|
      content = ""
      if not BUGZILLA_CONFIG['proxy_server'].nil?
        @http = Net::HTTP.Proxy(BUGZILLA_CONFIG['proxy_server'], BUGZILLA_CONFIG['proxy_port']).new(BUGZILLA_CONFIG['server'], BUGZILLA_CONFIG['port'])
      else
        @http = Net::HTTP.new(BUGZILLA_CONFIG['server'], BUGZILLA_CONFIG['port'])
      end

      @http.use_ssl     = BUGZILLA_CONFIG['use_ssl']
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @http.start() do |http|
        req = Net::HTTP::Get.new(uri)
        if not BUGZILLA_CONFIG['http_username'].nil?
          req.basic_auth BUGZILLA_CONFIG['http_username'], BUGZILLA_CONFIG['http_password']
        end
        response = http.request(req)
        content = response.body
      end
      contents << content
    end

    # XXX: bugzilla seems to encode its exported csv to utf-8 twice
    # so we convert from utf-8 to iso-8859-1, which is then interpreted
    # as utf-8
    begin
      json = [["bug_id", "short_desc", "bug_status", "resolution"]]
      contents.each do |content|
        data = Iconv.iconv("iso-8859-1", "utf-8", content)
        pre_json = JSON.parse(data[0])
        unless pre_json["fields"]["resolution"].nil?
          json << [pre_json["key"], pre_json["fields"]["summary"]["value"], pre_json["fields"]["status"]["value"]["name"], pre_json["fields"]["resolution"]["value"]["name"]]
        else
          json << [pre_json["key"], pre_json["fields"]["summary"]["value"], pre_json["fields"]["status"]["value"]["name"], "Unresolved"]
        end
      end
      # TODO: Should render json instead of CSV
      render :json => json
    rescue FasterCSV::MalformedCSVError => e
      logger.error e.message
      logger.info  "ERROR: MALFORMED BUGZILLA DATA"
      logger.info  data
      head :not_found
    end
  end

  protected

  def bugzilla_cache_key
    h = Digest::SHA1.hexdigest params.to_hash.to_a.map{|k,v| if v.respond_to?(:join) then k+v.join(",") else k+v end}.join(';')
    "bugzilla_#{h}"
  end

end

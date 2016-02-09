module Puppet::Parser::Functions
  newfunction(:get_app_version_info, :type => :rvalue) do |args|
    application_name = args[0]
    version          = args[1]
    pkg_type         = args[2]
    distribution     = args[3]
    username         = args[4]
    api_key          = args[5]

    require "net/https"
    require "uri"

    BASE_URL = "https://api.releasequeue.com"
    SERVER_PORT = 443

    uri = URI.parse("#{BASE_URL}/users/#{username}/applications/#{application_name}/versions/#{version}")
    http = Net::HTTP.new(uri.host, SERVER_PORT)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Authorization"] = "Bearer #{api_key}"
    response = http.request(request)
    if response.code != "200"
      raise "Error code received from RQ server for #{uri}: #{response.code} \n#{response.body}"
    end

    json = JSON.parse(response.body)

    repos = json["repositories"][pkg_type]
    dist_name = distribution.gsub(/\s+/, "").downcase()
    repos = repos.select{|repo| dist_name.include?(repo["distribution"].gsub(/\s+/, "").downcase()) }

    if repos.empty?
      raise "No distribution '#{distribution}' configured for application #{application_name} #{version}"
    else
      repo = repos[0]
      repo["components_joined"] = repo["components"].join(" ")
      esc_url = repo['url'].sub('https://', "https://#{api_key}@")
      repo["urls"] = repo["components"].map{ |comp| "#{esc_url}/#{repo['distribution']}/#{comp}"}
      return repos[0]
    end

  end
end

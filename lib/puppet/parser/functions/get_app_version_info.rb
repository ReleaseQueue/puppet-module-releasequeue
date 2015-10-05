module Puppet::Parser::Functions
  newfunction(:get_app_version_info, :type => :rvalue) do |args|
    application_name = args[0]
    version          = args[1]
    pkg_type         = args[2]
    distribution     = args[3]
    email            = args[4]
    password         = args[5]
    #raise(Puppet::ParseError, "Error in get_app_version_info #{email} #{password}")

    require "net/https"
    require "uri"

    BASE_URL = "https://api.releasequeue.com"

    uri = URI.parse("#{BASE_URL}/signin")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"email" => email, "password" => password})
    begin
      response = http.request(request)
    rescue
      return []
    end

    if response.code != "200"
      raise "Error code received from RQ server for #{uri}: #{response.code} \n#{response.body}"
    end

    json = JSON.parse(response.body)
    token = json["token"]
    username = json["username"]

    uri = URI.parse("#{BASE_URL}/users/#{username}/applications/#{application_name}/versions/#{version}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request["x-auth-token"] = token
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
      esc_email = CGI::escape(email)
      esc_password = CGI::escape(password)
      esc_url = repo['url'].sub('https://', "https://#{esc_email}:#{esc_password}@")
      repo["urls"] = repo["components"].map{ |comp| "#{esc_url}/#{repo['distribution']}/#{comp}"}
      return repos[0]
    end

  end
end

class App
  HOST = "http://s3.amazonaws.com%s"

  def self.call(env)
    @env = env
    request_file
    file_retrieved? ? success : failure
  end

  def self.request_file
    url = URI.parse(HOST % @env["PATH_INFO"])
    @request = Net::HTTP::Get.new(url.path)
    @response = Net::HTTP.start(url.host, url.port) {|http| http.request(@request) }
  end

  def self.file_retrieved?
    @response.code == "200"
  end

  def self.success
    [200, {"Content-Type" => mime_type, 'Cache-Control' => "max-age=#{duration_in_seconds}, public", 'Expires' => duration_in_words}, [@response.body]]
  end

  def self.mime_type
    MIME::Types.type_for(@env["PATH_INFO"]).first.simplified
  end

  def self.failure
    [404, {"Content-Type" => "text/html"}, ["Not Found"]]
  end

  def self.duration_in_words
    (Time.now + self.duration_in_seconds).strftime '%a, %d %b %Y %H:%M:%S GMT'
  end

  def self.duration_in_seconds
    60 * 60 * 24 * 365
  end
end
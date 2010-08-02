class App
  def initialize(host)
    @host = host
  end

  def call(env)
    @env = env
    request_file
    file_retrieved? ? success : failure
  end

  def request_file
    url = URI.parse([@host, @env["PATH_INFO"]].join(""))
    @request = Net::HTTP::Get.new(url.path)
    @response = Net::HTTP.start(url.host, url.port) {|http| http.request(@request) }
  end

  def file_retrieved?
    @response.code == "200"
  end

  def success
    [200, {"Content-Type" => mime_type, 'Cache-Control' => "max-age=#{duration_in_seconds}, public", 'Expires' => duration_in_words}, [@response.body]]
  end

  def mime_type
    MIME::Types.type_for(@env["PATH_INFO"]).first.simplified
  end

  def failure
    [404, {"Content-Type" => "text/html"}, ["Not Found"]]
  end

  def duration_in_words
    (Time.now + duration_in_seconds).strftime '%a, %d %b %Y %H:%M:%S GMT'
  end

  def duration_in_seconds
    60 * 60 * 24 * 365
  end
end
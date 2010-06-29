class App
  HOST = "http://tjsingleton.name%s"

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

  def self.body
    head? ? "" : @response.body
  end

  def self.head?
    @env["REQUEST_METHOD"] == "HEAD"
  end

  def self.success
    [200, {"Content-Type" => mime_type}, [body]]
  end

  def self.mime_type
    MIME::Types.type_for(@env["PATH_INFO"]).first.simplified
  end

  def self.failure
    [404, {"Content-Type" => "text/html"}, ["Not Found"]]
  end
end
require "rack"

module Qdocs
  class Server
    def call(env)
      req = Rack::Request.new(env)
      params = req.params
      case env["REQUEST_PATH"]
      when "/"
        body = JSON.pretty_generate(Qdocs.lookup(params["input"]))
        [200, { "Content-Type" => "application/json; charset=utf-8" }, [body]]
      else
        [404, { "Content-Type" => "text/html; charset=utf-8" }, ["Not Found"]]
      end
    rescue => e
      [500, { "Content-Type" => "text/html; charset=utf-8" }, ["Error: #{e.message}"]]
    end
  end
end

handler = Rack::Handler::WEBrick

handler.run Qdocs::Server.new

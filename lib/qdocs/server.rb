require "rack"
require "pathname"

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

  def self.load_env(dir_level = nil)
    check_dir = dir_level || ["."]
    project_top_level = Pathname(File.join(*check_dir, "Gemfile")).exist? ||
      Pathname(File.join(*check_dir, ".git")).exist?
    if project_top_level && Pathname(File.join(*check_dir, "config", "environment.rb")).exist?
      require File.join(*check_dir, "config", "environment.rb")
    elsif project_top_level
      # no op - no env to load
    else
      dir_level ||= []
      dir_level << ".."
      Qdocs.load_env(dir_level)
    end
  end

  load_env
end

handler = Rack::Handler::WEBrick

handler.run Qdocs::Server.new, Port: 7593 # random port, not common 8080

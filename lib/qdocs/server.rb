require "rack"

module Qdocs
  class Server
    def call(env)
      req = Rack::Request.new(env)
      params = req.params
      case env["REQUEST_PATH"]
      when "/"
        resp = Qdocs.lookup(params["input"])
        # this is a bit ugly but ok 🤷
        format = req.env.fetch("HTTP_ACCEPT", "")
        body, content_type = case format
          when %r{text/html}
            require "erb"
            template = case resp[:query_type]
              when :methods
                "constant/show"
              when :instance_method, :singleton_method, :class_method, :method
                "method/show"
              when :active_record_attribute
                "method/active_record_show"
              when :constant, :active_record_class
                "constant/show"
              end
            [render_html(resp, template), "text/html"]
          else
            [JSON.pretty_generate(resp), "application/json"]
          end
        [200, { "Content-Type" => "#{content_type}" }, [body]]
      else
        [404, { "Content-Type" => "text/plain; charset=utf-8" }, ["Not Found"]]
      end
    rescue Qdocs::UnknownClassError,
           Qdocs::UnknownMethodTypeError,
           Qdocs::UnknownMethodError,
           Qdocs::UnknownPatternError => e
      [404, { "Content-Type" => "text/plain; charset=utf-8" }, ["Not found: #{e.message}"]]
    rescue => e
      p e.backtrace
      [500, { "Content-Type" => "text/plain; charset=utf-8" }, ["Error: #{e.message}"]]
    end

    private

    def render_html(resp, template)
      layout_contents = File.read(
        File.join(
          __dir__,
          "..",
          "views",
          "common.html.erb"
        )
      )
      specific_contents = File.read(
        File.join(
          __dir__,
          "..",
          "views",
          "#{template}.html.erb"
        )
      )
      @resp, @const_name = resp, resp.dig(:constant, :name)
      @specific_contents = ERB.new(specific_contents).result(binding)
      ERB.new(layout_contents).result(binding)
    end
  end
end

handler = Rack::Handler::WEBrick

handler.run Qdocs::Server.new, Port: 7593 # random port, not common 8080

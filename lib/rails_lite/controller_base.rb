require 'erb'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = "")
    @req = req
    @res = res
    session
    @params = Params.new(@req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    # Prevent double rendering
    unless @response_built
      @res.status = 302
      @res.header['location'] = url
      @response_built = true
    end
    @session.store_session(@res)
  end

  def render_content(content, type)
    # Prevent double rendering
    unless already_rendered?
      @res.body = content
      @res.content_type = type
      @already_rendered = true
    end
    @session.store_session(@res)
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    template_file = File.read("views/#{controller_name}/#{template_name}.html.erb")
    x = ERB.new(template_file).result(binding)
    render_content(x, "text/html")
  end

  def invoke_action(name)
    send(name) || render(name)
  end
end

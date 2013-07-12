require 'json'
require 'webrick'

class Session
  def initialize(req)
    cookie_value = nil
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        cookie_value = cookie.value
      end
    end
    @cookie = cookie_value ? JSON.parse(cookie_value) : {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app", @cookie.to_json)
  end
end

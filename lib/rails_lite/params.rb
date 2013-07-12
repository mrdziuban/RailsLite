require 'uri'

class Params
  def initialize(req, route_params)
    @params ||= {}
    p parse_www_encoded_form(req.body.to_s) if req.body
    @params.merge!(parse_www_encoded_form(req.body.to_s)) if req.body
    @params.merge!(parse_www_encoded_form(req.query_string.to_s)) if req.query_string
    @params.merge!(parse_www_encoded_form(route_params)) if route_params
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    p www_encoded_form
    new_hash = {}
    arr = URI.decode_www_form(www_encoded_form)
    arr.each do |x|
      new_hash[x[0]] = x[1]
    end
    new_hash
  end

  def parse_key(key)

  end
end

require 'uri'

class Params
  def initialize(req, route_params)
    @params ||= route_params
    @params.merge!(parse_www_encoded_form(req.body.to_s)) if req.body
    @params.merge!(parse_www_encoded_form(req.query_string.to_s)) if req.query_string
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    new_hash = {}
    arr = URI.decode_www_form(www_encoded_form)
    arr.each do |x|
      new_hash[x[0]] = x[1]
    end

    values, keys = new_hash.values, new_hash.keys

    arr = []
    keys.each do |key|
      arr << parse_key(key)
    end

    create_hash(arr, values)
  end

  def parse_key(key)
    key_array = []
    key_match = /(?<head>.*)\[(?<rest>.*)\]/.match(key)

    return [key] if key_match.nil?

    head, rest = key_match["head"], key_match["rest"]

    key_array.unshift(rest)

    x = parse_key(head)
    key_array.unshift(x)

    key_array.flatten
  end

  def create_hash(key_arr, values)
    full_hash = {}
    nested_hash = {}
    key_arr.each_with_index do |inner_arr, j|
      inner_arr.length.times do |i|
        if inner_arr[i] == inner_arr.first
          full_hash[inner_arr[i]] ||= {}
          nested_hash = full_hash[inner_arr[i]]
        elsif inner_arr[i] == inner_arr.last  
          nested_hash[inner_arr[i]] = values[j]
        else  
          nested_hash[inner_arr[i]] ||= {}
          nested_hash = nested_hash[inner_arr[i]] 
        end
      end  
    end
    full_hash
  end
end

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
    decoded_arr = URI.decode_www_form(www_encoded_form)
    decoded_arr.each do |x|
      new_hash[x[0]] = x[1]
    end

    values, keys = new_hash.values, new_hash.keys

    key_arr = []
    keys.each do |key|
      key_arr << parse_key(key)
    end

    create_hash(key_arr, values)
  end

  # Returns an array of the path of keys in a nested hash
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

  # Takes an array of arrays (each inner array comes from #parse_key)
  # and creates a nested hash in the format {key1 => {key2 => {key3 => value}}}
  # rather than the format {key1[key2][key3] => value}
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

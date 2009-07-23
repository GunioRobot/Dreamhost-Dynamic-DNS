#!/usr/local/bin/ruby

%w[rubygems net/http net/https uuid].each { |x| require x}

class DreamhostDynamicDNS
  
  attr_accessor :api_key,
                :uuid,
                :url
  
  def initialize(key = nil)
    @api_key = key
    @uuid = generate_uuid
    @host = "https://api.dreamhost.com/?key=#{@api_key}&format=json"
    @url = URI.parse(@host)
  end
  
  def list_entries()
    http = Net::HTTP.new(@url.host, @url.port)
    http.use_ssl = (@url.scheme == 'https')
	  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  @uuid = generate_uuid
    data = [@url.query, "cmd=dns-list_records","unique_id=#{@uuid}"].join("&")
    resp, data = http.post(@url.path, data)
    puts 'Code = ' + resp.code
    puts 'Message = ' + resp.message
    resp.each {|key, val| puts key + ' = ' + val}
    puts resp.body
  end
  
  def add_entry(record=nil, type=nil, value=nil, comment=nil)
    unless(record)
      return "Please enter a valid record. ex: www.example.com"
    end
    unless(type)
      return "Please enter a valid DNS type. ex: A, CNAME, MX, NS"
    end
    unless(value)
      return "Please enter a valid DNS value. For example if type is a \"A\" then 192.168.0.1 would be the value."
    end               
   http = Net::HTTP.new(@url.host, @url.port)
   http.use_ssl = (@url.scheme == 'https')
   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   @uuid = generate_uuid
   data = [@url.query, "cmd=dns-add_record","record=#{record}","type=#{type}","value=#{value}","comment=#{comment}","unique_id=#{@uuid}"].join("&")
   resp, data = http.post(@url.path, data)
   puts 'Code = ' + resp.code
   puts 'Message = ' + resp.message
   resp.each {|key, val| puts key + ' = ' + val}
   resp.body
  end
  
  def delete_entry(record=nil, type=nil, value=nil)
    unless(record)
      return "Please enter a valid record. ex: www.example.com"
    end
    unless(type)
      return "Please enter a valid DNS type. ex: A, CNAME, MX, NS"
    end
    unless(value)
      return "Please enter a valid DNS value. For example if type is a \"A\" then 192.168.0.1 would be the value."
    end
    http = Net::HTTP.new(@url.host, @url.port)
    http.use_ssl = (@url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @uuid = generate_uuid
    data = [@url.query, "cmd=dns-remove_record","record=#{record}","type=#{type}","value=#{value}","unique_id=#{@uuid}"].join("&")
    resp, data = http.post(@url.path, data)
    puts 'Code = ' + resp.code
    puts 'Message = ' + resp.message
    resp.each {|key, val| puts key + ' = ' + val}
    resp.body
  end
  
  def edit_entry(record=nil, type=nil, value=nil, comment=nil)
    unless(record)
      return "Please enter a valid record. ex: www.example.com"
    end
    unless(type)
      return "Please enter a valid DNS type. ex: A, CNAME, MX, NS"
    end
    unless(value)
      return "Please enter a valid DNS value. For example if type is a \"A\" then 192.168.0.1 would be the value."
    end
    delete_entry(record, type, value)
    add_entry(record, type, value, comment)
  end
  
  def generate_uuid
    uuid = UUID.new
    uuid.generate
  end
	
end


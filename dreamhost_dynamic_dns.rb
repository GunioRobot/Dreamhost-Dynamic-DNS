#!/usr/local/bin/ruby

%w[rubygems net/http net/https uuid open-uri].each { |x| require x}

class DreamhostDynamicDNS
  
  attr_accessor :api_key,
                :uuid,
                :url,
                :format,
                :ipaddress
  
  def initialize(key = nil)
    @api_key = key
    @uuid = generate_uuid
    @format = "json"
    @ipaddress = get_ipaddress
    @host = "https://api.dreamhost.com/?key=#{@api_key}&format=#{@format}"
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
      puts "If no value is specified the default IP ADDRESS will be your current NAT IP #{@ipaddress}"
      value = @ipaddress
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
  
  def get_ipaddress
    open("http://whatismyip.com/") { |f| /([0-9]{1,3}\.){3}[0-9]{1,3}/.match(f.read)[0].to_a[0] }
  end
	
end


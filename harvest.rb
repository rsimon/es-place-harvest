require "json"
require "net/http"
require "uri"

PAGE_SIZE = 1

def parse_response(response)
  if response.code == "200"
    result = JSON.parse(response.body)
    scroll_id = result["_scroll_id"]
    result["hits"]["hits"].each do |hit|
      # puts hit["title"]
      #puts "----------------"
    end

    return scroll_id
  else
    puts "ERROR!!!"
  end
end

def fetch_inital
  uri = URI.parse("http://localhost:9200/peripleo/_search?q=item_type:PLACE&size=#{PAGE_SIZE}&scroll=1m")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  parse_response(http.request(request))
end

def fetch_next(id)
  uri = URI.parse("http://localhost:9200/peripleo/_search/scroll")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri, 'Content-Type' => 'application/json')
  request.body = "{ \"scroll\" : \"1m\", \"_scroll_id\" : \"#{id}\" }"
  response = http.request(request)

  puts response
end

scroll_id = fetch_inital()
puts scroll_id
fetch_next(scroll_id)

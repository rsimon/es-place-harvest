require "json"
require "net/http"
require "uri"

PAGE_SIZE = 200

def parse_response(response)
  if response.code == "200"
    result = JSON.parse(response.body)
    scroll_id = result["_scroll_id"]
    result["hits"]["hits"].each do |hit|
      # TODO title, geometry, identifier, match uris, names
      # TODO write to file
      source = hit["_source"]
      puts source["title"]
    end

    if result["hits"]["hits"].length >= PAGE_SIZE
      return scroll_id
    end
  else
    puts "-- ERROR --"
  end
end

def fetch_inital
  uri = URI.parse("http://localhost:9200/peripleo/_search?q=item_type:PLACE&size=#{PAGE_SIZE}&scroll=1m")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  parse_response(http.request(request))
end

def fetch_next(id)
  uri = URI.parse("http://localhost:9200/_search/scroll")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
  request.body = "{ \"scroll\" : \"1m\", \"scroll_id\" : \"#{id}\" }"
  parse_response(http.request(request))
end

scroll_id = fetch_inital()

while not scroll_id.to_s.empty? do
  scroll_id = fetch_next(scroll_id)
end

puts 'Done.'

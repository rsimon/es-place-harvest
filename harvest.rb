require "json"
require "net/http"
require "uri"

def fetch_inital
  uri = URI.parse("http://localhost:9200/peripleo/_search?q=item_type:PLACE&size=200&scroll=1m")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  if response.code == "200"
    result = JSON.parse(response.body)
    scroll_id = result["_scroll_id"]
    result["hits"]["hits"].each do |hit|
      #puts hit
      #puts "----------------"
    end

    return scroll_id
  else
    puts "ERROR!!!"
  end

end

def fetch_next(id)
  uri = URI.parse("http://localhost:9200/peripleo/_search/scroll?scroll=1m&scroll_id=#{id}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
end

scroll_id = fetch_inital()
fetch_next(scroll_id)

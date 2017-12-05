require "json"
require "net/http"
require "uri"

uri = URI.parse("http://localhost:9200/peripleo/_search?q=item_type:PLACE&size=200&scroll=1m")

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

if response.code == "200"
  result = JSON.parse(response.body)
  scroll_id = result["scroll_id"]
  result["hits"]["hits"].each do |hit|
    puts hit
    puts "----------------"
  end

else
  puts "ERROR!!!"
end

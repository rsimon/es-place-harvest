require "date"
require "json"
require "net/http"
require "uri"

PAGE_SIZE = 200
OUT_FILE  = "data/places.json"

def write_one(place)

  # Shorthand
  def flat_map(place, key)
    place["is_conflation_of"].flat_map { |r| r[key] }.compact
  end

  def addIfDefined(prop, key, record)
    if not prop == nil
      record[key] = prop
    end
  end

  # TODO don't write places that are GeoNames only

  identifiers  = flat_map(place, "identifiers")
  names        = flat_map(place, "names")
  descriptions = flat_map(place, "descriptions")
  depictions   = flat_map(place, "depictions")

  temp_bounds = place["temporal_bounds"]
  from_year = Date.parse(temp_bounds["from"]).year unless temp_bounds == nil
  to_year = Date.parse(temp_bounds["to"]).year unless temp_bounds == nil

  record = {
    type: "Feature",
    geometry: place["representative_geometry"],
    properties: {
      title: place["title"],
      peripleo_view: "http://peripleo.pelagios.org/ui#selected=#{URI.encode(identifiers.first)}"
    },
    title: place["title"],
    identifiers: identifiers
  }

  addIfDefined(temp_bounds,  :temporal_bounds, record)
  addIfDefined(names,        :names,           record)
  addIfDefined(descriptions, :descriptions,    record)

  addIfDefined(from_year,   :from_year, record[:properties])
  addIfDefined(to_year,     :to_year,   record[:properties])

  if depictions.length > 0
    record[:depictions] = depictions.map { |d| d.url }
  end

  # TODO external_links

  # TODO don't write records with geometry == nil?

  # TODO don't append comma for last record
  open(OUT_FILE, 'a') { |f| f.puts "#{record.to_json}," }
end

def parse_response(response)
  if response.code == "200"
    result = JSON.parse(response.body)
    scroll_id = result["_scroll_id"]
    result["hits"]["hits"].each { |hit| write_one(hit["_source"]) }

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

def init_file
  File.delete(OUT_FILE) if File.exist?(OUT_FILE)
  open(OUT_FILE, 'a') do |f|
    f.puts '{ "type": "FeatureCollection",'
    f.puts '  "features": ['
  end
end

def close_file
  open(OUT_FILE, 'a') do |f|
    f.puts '  ]'
    f.puts '}'
  end
end

###
# Scrolls through ElasticSearch place items and writes a GeoJSON FeatureCollection as output
###
init_file()

scroll_id = fetch_inital()

while not scroll_id.to_s.empty? do
  scroll_id = fetch_next(scroll_id)
end

close_file()

puts 'Done.'

PAGE_SIZE  = 200
OUT_FILE   = "data/places.json"

# TODO MAX_NUM_RECORDS parameter

require "date"
require "json"
require "net/http"
require "uri"

def write_one(place, is_last)

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

  temp_bounds  = place["temporal_bounds"]
  from_year    = Date.parse(temp_bounds["from"]).year unless temp_bounds == nil
  to_year      = Date.parse(temp_bounds["to"]).year unless temp_bounds == nil

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

  if is_last
    open(OUT_FILE, 'a') { |f| f.puts "    #{record.to_json}" }
  else
    open(OUT_FILE, 'a') { |f| f.puts "    #{record.to_json}," }
  end
end

def parse_response(response)
  if response.code == "200"
    result = JSON.parse(response.body)
    scroll_id = result["_scroll_id"]
    hits = result["hits"]["hits"]
    is_last_page = hits.length < PAGE_SIZE

    hits.each_with_index do |hit, idx|
      is_last = is_last_page && (idx == hits.length - 1)
      write_one(hit["_source"], is_last)
    end

    if not is_last_page
      scroll_id
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

# Scrolls through ElasticSearch place items and writes a GeoJSON FeatureCollection as output
def run!

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

  init_file()
  scroll_id = fetch_inital()

  while not scroll_id.to_s.empty? do
    scroll_id = fetch_next(scroll_id)
  end

  close_file()
  puts 'Done.'
end

run! if __FILE__==$0

# Page size used for ElasticSearch scrolling
PAGE_SIZE   = 200

# Output file to write to
OUT_FILE    = "data/places.json"

# Maximum number for records to write to the file
MAX_RECORDS = 30000

# ElasticSearch REST port number
ES_PORT = 9200

require "date"
require "json"
require "net/http"
require "uri"

@record_count = 0

def write_one(place, is_last)

  def flat_map(place, key)
    place["is_conflation_of"].flat_map { |r| r[key] }.compact
  end

  def add_if_defined(prop, key, record)
    if not prop == nil
      record[key] = prop
    end
  end

  def get_dare_title(place)
    dare = place["is_conflation_of"].find { |r| r["uri"].include? "dare.ht.lu.se" }
    if (dare)
      dare["title"]
    end
  end

  identifiers  = flat_map(place, "identifiers")
  is_geonames_only = (identifiers.size == 1) && identifiers.first.include?("geonames.org")

  # By convention, we skip all records that are GeoNames only, or have null geometry
  if is_geonames_only || place["representative_geometry"] == nil
    return
  end

  names        = flat_map(place, "names")
  descriptions = flat_map(place, "descriptions")
  depictions   = flat_map(place, "depictions")

  temp_bounds  = place["temporal_bounds"]
  from_year    = Date.parse(temp_bounds["from"]).year unless temp_bounds == nil
  to_year      = Date.parse(temp_bounds["to"]).year unless temp_bounds == nil

  links        = flat_map(place, "links")
  link_uris    = links.map { |l| l["uri"] } if links

  # Prefer DARE titles.
  # Simple rule, but should be enough to eliminate all "Untitled" titles from Pleiades
  # where a DARE equivalent exists
  dare_title   = get_dare_title(place)
  title        = (dare_title) ? dare_title : place["title"]

  record = {
    type: "Feature",
    identifiers: identifiers,
    geometry: place["representative_geometry"],
    properties: {
      title: title,
      peripleo_view: "http://peripleo.pelagios.org/ui#selected=#{URI.encode(identifiers.first)}"
    },
    title: place["title"]
  }

  add_if_defined(temp_bounds,  :temporal_bounds, record)
  add_if_defined(names,        :names,           record)
  add_if_defined(descriptions, :descriptions,    record)

  add_if_defined(from_year,   :from_year, record[:properties])
  add_if_defined(to_year,     :to_year,   record[:properties])

  if depictions.length > 0
    record[:depictions] = depictions.map { |d| d["url"] }
  end

  if link_uris
    record[:external_links] = link_uris - identifiers
  end

  if is_last
    open(OUT_FILE, 'a') { |f| f.puts "    #{record.to_json}" }
  else
    open(OUT_FILE, 'a') { |f| f.puts "    #{record.to_json}," }
  end

  @record_count += 1
end

def parse_response(response)
  if response.code == "200"
    result = JSON.parse(response.body)
    scroll_id = result["_scroll_id"]
    hits = result["hits"]["hits"]
    is_last_page = hits.length < PAGE_SIZE

    hits.each_with_index do |hit, idx|
      is_last = (is_last_page && (idx == hits.length - 1)) || @record_count == MAX_RECORDS - 1
      if @record_count < MAX_RECORDS
        write_one(hit["_source"], is_last)
      end
    end

    if not is_last_page
      scroll_id
    end
  else
    puts "-- ERROR --"
  end
end

def fetch_inital
  uri = URI.parse("http://localhost:#{ES_PORT}/peripleo/_search?q=item_type:PLACE&size=#{PAGE_SIZE}&scroll=1m")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  parse_response(http.request(request))
end

def fetch_next(id)
  uri = URI.parse("http://localhost:#{ES_PORT}/_search/scroll")
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

  until scroll_id.to_s.empty? || @record_count == MAX_RECORDS do
    scroll_id = fetch_next(scroll_id)
  end

  close_file()
  puts "Done. Wrote #{@record_count} records"
end

run! if __FILE__==$0

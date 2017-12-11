# Peripleo ElasticSearch Place Harvest Script

A simple Ruby script to harvest all the places from the Peripleo ElasticSearch index, and
generate a single (big) GeoJSON FeatureCollection.

## Usage

1. make sure the ElasticSearch index is running
2. run `ruby harvest.rb`
3. wait

## Output Format

The output is a single FeatureCollection with Feature objects such as this

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [ -2.58024, 53.39254 ]
  },
  "properties": {
    "title": "Warrington",
    "from_year": -750,
    "to_year": 640,
    "peripleo_view": "http://peripleo.pelagios.org/ui#selected=http%3A%2F%2Fsws.geonames.org%2F2634739"
  },
  "title": "Warrington",
  "identifiers": [ "http://sws.geonames.org/2634739" ],
  "temporal_bounds": {"from":"-0750-01-01", "to":"0640-01-01"},
  "names":[  
     {  
        "name":"Warrington",
        "language":"DE"
     },
     {  
        "name":"Warrington",
        "language":"EN"
     },
     {  
        "name":"Warrington",
        "language":"FR"
     },
     {  
        "name":"Уоррингтон",
        "language":"RU"
     }
  ],
  "descriptions":[
    {
      "description": "A place.",
      "language": "EN"
    }
  ],
  "depictions": [ "http://www.example.com/photo.jpg" ],
  "external_links": [
    "https://en.wikipedia.org/wiki/Warrington",
    "http://www.wikidata.org/entity/Q215733"
  ]
}
```

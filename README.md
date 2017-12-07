# Peripleo ElasticSearch Place Harvest Script

A simple Ruby script to harvest all the places from the Peripleo ElasticSearch index, and
generate a single (big) GeoJSON FeatureCollection.

__Work in progress!__

## Usage

1. make sure the ElasticSearch index is running
2. run `ruby harvest.rb`
3. wait

## Output Format

The desired output format is a single FeatureCollection with Feature objects such as this

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

## Example ElasticSearch Record

```json
{  
   "doc_id":"45ed8835-80b6-4281-adf0-03244eefb441",
   "item_type":[  
      "PLACE"
   ],
   "title":"Warrington",
   "representative_geometry":{  
      "type":"Point",
      "coordinates":[  
         -2.58024,
         53.39254
      ]
   },
   "representative_point":[  
      -2.58024,
      53.39254
   ],
   "bbox":{  
      "type":"envelope",
      "coordinates":[  
         [  
            -2.58024,
            53.39254
         ],
         [  
            -2.58024,
            53.39254
         ]
      ]
   },
   "is_conflation_of":[  
      {  
         "uri":"http://sws.geonames.org/2634739",
         "identifiers":[  
            "http://sws.geonames.org/2634739"
         ],
         "last_synced_at":"2017-11-29T12:25:18+00:00",
         "title":"Warrington",
         "is_in_dataset":{  
            "root":"geonames\u0007geonames",
            "paths":[  
               "geonames\u0007geonames"
            ],
            "ids":[  
               "geonames"
            ]
         },
         "languages":[  
            "DE",
            "EN",
            "FR",
            "RU",
            "ZH"
         ],
         "geometry":{  
            "type":"Point",
            "coordinates":[  
               -2.58024,
               53.39254
            ]
         },
         "representative_point":[  
            -2.58024,
            53.39254
         ],
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
         ]
      }
   ],
   "suggest":{  
      "input":[  
         "Warrington",
         "Warrington",
         "Warrington",
         "Warrington",
         "Уоррингтон",
         "沃灵顿"
      ],
      "output":"Warrington",
      "payload":{  
         "identifier":"http://sws.geonames.org/2634739",
         "type":[  
            "PLACE"
         ]
      }
   }
}
```

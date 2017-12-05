curl "http://localhost:9200/peripleo/_search?pretty&size=1&q=item_type:PLACE&scroll=1m"

---

curl -XGET 'localhost:9200/twitter/tweet/_search?scroll=1m' -d '
{
    "query": {
        "match" : {
            "title" : "elasticsearch"
        }
    }
}
'
The result from the above request includes a _scroll_id, which should be passed to the scroll API in order to retrieve the next batch of results.

curl -XGET  'localhost:9200/_search/scroll'  -d'
{
    "scroll" : "1m", 
    "scroll_id" : "c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1" 
}
'

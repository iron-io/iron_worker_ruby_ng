import httplib
import json
import logging
import socket
import time
import urllib
SEARCH_HOST="search.twitter.com"
SEARCH_PATH="/search.json"

def search(query):
        c = httplib.HTTPConnection(SEARCH_HOST)
        params = {'q' : query}
        path = "%s?%s" %(SEARCH_PATH, urllib.urlencode(params))
        try:
            c.request('GET', path)
            r = c.getresponse()
            data = r.read()
            c.close()
            try:
                result = json.loads(data)
            except ValueError:
                return None
            if 'results' not in result:
                return None
            return result['results']
        except (httplib.HTTPException, socket.error, socket.timeout), e:
            logging.error("search() error: %s" %(e))
            return None

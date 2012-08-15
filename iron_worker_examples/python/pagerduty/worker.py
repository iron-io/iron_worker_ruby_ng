import argparse
import json
import httlib
import json
import logging
import socket
import time
import urllib

SEARCH_HOST="search.twitter.com"
SEARCH_PATH="/search.json"

parser = argparse.ArgumentParser(
        description="Calculates the Fibonacci sequence up to a maximum number")
parser.add_argument("-payload", type=str, required=False,
        help="The location of a file containing a JSON payload.")
args = parser.parse_args()

pd = False
if args.payload is not None:
    payload = json.loads(open(args.payload).read())
    if 'query' in payload:
        query = payload['query']

def search(query):
        c = httplib.HTTPConnection(SEARCH_HOST)
        params = {'q' : query}
        if self.max_id is not None:
            params['since_id'] = self.max_id
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
            self.max_id = result['max_id']
            return result['results']
        except (httplib.HTTPException, socket.error, socket.timeout), e:
            logging.error("search() error: %s" %(e))
            return None
#some code here

#Workers code
twittersearch(query)

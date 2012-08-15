import argparse
import json
from lib import twitter
query = 'iron.io'

parser = argparse.ArgumentParser(
        description="Simple argument parser")
parser.add_argument("-payload", type=str, required=False,
        help="The location of a file containing a JSON payload.")
parser.add_argument("-d", type=str, required=False,
        help="Directory")
parser.add_argument("-e", type=str, required=False,
        help="Environment")
parser.add_argument("-id", type=str, required=False,
        help="Task id")
args = parser.parse_args()

pd = False
if args.payload is not None:
    payload = json.loads(open(args.payload).read())
    if 'query' in payload:
        query = payload['query']

#Workers code
if query is not None:
    print("Search by query")
    results = twitter.search(query)
    print(results)
    myInput = open('myfile.txt','w+')
    print("now writing to file")
    myInput.write(results[0]['text'])
    myInput.close()
    myInput = open('myfile.txt','r')
    print("now reading from file")
    res_from_file = myInput.read()
    print(res_from_file)
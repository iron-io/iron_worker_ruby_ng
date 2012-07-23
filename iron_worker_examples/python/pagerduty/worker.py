import argparse
import json
from pagerduty import PagerDuty

parser = argparse.ArgumentParser(
        description="Calculates the Fibonacci sequence up to a maximum number")
parser.add_argument("-payload", type=str, required=False,
        help="The location of a file containing a JSON payload.")
args = parser.parse_args()

pd = False
if args.payload is not None:
    payload = json.loads(open(args.payload).read())
    if 'pagerduty' in payload:
        pd = PagerDuty(payload['pagerduty']['secret_key'])

def trigger_alert(description):
    if pd:
        pd.trigger(description)

#some code here

#let's report an incident eventually
trigger_alert('Something bad happened, evacuate immediately')

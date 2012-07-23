import hoover
import logging

import argparse
import json

parser = argparse.ArgumentParser(
        description="Some stuff")
parser.add_argument("-payload", type=str, required=False,
        help="The location of a file containing a JSON payload.")
args = parser.parse_args()
if args.payload is not None:
    payload = json.loads(open(args.payload).read())
    if 'loggly' in payload:
        loggly_settings = payload['loggly']
        i = hoover.LogglySession(loggly_settings['subdomain'], loggly_settings['username'], loggly_settings['password'])
        i.config_inputs() #inject loggly handler into logger chain

#and then usual yada-yada is going on
logger = logging.getLogger('worker_log')

# YOUR CODE HERE

logger.debug("Debug message")

#MORE CODE

logger.warn('Warning message')

logger.fatal('Unable to launch spaceship due to recent moon nazis invasion. Sorry for inconvenience.')

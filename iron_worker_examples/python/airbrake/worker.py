from airbrakepy.logging.handlers import AirbrakeHandler
import logging

# registering airbrake handler
logger = logging.getLogger("test-logger")
handler = AirbrakeHandler("API_KEY", environment='dev', component_name='SomethingWorker', node_name='IronWorker')
logger.addHandler(handler)

try:
    # your code here
    print 'TODO: Add actual worker code'
except StandardError:
    logger.error("test with exception", exc_info=True)
    logger.error("test without exception", exc_info=False)

from iron_worker import *

import pagerduty
import shutil

#here we have to include pagerduty library with worker.
worker_dir = os.path.dirname(__file__) + '/pagerduty'
pd_dir = os.path.dirname(pagerduty.__file__)
shutil.copytree(pd_dir, worker_dir + '/pagerduty') #copy it to worker directory

payload = {'pagerduty': {'service_key': PAGERDUTY_SERVICE_KEY}}

worker = IronWorker(config='config.ini')
IronWorker.zipDirectory(directory=worker_dir, destination='pagerduty-py.zip', overwrite=True)

res = worker.postCode(runFilename='pagerduty.py', zipFilename='pagerduty-py.zip', name='pagerduty-py')

task = worker.postTask(name='pagerduty-py', payload=payload)
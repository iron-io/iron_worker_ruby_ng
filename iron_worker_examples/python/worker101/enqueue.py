from iron_worker import *

worker = IronWorker(token='XXXXXXXXXX', project_id='xxxxxxxxxxx')

payload = {'pagerduty': {'query':'iron.io'}}

task = worker.postTask(name='PythonWorker101', payload=payload)

from iron_worker import *

import airbrakepy
import shutil

worker = IronWorker(token='XXXXXXXXXX', project_id='xxxxxxxxxxx')

#here we have to include AirbrakePy library with worker.
worker_dir = os.path.dirname(__file__) + '/airbrake'
abrakepy_dir = os.path.dirname(airbrakepy.__file__)
shutil.copytree(abrakepy_dir, worker_dir + '/airbrakepy') #copy it to worker directory

IronWorker.zipDirectory(directory="airbrake/", destination='worker.zip', overwrite=True)

res = worker.postCode(runFilename='worker.py', zipFilename='worker.zip', name='Airbrake.py sample')

task = worker.postTask(name='Airbrake.py sample')
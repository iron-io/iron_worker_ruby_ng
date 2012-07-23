from iron_worker import *
import shutil

import hoover

#here we have to include hoover library with worker.
worker_dir = os.path.dirname(__file__) + '/loggly'
hoover_dir = os.path.dirname(hoover.__file__)
shutil.copytree(hoover_dir, worker_dir + '/loggly') #copy it to worker directory

worker = IronWorker(config='config.ini')
IronWorker.zipDirectory(directory=worker_dir, destination='loggly-py.zip', overwrite=True)

res = worker.postCode(runFilename='loggly.py', zipFilename='loggly-py.zip', name='loggly-py')

payload = {'loggly': {'subdomain': 'LOGGLY_SUBDOMAIN', 'username': 'LOGGLY_USERNAME', 'password': 'LOGGLY_PASSWORD'}}

task = worker.postTask(name='loggly-py')
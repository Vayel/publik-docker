import sys
sys.path.insert(0, "/home")
from pyenv import *

BROKER_URL = 'amqp://{user}:{password}@rabbitmq:{port}//'.format(
    user=RABBITMQ_DEFAULT_USER,
    password=RABBITMQ_DEFAULT_PASS,
    port=RABBITMQ_PORT,
)

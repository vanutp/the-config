import logging
from fastapi import FastAPI

from vhapd.config import config
from vhapd.routes import router

logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.INFO)

app = FastAPI(debug=config.debug)

app.include_router(router)

import uvicorn

from vhapd.config import config


def main():
    uvicorn.run('vhapd:app', host=config.host, port=config.port, reload=config.debug)


if __name__ == '__main__':
    main()

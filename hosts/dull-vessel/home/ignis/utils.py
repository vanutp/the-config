import asyncio
from ignis.utils import Utils


def create_exec_task(cmd: str) -> None:
    # use create_task to run async function in a regular (sync) one
    asyncio.create_task(Utils.exec_sh_async(cmd))

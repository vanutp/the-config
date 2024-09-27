import logging
from typing import Annotated

from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from vhapd.config import access_config
from vhapd.core import get_full_app
from vhapd.schemas import App, User
from vhapd.utils import jwt_decode
from authlib.jose.errors import JoseError

logger = logging.getLogger(__name__)


auth_scheme = HTTPBearer()


async def get_current_user(
    creds: Annotated[HTTPAuthorizationCredentials, Depends(auth_scheme)],
) -> User:
    try:
        data = jwt_decode(creds.credentials)
        access_config_entry = [x for x in access_config.users if x.id == data['id']]
        if access_config_entry:
            user = User.model_validate(
                {
                    **access_config_entry[0].model_dump(),
                    **data,
                }
            )
        else:
            user = None
    except JoseError:
        user = None
    if user is None:
        raise HTTPException(
            status_code=401,
            headers={'WWW-Authenticate': 'Bearer'},
        )
    return user


async def get_requested_app(
    app_name: str, user: Annotated[User, Depends(get_current_user)]
) -> App:
    app = await get_full_app(app_name)
    if not app:
        raise HTTPException(status_code=404)
    if not user.is_admin and user.id not in app.metadata.owners:
        raise HTTPException(status_code=403)
    return app


async def get_managed_app(app: Annotated[App, Depends(get_requested_app)]) -> App:
    if not app.managed:
        raise HTTPException(status_code=400, detail="Can't edit unmanaged app")
    return app


# TODO: move to route
# async def get_editable_app(
#     app: Annotated[App, Depends(get_managed_app)],
#     user: Annotated[User, Depends(get_current_user)],
# ) -> App:
#     if not app.nix_config:
#         raise HTTPException(
#             status_code=400, detail='App config file not found, cannot edit'
#         )
#     if not user.is_admin and not app.json_data:
#         raise HTTPException(
#             status_code=403,
#             detail="Could not parse current app config and you don't have admin privileges, cannot edit"
#         )
#     return app

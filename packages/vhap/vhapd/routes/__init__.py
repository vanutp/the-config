import hashlib
import hmac
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response
from fastapi.responses import HTMLResponse, JSONResponse, PlainTextResponse
from pydantic import BaseModel

from vhapd.config import access_config, config
from vhapd.core import get_full_app, get_full_apps
from vhapd.dependencies import get_current_user, get_managed_app, get_requested_app
from vhapd.schemas import App, TelegramUser, User
from vhapd.utils import jwt_encode


router = APIRouter(prefix='/api')


class TelegramCallbackResponse(BaseModel):
    access_token: str


@router.post('/token', response_model=TelegramCallbackResponse)
async def telegram_callback(data: dict):
    query_hash = data.get('hash')
    data_check_string = '\n'.join(
        sorted(f'{x}={y}' for x, y in data.items() if x != 'hash')
    )
    bot_token_hash = hashlib.sha256(config.bot_token.encode()).digest()
    computed_hash = hmac.new(
        bot_token_hash, data_check_string.encode(), 'sha256'
    ).hexdigest()
    is_correct = hmac.compare_digest(computed_hash, query_hash)
    if not is_correct:
        raise HTTPException(401)

    allowed_user_ids = {user.id for user in access_config.users}
    if data.get('id') not in allowed_user_ids:
        raise HTTPException(403)

    data = {
        k: v
        for k, v in data.items()
        if k in ('id', 'first_name', 'last_name', 'username', 'photo_url', 'auth_date')
    }
    telegram_user = TelegramUser.model_validate(data)
    token = jwt_encode(telegram_user.model_dump())
    return TelegramCallbackResponse(access_token=token)


@router.get('/apps', response_model=list[App])
async def test(user: Annotated[User, Depends(get_current_user)]):
    apps = await get_full_apps()
    if user.is_admin:
        return apps
    else:
        return [app for app in apps if user.id in app.metadata.owners]


@router.get('/app/{app_name}', response_model=App)
async def get_app(app: Annotated[App, Depends(get_requested_app)]):
    return app

@router.post('/app/{app_name}/down', status_code=204)
async def down_app(app: Annotated[App, Depends(get_managed_app)]):
    return Response(status_code=204)


__all__ = ['router']

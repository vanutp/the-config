from ignis.widgets import Widget
from ignis.services.mpris import MprisService, MprisPlayer

mpris = MprisService.get_default()


def mpris_title(player: MprisPlayer) -> Widget.Box:
    return Widget.Box(
        spacing=10,
        setup=lambda self: player.connect(
            'closed',
            lambda x: self.unparent(),  # remove widget when player is closed
        ),
        child=[
            Widget.Icon(image='audio-x-generic-symbolic'),
            Widget.Label(
                ellipsize='end',
                max_width_chars=20,
                label=player.bind('title'),
            ),
        ],
    )


def Media() -> Widget.Box:
    return Widget.Box(
        spacing=10,
        child=[
            Widget.Label(
                label='No media players',
                visible=mpris.bind('players', lambda value: len(value) == 0),
            )
        ],
        setup=lambda self: mpris.connect(
            'player-added', lambda x, player: self.append(mpris_title(player))
        ),
    )

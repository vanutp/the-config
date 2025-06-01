from ignis.widgets import Widget
from ignis.services.audio import AudioService

audio = AudioService.get_default()


def Volume() -> Widget.Box:
    return Widget.Box(
        child=[
            Widget.Icon(
                image=audio.speaker.bind('icon_name'), style='margin-right: 5px;'
            ),
            Widget.Label(
                label=audio.speaker.bind('volume', transform=lambda value: str(value))
            ),
        ]
    )

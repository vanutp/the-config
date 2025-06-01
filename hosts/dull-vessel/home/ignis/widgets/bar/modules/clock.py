from datetime import datetime
from ignis.widgets import Widget
from ignis.utils import Utils


def Clock() -> Widget.Label:
    # poll for current time every second
    return Widget.Label(
        css_classes=['clock'],
        label=Utils.Poll(1_000, lambda self: datetime.now().strftime('%H:%M:%S')).bind(
            'output'
        ),
    )

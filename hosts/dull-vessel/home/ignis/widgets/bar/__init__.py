from ignis.widgets import Widget
from ignis.utils import Utils

from widgets.bar.modules.clock import Clock
from widgets.bar.modules.keyboard import Keyboard
from widgets.bar.modules.media import Media
from widgets.bar.modules.volume import Volume

from .modules.workspaces import Workspaces


def left(monitor_name: str) -> Widget.Box:
    return Widget.Box(child=[Workspaces(monitor_name)], spacing=10)


def center() -> Widget.Box:
    return Widget.Box(
        child=[
            # current_notification(),
            Widget.Separator(vertical=True, css_classes=['middle-separator']),
            Media(),
        ],
        spacing=10,
    )


def right() -> Widget.Box:
    return Widget.Box(
        child=[
            # tray(),
            Keyboard(),
            Volume(),
            Clock(),
        ],
        spacing=10,
    )


class Bar(Widget.Window):
    def __init__(self, monitor_id: int):
        monitor_name = Utils.get_monitor(monitor_id).get_connector()
        super().__init__(
            namespace=f'ignis_bar_{monitor_id}',
            monitor=monitor_id,
            anchor=['left', 'top', 'right'],
            exclusivity='exclusive',
            child=Widget.CenterBox(
                css_classes=['bar'],
                start_widget=left(monitor_name),
                center_widget=center(),
                end_widget=right(),
            ),
        )

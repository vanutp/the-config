from ignis.widgets import Widget
from ignis.services.niri import NiriService

niri = NiriService.get_default()


def Keyboard() -> Widget.EventBox:
    return Widget.EventBox(
        on_click=lambda self: niri.switch_kb_layout(),
        child=[Widget.Label(label=niri.keyboard_layouts.bind('current_name'))],
    )

from ignis.widgets import Widget
from ignis.services.system_tray import SystemTrayService, SystemTrayItem

system_tray = SystemTrayService.get_default()


def tray_item(item: SystemTrayItem) -> Widget.Button:
    if item.menu:
        menu = item.menu.copy()
    else:
        menu = None

    return Widget.Button(
        child=Widget.Box(
            child=[
                Widget.Icon(image=item.bind('icon'), pixel_size=24),
                menu,
            ]
        ),
        setup=lambda self: item.connect('removed', lambda x: self.unparent()),
        tooltip_text=item.bind('tooltip'),
        on_click=lambda x: menu.popup() if menu else None,
        on_right_click=lambda x: menu.popup() if menu else None,
        css_classes=['tray-item'],
    )


def Tray():
    return Widget.Box(
        setup=lambda self: system_tray.connect(
            'added', lambda x, item: self.append(tray_item(item))
        ),
        spacing=10,
    )

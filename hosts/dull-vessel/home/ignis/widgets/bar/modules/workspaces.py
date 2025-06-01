from ignis.widgets import Widget
from ignis.services.niri import NiriService, NiriWorkspace

niri = NiriService.get_default()


def workspace_button(workspace: NiriWorkspace) -> Widget.Button:
    widget = Widget.Button(
        css_classes=['workspace'],
        on_click=lambda x: workspace.switch_to(),
        child=Widget.Label(label=str(workspace.idx)),
    )
    if workspace.is_active:
        widget.add_css_class('active')

    return widget


def scroll_workspaces(monitor_name: str, direction: str) -> None:
    current = list(
        filter(lambda w: w.is_active and w.output == monitor_name, niri.workspaces)
    )[0].idx
    if direction == 'up':
        target = current + 1
        niri.switch_to_workspace(target)
    else:
        target = current - 1
        niri.switch_to_workspace(target)


def Workspaces(monitor_name: str) -> Widget.EventBox:
    return Widget.EventBox(
        on_scroll_up=lambda x: scroll_workspaces(monitor_name, 'up'),
        on_scroll_down=lambda x: scroll_workspaces(monitor_name, 'down'),
        css_classes=['workspaces'],
        spacing=5,
        child=niri.bind(
            'workspaces',
            transform=lambda value: [
                workspace_button(i) for i in value if i.output == monitor_name
            ],
        ),
    )

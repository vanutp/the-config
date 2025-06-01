from ignis.widgets import Widget
from ignis.services.notifications import NotificationService

notifications = NotificationService.get_default()


def current_notification() -> Widget.Label:
    return Widget.Label(
        ellipsize='end',
        max_width_chars=20,
        label=notifications.bind(
            'notifications', lambda value: value[-1].summary if len(value) > 0 else None
        ),
    )

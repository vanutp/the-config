from ignis.utils import Utils
from ignis.app import IgnisApp

from widgets.bar import Bar

app = IgnisApp.get_default()

app.apply_css(f'{Utils.get_current_dir()}/style.scss')


# this will display bar on all monitors
for i in range(Utils.get_n_monitors()):
    Bar(i)

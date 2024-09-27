APP_NOT_FULLY_MANAGED = (
    'This app has both managed and unmanaged containers. '
    'Please recreate the app manually'
)
APP_ORPHANED = (
    'This app was created using vhap, but has been removed from the nix config. '
    'Please fix the issue manually'
)
APP_CONFIGURED_BUT_RUNNING_UNMANAGED = (
    'This app was found in the nix config, but running containers are unmanaged. '
    'Please recreate the app manually'
)

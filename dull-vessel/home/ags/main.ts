import 'virtual:uno.css'

const vpnSwitcher = Widget.Window({
  name: 'vpn-switcher',
  anchor: ['top', 'right'],
  exclusivity: 'ignore',
  keymode: 'on-demand',
  layer: 'top',
  child: Widget.Box({
    vertical: true,
    class_name: 'px-4 py-2 bg-[#eeeeee00]',
    children: [
      
    ]
  })
});

App.config({
  // style: './main.css',
  windows: [vpnSwitcher],
});

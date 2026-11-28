import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "bluetoothLauncher"
    property string trigger: "bt"

    signal itemsChanged

    Component.onCompleted: {
        if (pluginService) {
            trigger = pluginService.loadPluginData(pluginId, "trigger", "bt");
        }
    }

    // Refresh Spotlight live if devices connect/disconnect while the launcher is open
    property Connections btConnections: Connections {
        target: Bluetooth.defaultAdapter
        function onStateChanged() {
            root.itemsChanged();
            root.pluginService?.requestLauncherUpdate(root.pluginId);
        }
        function onDiscoveringChanged() {
            root.itemsChanged();
            root.pluginService?.requestLauncherUpdate(root.pluginId);
        }
    }

    function getItems(query) {
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter) {
            return [{
                name: "No Bluetooth Adapter Found",
                icon: "material:bluetooth_disabled",
                comment: "Check that bluetooth.service is running",
                action: "noop",
                categories: ["Bluetooth"]
            }];
        }

        const q = (query || "").trim().toLowerCase();
        const items = [];
        const powered = adapter.enabled;

        // 1. Adapter Power Toggle
        const powerTitle = powered ? "Turn Bluetooth Off" : "Turn Bluetooth On";
        if (!q || powerTitle.toLowerCase().includes(q) || "power".includes(q)) {
            items.push({
                name: powerTitle,
                icon: powered ? "material:bluetooth_disabled" : "material:bluetooth",
                comment: powered ? "Adapter is currently enabled" : "Adapter is currently disabled",
                action: "adapter:toggle",
                categories: ["Bluetooth"]
            });
        }

        if (!powered) return items;

        // 2. Scan Toggle
        const scanning = adapter.discovering;
        const scanTitle = scanning ? "Stop Scanning for Devices" : "Scan for Devices";
        if (!q || scanTitle.toLowerCase().includes(q) || "discover".includes(q)) {
            items.push({
                name: scanTitle,
                icon: scanning ? "material:sync_disabled" : "material:bluetooth_searching",
                comment: scanning ? "Discovery is active..." : "Search for nearby Bluetooth devices",
                action: "adapter:scan",
                categories: ["Bluetooth"]
            });
        }

        // 3. Devices List (Connected first, then Paired, then Unpaired)
        const deviceList = adapter.devices ? adapter.devices.values : [];
        const sorted = Array.from(deviceList).sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if (a.paired !== b.paired) return a.paired ? -1 : 1;
            return (a.name || a.address).localeCompare(b.name || b.address);
        });

        for (let i = 0; i < sorted.length; i++) {
            const dev = sorted[i];
            const label = dev.name || dev.deviceName || dev.address;
            const addr = dev.address;

            if (q && !label.toLowerCase().includes(q) && !addr.toLowerCase().includes(q)) {
                continue;
            }

            let statusParts = [];
            if (dev.connected) statusParts.push("Connected");
            else if (dev.paired) statusParts.push("Paired");
            else statusParts.push("Available");

            if (dev.connected && dev.batteryAvailable) {
                statusParts.push(Math.round(dev.battery * 100) + "% battery");
            }
            statusParts.push(addr);

            items.push({
                name: label,
                icon: dev.connected ? "material:bluetooth_connected" : (dev.paired ? "material:bluetooth" : "material:bluetooth_searching"),
                comment: statusParts.join(" • "),
                action: "device:" + addr,
                keywords: [addr, dev.connected ? "disconnect" : "connect"],
                categories: ["Bluetooth"]
            });
        }

        return items;
    }

    function executeItem(item) {
        if (!item?.action) return;
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter) return;

        if (item.action === "adapter:toggle") {
            adapter.enabled = !adapter.enabled;
            ToastService.showInfo("Bluetooth", adapter.enabled ? "Bluetooth enabled" : "Bluetooth disabled");
            return;
        }

        if (item.action === "adapter:scan") {
            adapter.discovering = !adapter.discovering;
            ToastService.showInfo("Bluetooth", adapter.discovering ? "Scanning for devices..." : "Stopped scanning");
            return;
        }

        if (item.action.startsWith("device:")) {
            const addr = item.action.substring(7);
            const dev = findDevice(addr);
            if (!dev) return;

            if (!dev.paired) {
                dev.pair();
                ToastService.showInfo("Bluetooth", "Pairing with " + (dev.name || addr) + "...");
            } else {
                const nextState = !dev.connected;
                dev.connected = nextState;
                ToastService.showInfo("Bluetooth", (nextState ? "Connecting to " : "Disconnecting ") + (dev.name || addr));
            }
        }
    }

    // Optional: Right-click / Tab context menu for Trust / Forget actions
    function getContextMenuActions(item) {
        if (!item?.action?.startsWith("device:")) return [];
        const addr = item.action.substring(7);
        const dev = findDevice(addr);
        if (!dev) return [];

        const actions = [];
        if (dev.paired) {
            actions.push({
                icon: dev.trusted ? "verified_user" : "shield",
                text: dev.trusted ? "Untrust Device" : "Trust Device",
                action: () => { dev.trusted = !dev.trusted; }
            });
            actions.push({
                icon: "delete",
                text: "Forget Device",
                action: () => {
                    dev.forget();
                    ToastService.showInfo("Bluetooth", "Forgot " + (dev.name || addr));
                }
            });
        }
        return actions;
    }

    function findDevice(address) {
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter || !adapter.devices) return null;
        const list = adapter.devices.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].address === address) return list[i];
        }
        return null;
    }
}


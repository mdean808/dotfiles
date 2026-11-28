import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "bluetoothLauncher"

    StyledText {
        width: parent.width
        text: "Bluetooth Launcher Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "trigger"
        label: "Launcher Trigger"
        description: "Prefix typed in Spotlight to list Bluetooth devices (e.g., bt)"
        placeholder: "bt"
        defaultValue: "bt"
    }
}


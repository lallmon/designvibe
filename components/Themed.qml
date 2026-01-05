pragma Singleton

import QtQuick

// Shared palette access; single SystemPalette instance.
QtObject {
    readonly property SystemPalette palette: SystemPalette {
        colorGroup: SystemPalette.Active
    }
}

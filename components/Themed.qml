// Copyright (C) 2026 The Culture List, Inc.
// SPDX-License-Identifier: GPL-3.0-or-later

pragma Singleton

import QtQuick

// Theme detection and custom colors that follow the OS theme.
QtObject {
    readonly property SystemPalette palette: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    // Direct system color scheme detection (Qt 6.5+)
    readonly property bool isDark: Qt.styleHints.colorScheme === Qt.Dark

    // Custom grid colors that switch with theme
    readonly property color gridBackground: isDark ? "#1e1e1e" : "#f2f2f2"
    // Adjusted for better contrast: dark theme 20% lighter, light theme 20% darker
    readonly property color gridMajor: isDark ? "#636363" : "#a8a8a8"
    readonly property color gridMinor: isDark ? "#575757" : "#b8b8b8"

    readonly property color selector: "#409cff"
    readonly property color editSelector: "#fc03d2"

    // Default tool colors that switch with theme
    readonly property color defaultStroke: "#808080"
    readonly property color defaultFill: "#A0A0A0"
}

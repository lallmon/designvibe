// Copyright (C) 2026 The Culture List, Inc.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as Lucent

Pane {
    id: root
    padding: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: rightPaneTabBar1
            Layout.fillWidth: true
            TabButton {
                text: "Transform"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.maximumHeight: transformPanel.implicitHeight
            currentIndex: rightPaneTabBar1.currentIndex
            TransformPanel {
                id: transformPanel
            }
        }

        TabBar {
            id: rightPaneTabBar2
            Layout.fillWidth: true
            TabButton {
                text: "Layers"
            }
            TabButton {
                text: "History"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: rightPaneTabBar2.currentIndex
            LayerPanel {
                id: layerPanel
            }
            HistoryPanel {
                id: historyPanel
            }
        }
    }
}

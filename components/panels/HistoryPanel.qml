// Copyright (C) 2026 The Culture List, Inc.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as Lucent

Item {
    id: root
    readonly property SystemPalette themePalette: Lucent.Themed.palette

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ToolSeparator {
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            contentItem: Rectangle {
                implicitHeight: 1
                color: themePalette.mid
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: historyList
                anchors.fill: parent
                model: historyManager.undoDescriptions

                delegate: Rectangle {
                    width: historyList.width
                    height: 24
                    color: "transparent"

                    Label {
                        anchors.fill: parent
                        anchors.leftMargin: Lucent.Styles.pad.sm
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: root.themePalette.text
                        font.pixelSize: 11
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: historyList.count === 0
                text: qsTr("No history")
                font.pixelSize: 12
                color: themePalette.text
            }
        }
    }
}

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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: historyList
                anchors.fill: parent
                model: historyManager.undoDescriptions

                // Auto-scroll to show newest item at bottom
                onCountChanged: {
                    if (count > 0) {
                        positionViewAtEnd();
                    }
                }

                delegate: Column {
                    width: historyList.width

                    Rectangle {
                        width: parent.width
                        height: 32
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

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.themePalette.mid
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

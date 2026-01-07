import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Lucent

Pane {
    id: root
    padding: 0
    readonly property SystemPalette themePalette: Lucent.Themed.palette

    signal exportLayerRequested(string layerId, string layerName)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Transform section - fixed height based on content
        Pane {
            Layout.fillWidth: true
            padding: 12

            TranslationPanel {
                id: translationPanel
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 100
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: themePalette.mid
        }

        // Layers section
        Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            padding: 12

            LayerPanel {
                anchors.fill: parent
                onExportLayerRequested: (layerId, layerName) => root.exportLayerRequested(layerId, layerName)
            }
        }
    }

    // Keep panel selection in sync without introducing a binding loop
    Component.onCompleted: {
        translationPanel.selectedItem = Lucent.SelectionManager.selectedItem;
    }
    Connections {
        target: Lucent.SelectionManager
        function onSelectedItemChanged() {
            translationPanel.selectedItem = Lucent.SelectionManager.selectedItem;
        }
        function onSelectedItemIndexChanged() {
            translationPanel.selectedItem = Lucent.SelectionManager.selectedItem;
        }
        function onSelectedIndicesChanged() {
            translationPanel.selectedItem = Lucent.SelectionManager.selectedItem;
        }
    }
}

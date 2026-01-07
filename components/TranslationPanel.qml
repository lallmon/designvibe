import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Lucent

// Panel displaying unified transform properties (X, Y, Width, Height) for selected items
Item {
    id: root
    readonly property SystemPalette themePalette: Lucent.Themed.palette

    property var selectedItem: null

    // Check if the selected item supports bounding box editing
    readonly property bool hasEditableBounds: {
        if (!selectedItem)
            return false;
        var t = selectedItem.type;
        return t === "rectangle" || t === "ellipse" || t === "path" || t === "text";
    }

    // Check if selected item is effectively locked
    readonly property bool isLocked: (Lucent.SelectionManager.selectedItemIndex >= 0) && canvasModel && canvasModel.isEffectivelyLocked(Lucent.SelectionManager.selectedItemIndex)

    // Current bounding box from the model
    readonly property var currentBounds: {
        var idx = Lucent.SelectionManager.selectedItemIndex;
        if (idx < 0 || !canvasModel)
            return null;
        return canvasModel.getBoundingBox(idx);
    }

    // Controls are enabled only when an editable item is selected and not locked
    readonly property bool controlsEnabled: hasEditableBounds && !isLocked

    readonly property int labelSize: 10
    readonly property color labelColor: themePalette.text

    function updateBounds(property, value) {
        var idx = Lucent.SelectionManager.selectedItemIndex;
        if (idx < 0 || !canvasModel || !currentBounds)
            return;

        var newBounds = {
            x: currentBounds.x,
            y: currentBounds.y,
            width: currentBounds.width,
            height: currentBounds.height
        };
        newBounds[property] = value;
        canvasModel.setBoundingBox(idx, newBounds);
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            text: qsTr("Transform")
            font.pixelSize: 12
            color: themePalette.text
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: themePalette.mid
        }

        // Transform properties grid - always visible for consistent height
        // Row 1: X and Y, Row 2: Width and Height
        GridLayout {
            columns: 4
            rowSpacing: 4
            columnSpacing: 8
            Layout.fillWidth: true
            Layout.topMargin: 4
            enabled: root.controlsEnabled
            opacity: root.controlsEnabled ? 1.0 : 0.5

            // Row 1: X and Y
            Label {
                text: qsTr("X:")
                font.pixelSize: root.labelSize
                color: root.labelColor
            }
            SpinBox {
                from: -100000
                to: 100000
                value: root.currentBounds ? Math.round(root.currentBounds.x) : 0
                editable: true
                Layout.fillWidth: true
                onValueModified: root.updateBounds("x", value)
            }

            Label {
                text: qsTr("Y:")
                font.pixelSize: root.labelSize
                color: root.labelColor
            }
            SpinBox {
                from: -100000
                to: 100000
                value: root.currentBounds ? Math.round(root.currentBounds.y) : 0
                editable: true
                Layout.fillWidth: true
                onValueModified: root.updateBounds("y", value)
            }

            // Row 2: Width and Height
            Label {
                text: qsTr("W:")
                font.pixelSize: root.labelSize
                color: root.labelColor
            }
            SpinBox {
                from: 0
                to: 100000
                value: root.currentBounds ? Math.round(root.currentBounds.width) : 0
                editable: true
                Layout.fillWidth: true
                onValueModified: root.updateBounds("width", value)
            }

            Label {
                text: qsTr("H:")
                font.pixelSize: root.labelSize
                color: root.labelColor
            }
            SpinBox {
                from: 0
                to: 100000
                value: root.currentBounds ? Math.round(root.currentBounds.height) : 0
                editable: true
                Layout.fillWidth: true
                onValueModified: root.updateBounds("height", value)
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

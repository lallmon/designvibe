import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Lucent

ToolBar {
    id: root
    height: 48

    property string activeTool: ""
    readonly property SystemPalette themePalette: Lucent.Themed.palette

    // Selection awareness: when a shape is selected, show its properties
    // Use a non-readonly property to avoid binding loops when itemModified updates the selection
    property var currentSelection: null
    property string currentSelectionType: ""

    // Update selection info when SelectionManager changes (but not during property edits)
    Connections {
        target: Lucent.SelectionManager
        function onSelectedItemChanged() {
            var item = Lucent.SelectionManager.selectedItem;
            root.currentSelection = item;
            root.currentSelectionType = item ? item.type : "";
        }
    }

    Component.onCompleted: {
        // Initialize from current selection
        var item = Lucent.SelectionManager.selectedItem;
        currentSelection = item;
        currentSelectionType = item ? item.type : "";
    }

    readonly property bool hasEditableSelection: {
        var t = currentSelectionType;
        return t === "rectangle" || t === "ellipse" || t === "path" || t === "text";
    }

    // Determine which settings to display: selected item type takes priority over active tool
    readonly property string displayType: hasEditableSelection ? currentSelectionType : activeTool

    // Expose tool settings for external access (e.g., when creating shapes)
    readonly property var toolSettings: ({
            "rectangle": {
                strokeWidth: rectangleSettings.strokeWidth,
                strokeColor: rectangleSettings.strokeColor,
                strokeOpacity: rectangleSettings.strokeOpacity,
                fillColor: rectangleSettings.fillColor,
                fillOpacity: rectangleSettings.fillOpacity
            },
            "ellipse": {
                strokeWidth: ellipseSettings.strokeWidth,
                strokeColor: ellipseSettings.strokeColor,
                strokeOpacity: ellipseSettings.strokeOpacity,
                fillColor: ellipseSettings.fillColor,
                fillOpacity: ellipseSettings.fillOpacity
            },
            "pen": {
                strokeWidth: penSettings.strokeWidth,
                strokeColor: penSettings.strokeColor,
                strokeOpacity: penSettings.strokeOpacity,
                fillColor: penSettings.fillColor,
                fillOpacity: penSettings.fillOpacity
            },
            "text": {
                fontFamily: textSettings.fontFamily,
                fontSize: textSettings.fontSize,
                textColor: textSettings.textColor,
                textOpacity: textSettings.textOpacity
            }
        })

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Lucent.RectangleToolSettings {
            id: rectangleSettings
            visible: root.displayType === "rectangle"
            editMode: root.hasEditableSelection && root.currentSelectionType === "rectangle"
            selectedItem: root.hasEditableSelection ? root.currentSelection : null
        }

        Lucent.EllipseToolSettings {
            id: ellipseSettings
            visible: root.displayType === "ellipse"
            editMode: root.hasEditableSelection && root.currentSelectionType === "ellipse"
            selectedItem: root.hasEditableSelection ? root.currentSelection : null
        }

        Lucent.PenToolSettings {
            id: penSettings
            visible: root.displayType === "pen" || root.displayType === "path"
            editMode: root.hasEditableSelection && root.currentSelectionType === "path"
            selectedItem: root.hasEditableSelection ? root.currentSelection : null
        }

        Lucent.TextToolSettings {
            id: textSettings
            visible: root.displayType === "text"
            editMode: root.hasEditableSelection && root.currentSelectionType === "text"
            selectedItem: root.hasEditableSelection ? root.currentSelection : null
        }

        // Empty state when no tool selected and no shape selected
        Item {
            visible: !root.hasEditableSelection && (root.activeTool === "select" || root.activeTool === "")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as DV

ToolBar {
    id: root
    height: 48

    property ToolDefaults toolDefaults: ToolDefaults {}
    property string activeTool: ""
    readonly property SystemPalette themePalette: DV.Themed.palette

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

    // Backward compatibility aliases for direct property access
    property alias rectangleStrokeWidth: rectangleSettings.strokeWidth
    property alias rectangleStrokeColor: rectangleSettings.strokeColor
    property alias rectangleStrokeOpacity: rectangleSettings.strokeOpacity
    property alias rectangleFillColor: rectangleSettings.fillColor
    property alias rectangleFillOpacity: rectangleSettings.fillOpacity

    property alias ellipseStrokeWidth: ellipseSettings.strokeWidth
    property alias ellipseStrokeColor: ellipseSettings.strokeColor
    property alias ellipseStrokeOpacity: ellipseSettings.strokeOpacity
    property alias ellipseFillColor: ellipseSettings.fillColor
    property alias ellipseFillOpacity: ellipseSettings.fillOpacity

    property alias penStrokeWidth: penSettings.strokeWidth
    property alias penStrokeColor: penSettings.strokeColor
    property alias penStrokeOpacity: penSettings.strokeOpacity
    property alias penFillColor: penSettings.fillColor
    property alias penFillOpacity: penSettings.fillOpacity

    property alias textFontFamily: textSettings.fontFamily
    property alias textFontSize: textSettings.fontSize
    property alias textColor: textSettings.textColor
    property alias textOpacity: textSettings.textOpacity

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        DV.RectangleToolSettings {
            id: rectangleSettings
            visible: root.activeTool === "rectangle"
            strokeColor: root.toolDefaults.defaultStrokeColor
            fillColor: root.toolDefaults.defaultFillColor
            fillOpacity: root.toolDefaults.defaultFillOpacity
        }

        DV.EllipseToolSettings {
            id: ellipseSettings
            visible: root.activeTool === "ellipse"
            strokeColor: root.toolDefaults.defaultStrokeColor
            fillColor: root.toolDefaults.defaultFillColor
            fillOpacity: root.toolDefaults.defaultFillOpacity
        }

        DV.PenToolSettings {
            id: penSettings
            visible: root.activeTool === "pen"
            strokeColor: root.toolDefaults.defaultStrokeColor
            fillColor: root.toolDefaults.defaultFillColor
            fillOpacity: root.toolDefaults.defaultFillOpacity
        }

        DV.TextToolSettings {
            id: textSettings
            visible: root.activeTool === "text"
            textColor: root.toolDefaults.defaultStrokeColor
        }

        // Select tool settings (empty for now)
        Item {
            visible: root.activeTool === "select" || root.activeTool === ""
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }
    }
}

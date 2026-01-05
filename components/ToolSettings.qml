import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "." as DV

ToolBar {
    id: root
    height: 48
    property ToolDefaults toolDefaults: ToolDefaults {}

    property string activeTool: ""  // Current tool ("select", "rectangle", "ellipse", etc.)
    readonly property SystemPalette themePalette: DV.Themed.palette

    property real rectangleStrokeWidth: 1
    property color rectangleStrokeColor: toolDefaults.defaultStrokeColor
    property real rectangleStrokeOpacity: 1.0
    property color rectangleFillColor: toolDefaults.defaultFillColor
    property real rectangleFillOpacity: toolDefaults.defaultFillOpacity

    property real ellipseStrokeWidth: 1
    property color ellipseStrokeColor: toolDefaults.defaultStrokeColor
    property real ellipseStrokeOpacity: 1.0
    property color ellipseFillColor: toolDefaults.defaultFillColor
    property real ellipseFillOpacity: toolDefaults.defaultFillOpacity

    property real penStrokeWidth: 1
    property color penStrokeColor: toolDefaults.defaultStrokeColor
    property real penStrokeOpacity: 1.0
    property color penFillColor: toolDefaults.defaultFillColor
    property real penFillOpacity: toolDefaults.defaultFillOpacity

    property string textFontFamily: "Sans Serif"
    property real textFontSize: 16
    property color textColor: toolDefaults.defaultStrokeColor
    property real textOpacity: 1.0

    readonly property var toolSettings: ({
            "rectangle": {
                strokeWidth: rectangleStrokeWidth,
                strokeColor: rectangleStrokeColor,
                strokeOpacity: rectangleStrokeOpacity,
                fillColor: rectangleFillColor,
                fillOpacity: rectangleFillOpacity
            },
            "ellipse": {
                strokeWidth: ellipseStrokeWidth,
                strokeColor: ellipseStrokeColor,
                strokeOpacity: ellipseStrokeOpacity,
                fillColor: ellipseFillColor,
                fillOpacity: ellipseFillOpacity
            },
            "pen": {
                strokeWidth: penStrokeWidth,
                strokeColor: penStrokeColor,
                strokeOpacity: penStrokeOpacity,
                fillColor: penFillColor,
                fillOpacity: penFillOpacity
            },
            "text": {
                fontFamily: textFontFamily,
                fontSize: textFontSize,
                textColor: textColor,
                textOpacity: textOpacity
            }
        })

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        // Rectangle tool settings
        RowLayout {
            id: rectangleSettings
            visible: root.activeTool === "rectangle"
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            DV.LabeledNumericField {
                labelText: qsTr("Stroke Width:")
                value: root.rectangleStrokeWidth
                minimum: 0.1
                maximum: 100.0
                decimals: 1
                suffix: qsTr("px")
                onCommitted: function (newValue) {
                    root.rectangleStrokeWidth = newValue;
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Stroke Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.rectangleStrokeColor
                colorOpacity: root.rectangleStrokeOpacity
                dialogTitle: qsTr("Choose Stroke Color")
                onColorPicked: newColor => root.rectangleStrokeColor = newColor
            }

            Label {
                text: qsTr("Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: strokeOpacitySlider
                opacityValue: root.rectangleStrokeOpacity
                onValueUpdated: newOpacity => root.rectangleStrokeOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.rectangleStrokeOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.rectangleStrokeOpacity = newValue / 100.0;
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Fill Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.rectangleFillColor
                colorOpacity: root.rectangleFillOpacity
                dialogTitle: qsTr("Choose Fill Color")
                onColorPicked: newColor => root.rectangleFillColor = newColor
            }

            Label {
                text: qsTr("Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: opacitySlider
                opacityValue: root.rectangleFillOpacity
                onValueUpdated: newOpacity => root.rectangleFillOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.rectangleFillOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.rectangleFillOpacity = newValue / 100.0;
                }
            }
        }

        // Pen tool settings
        RowLayout {
            id: penSettings
            visible: root.activeTool === "pen"
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            DV.LabeledNumericField {
                labelText: qsTr("Stroke Width:")
                value: root.penStrokeWidth
                minimum: 0.1
                maximum: 100.0
                decimals: 1
                suffix: qsTr("px")
                onCommitted: function (newValue) {
                    root.penStrokeWidth = newValue;
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Stroke Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.penStrokeColor
                colorOpacity: root.penStrokeOpacity
                dialogTitle: qsTr("Choose Pen Stroke Color")
                onColorPicked: newColor => root.penStrokeColor = newColor
            }

            Label {
                text: qsTr("Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: penStrokeOpacitySlider
                opacityValue: root.penStrokeOpacity
                onValueUpdated: newOpacity => root.penStrokeOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.penStrokeOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.penStrokeOpacity = newValue / 100.0;
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Fill Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.penFillColor
                colorOpacity: root.penFillOpacity
                dialogTitle: qsTr("Choose Pen Fill Color")
                onColorPicked: newColor => root.penFillColor = newColor
            }

            Label {
                text: qsTr("Fill Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: penFillOpacitySlider
                opacityValue: root.penFillOpacity
                onValueUpdated: newOpacity => root.penFillOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.penFillOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.penFillOpacity = newValue / 100.0;
                }
            }
        }

        // Ellipse tool settings
        RowLayout {
            id: ellipseSettings
            visible: root.activeTool === "ellipse"
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            DV.LabeledNumericField {
                labelText: qsTr("Stroke Width:")
                value: root.ellipseStrokeWidth
                minimum: 0.1
                maximum: 100.0
                decimals: 1
                suffix: qsTr("px")
                onCommitted: function (newValue) {
                    root.ellipseStrokeWidth = newValue;
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Stroke Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.ellipseStrokeColor
                colorOpacity: root.ellipseStrokeOpacity
                dialogTitle: qsTr("Choose Ellipse Stroke Color")
                onColorPicked: newColor => root.ellipseStrokeColor = newColor
            }

            Label {
                text: qsTr("Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: ellipseStrokeOpacitySlider
                opacityValue: root.ellipseStrokeOpacity
                onValueUpdated: newOpacity => root.ellipseStrokeOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.ellipseStrokeOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.ellipseStrokeOpacity = newValue / 100.0;
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Fill Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.ellipseFillColor
                colorOpacity: root.ellipseFillOpacity
                dialogTitle: qsTr("Choose Ellipse Fill Color")
                onColorPicked: newColor => root.ellipseFillColor = newColor
            }

            Label {
                text: qsTr("Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: ellipseOpacitySlider
                opacityValue: root.ellipseFillOpacity
                onValueUpdated: newOpacity => root.ellipseFillOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.ellipseFillOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.ellipseFillOpacity = newValue / 100.0;
                }
            }
        }

        // Text tool settings
        RowLayout {
            id: textSettings
            visible: root.activeTool === "text"
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Label {
                text: qsTr("Font:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            ComboBox {
                id: fontFamilyCombo
                Layout.preferredWidth: 160
                Layout.preferredHeight: DV.Styles.height.md
                Layout.alignment: Qt.AlignVCenter
                model: fontProvider ? fontProvider.fonts : []
                currentIndex: fontProvider ? fontProvider.indexOf(root.textFontFamily) : 0

                onCurrentTextChanged: {
                    if (currentText && currentText.length > 0) {
                        root.textFontFamily = currentText;
                    }
                }

                Component.onCompleted: {
                    // Set default font if not already set
                    if (fontProvider && (!root.textFontFamily || root.textFontFamily === "Sans Serif")) {
                        root.textFontFamily = fontProvider.defaultFont();
                    }
                }

                background: Rectangle {
                    color: palette.base
                    border.color: fontFamilyCombo.activeFocus ? palette.highlight : palette.mid
                    border.width: 1
                    radius: DV.Styles.rad.sm
                }

                contentItem: Text {
                    text: fontFamilyCombo.displayText
                    color: palette.text
                    font.pixelSize: 11
                    font.family: fontFamilyCombo.displayText
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 6
                    elide: Text.ElideRight
                }
            }

            ToolSeparator {}

            Label {
                text: qsTr("Size:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            ComboBox {
                id: textFontSizeCombo
                Layout.preferredWidth: 70
                Layout.preferredHeight: DV.Styles.height.md
                Layout.alignment: Qt.AlignVCenter
                editable: true
                model: [8, 9, 10, 11, 12, 14, 16, 18, 20, 24, 28, 32, 36, 48, 64, 72, 96, 128]

                // Find current index or -1 for custom values
                currentIndex: {
                    var idx = model.indexOf(Math.round(root.textFontSize));
                    return idx >= 0 ? idx : -1;
                }

                // Update text field to show current size
                Component.onCompleted: {
                    editText = Math.round(root.textFontSize).toString();
                }

                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        root.textFontSize = model[currentIndex];
                    }
                }

                onAccepted: {
                    var value = parseFloat(editText);
                    if (!isNaN(value) && value >= 8 && value <= 200) {
                        root.textFontSize = Math.round(value);
                    }
                    editText = Math.round(root.textFontSize).toString();
                }

                // Sync editText when textFontSize changes externally
                Connections {
                    target: root
                    function onTextFontSizeChanged() {
                        if (!textFontSizeCombo.activeFocus) {
                            textFontSizeCombo.editText = Math.round(root.textFontSize).toString();
                        }
                    }
                }

                validator: IntValidator {
                    bottom: 8
                    top: 200
                }

                background: Rectangle {
                    color: palette.base
                    border.color: textFontSizeCombo.activeFocus ? palette.highlight : palette.mid
                    border.width: 1
                    radius: DV.Styles.rad.sm
                }

                contentItem: TextInput {
                    text: textFontSizeCombo.editText
                    font.pixelSize: 11
                    color: palette.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    leftPadding: 6
                    rightPadding: 6
                    selectByMouse: true
                    validator: textFontSizeCombo.validator

                    onTextChanged: textFontSizeCombo.editText = text
                    onAccepted: textFontSizeCombo.accepted()
                }
            }

            Label {
                text: qsTr("pt")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            ToolSeparator {}

            Label {
                text: qsTr("Color:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.ColorPickerButton {
                color: root.textColor
                colorOpacity: root.textOpacity
                dialogTitle: qsTr("Choose Text Color")
                onColorPicked: newColor => root.textColor = newColor
            }

            Label {
                text: qsTr("Opacity:")
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }

            DV.OpacitySlider {
                id: textOpacitySlider
                opacityValue: root.textOpacity
                onValueUpdated: newOpacity => root.textOpacity = newOpacity
            }

            DV.LabeledNumericField {
                labelText: ""
                value: Math.round(root.textOpacity * 100)
                minimum: 0
                maximum: 100
                decimals: 0
                fieldWidth: 35
                suffix: qsTr("%")
                onCommitted: function (newValue) {
                    root.textOpacity = newValue / 100.0;
                }
            }
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

import QtQuick
import QtQuick.Controls
import "." as DV

// Text tool component for creating text on the canvas
Item {
    id: tool

    // Properties passed from Canvas
    property real zoomLevel: 1.0
    property bool active: false
    property var settings: null  // Tool settings object

    // State for text input
    property bool isEditing: false
    property real textX: 0
    property real textY: 0

    // Signal emitted when a text item is completed
    signal itemCompleted(var itemData)

    // Text input overlay (shown while editing)
    Item {
        id: textInputContainer
        visible: tool.isEditing
        x: tool.textX
        y: tool.textY

        // Live preview text (shows what the text will look like)
        Text {
            id: previewText
            x: 0
            y: -font.pixelSize  // Position above baseline
            text: textInput.text || " "
            font.family: settings ? settings.fontFamily : "Sans Serif"
            font.pixelSize: (settings ? settings.fontSize : 16) / tool.zoomLevel
            color: {
                if (!settings)
                    return DV.PaletteBridge.active.text;
                var c = Qt.color(settings.textColor);
                c.a = settings.textOpacity !== undefined ? settings.textOpacity : 1.0;
                return c;
            }
            opacity: 0.5  // Show preview at lower opacity
            visible: textInput.text.length > 0
        }

        // Editable text input
        TextInput {
            id: textInput
            x: 0
            y: -font.pixelSize  // Position above baseline
            font.family: settings ? settings.fontFamily : "Sans Serif"
            font.pixelSize: (settings ? settings.fontSize : 16) / tool.zoomLevel
            color: {
                if (!settings)
                    return DV.PaletteBridge.active.text;
                var c = Qt.color(settings.textColor);
                c.a = settings.textOpacity !== undefined ? settings.textOpacity : 1.0;
                return c;
            }
            cursorVisible: true
            focus: tool.isEditing

            // Placeholder text when empty
            property string placeholderText: "Type here..."
            Text {
                anchors.fill: parent
                text: parent.placeholderText
                color: DV.PaletteBridge.active.mid
                font: parent.font
                visible: !parent.text && !parent.activeFocus
            }

            Keys.onReturnPressed: {
                tool.commitText();
            }

            Keys.onEnterPressed: {
                tool.commitText();
            }

            Keys.onEscapePressed: {
                tool.cancelText();
            }
        }

        // Cursor indicator (blinking line)
        Rectangle {
            id: cursor
            x: textInput.cursorRectangle.x
            y: textInput.cursorRectangle.y - textInput.font.pixelSize
            width: 2 / tool.zoomLevel
            height: textInput.font.pixelSize * 1.2
            color: DV.PaletteBridge.active.text
            visible: tool.isEditing && textInput.activeFocus

            SequentialAnimation on opacity {
                running: cursor.visible
                loops: Animation.Infinite
                NumberAnimation {
                    from: 1.0
                    to: 0.0
                    duration: 500
                }
                NumberAnimation {
                    from: 0.0
                    to: 1.0
                    duration: 500
                }
            }
        }
    }

    // Handle clicks for text placement
    function handleClick(canvasX, canvasY) {
        if (!tool.active)
            return;

        if (!tool.isEditing) {
            // First click: Start text input at this position
            tool.textX = canvasX;
            tool.textY = canvasY;
            tool.isEditing = true;
            textInput.text = "";
            textInput.forceActiveFocus();
        } else {
            // Second click while editing: Commit current text and start new one
            if (textInput.text.trim().length > 0) {
                tool.commitText();
            }
            // Start new text at clicked position
            tool.textX = canvasX;
            tool.textY = canvasY;
            tool.isEditing = true;
            textInput.text = "";
            textInput.forceActiveFocus();
        }
    }

    // Commit the text as a canvas item
    function commitText() {
        if (textInput.text.trim().length === 0) {
            tool.cancelText();
            return;
        }

        var fontFamily = settings ? settings.fontFamily : "Sans Serif";
        var fontSize = settings ? settings.fontSize : 16;
        var textColor = settings ? settings.textColor : "#ffffff";
        var textOpacity = settings ? (settings.textOpacity !== undefined ? settings.textOpacity : 1.0) : 1.0;

        // Store y as the top of the text (where it appears visually)
        // The preview positions text at textY - fontSize, so that's the top
        itemCompleted({
            type: "text",
            x: tool.textX,
            y: tool.textY - fontSize,
            text: textInput.text,
            fontFamily: fontFamily,
            fontSize: fontSize,
            textColor: textColor.toString(),
            textOpacity: textOpacity
        });

        // Reset state
        tool.isEditing = false;
        textInput.text = "";
    }

    // Cancel text input without creating an item
    function cancelText() {
        tool.isEditing = false;
        textInput.text = "";
    }

    // Handle mouse movement (no-op for text tool)
    function handleMouseMove(canvasX, canvasY, modifiers) {
    // Text tool doesn't need mouse move handling
    }

    // Reset tool state (called when switching tools)
    function reset() {
        if (tool.isEditing && textInput.text.trim().length > 0) {
            // Commit any pending text before switching
            tool.commitText();
        } else {
            tool.cancelText();
        }
    }
}

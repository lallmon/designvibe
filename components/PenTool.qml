import QtQuick

// Pen drawing tool component
Item {
    id: tool

    // Properties passed from Canvas
    property real zoomLevel: 1.0
    property bool active: false
    property var settings: null  // Tool settings object

    // Internal state
    property var points: []
    property var previewPoint: null
    property bool isClosed: false

    // How close the click must be to first point to close the path (canvas units)
    readonly property real closeThreshold: 6 / Math.max(zoomLevel, 0.0001)

    signal itemCompleted(var itemData)

    // Draw preview stroke and points
    Canvas {
        id: previewCanvas
        width: 20000
        height: 20000
        anchors.centerIn: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.resetTransform();
            ctx.clearRect(0, 0, width, height);

            if (tool.points.length === 0)
                return;

            var originX = width / 2;
            var originY = height / 2;
            var strokeWidth = settings && settings.strokeWidth !== undefined ? settings.strokeWidth : 1;
            var strokeColor = settings && settings.strokeColor ? settings.strokeColor : "#ffffff";
            var strokeOpacity = settings && settings.strokeOpacity !== undefined ? settings.strokeOpacity : 1.0;

            ctx.save();
            ctx.lineWidth = strokeWidth / Math.max(tool.zoomLevel, 0.0001);
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.globalAlpha = strokeOpacity;
            ctx.strokeStyle = strokeColor;
            ctx.beginPath();
            ctx.moveTo(originX + tool.points[0].x, originY + tool.points[0].y);
            for (var i = 1; i < tool.points.length; i++) {
                ctx.lineTo(originX + tool.points[i].x, originY + tool.points[i].y);
            }

            if (tool.previewPoint && !tool.isClosed) {
                ctx.lineTo(originX + tool.previewPoint.x, originY + tool.previewPoint.y);
            } else if (tool.isClosed) {
                ctx.closePath();
            }
            ctx.stroke();
            ctx.restore();
        }
    }

    // Draw control points
    Repeater {
        model: tool.points.length
        delegate: Rectangle {
            property var point: tool.points[index]
            width: 8 / Math.max(tool.zoomLevel, 0.0001)
            height: width
            radius: width / 2
            x: point.x - width / 2
            y: point.y - height / 2
            color: "#222222"
            border.color: "#ffffff"
            border.width: 1 / Math.max(tool.zoomLevel, 0.0001)
        }
    }

    function handleClick(canvasX, canvasY) {
        if (!tool.active)
            return;

        if (tool.isClosed) {
            return;
        }

        if (tool.points.length === 0) {
            tool.points = [
                {
                    x: canvasX,
                    y: canvasY
                }
            ];
            tool.previewPoint = null;
            previewCanvas.requestPaint();
            return;
        }

        if (tool.points.length >= 2 && tool._isNearFirst(canvasX, canvasY)) {
            tool.isClosed = true;
            tool._finalize();
            return;
        }

        var nextPoints = tool.points.slice();
        nextPoints.push({
            x: canvasX,
            y: canvasY
        });
        tool.points = nextPoints;
        tool.previewPoint = null;
        previewCanvas.requestPaint();
    }

    function handleMouseMove(canvasX, canvasY, modifiers) {
        if (!tool.active || tool.isClosed)
            return;
        tool.previewPoint = {
            x: canvasX,
            y: canvasY
        };
        previewCanvas.requestPaint();
    }

    function reset() {
        tool.points = [];
        tool.previewPoint = null;
        tool.isClosed = false;
        previewCanvas.requestPaint();
    }

    function _finalize() {
        if (tool.points.length < 2) {
            reset();
            return;
        }
        var s = settings || {};
        var strokeWidth = s.strokeWidth !== undefined ? s.strokeWidth : 1;
        var strokeColor = s.strokeColor || "#ffffff";
        var strokeOpacity = s.strokeOpacity !== undefined ? s.strokeOpacity : 1.0;
        itemCompleted({
            type: "path",
            points: tool.points,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            strokeOpacity: strokeOpacity,
            fillOpacity: 0.0,
            closed: true
        });
        reset();
    }

    function _isNearFirst(x, y) {
        if (tool.points.length === 0)
            return false;
        var first = tool.points[0];
        return Math.abs(first.x - x) <= tool.closeThreshold && Math.abs(first.y - y) <= tool.closeThreshold;
    }
}

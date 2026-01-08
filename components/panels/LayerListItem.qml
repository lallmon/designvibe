import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as Lucent

// Individual row item for the layer list
Item {
    id: delegateRoot

    // Parent references for accessing shared state
    required property var panel        // LayerPanel root
    required property var container    // layerContainer
    required property var flickable    // layerFlickable
    required property var repeater     // layerRepeater
    required property var column       // layerColumn

    // Model role properties (auto-bound from QAbstractListModel)
    required property int index
    required property string name
    required property string itemType
    required property int itemIndex
    required property var itemId      // Layer's unique ID (null for shapes)
    required property var parentId    // Parent layer ID (null for top-level items)
    required property bool modelVisible
    required property bool modelLocked

    readonly property SystemPalette themePalette: Lucent.Themed.palette

    // Model index is the source-of-truth for data operations.
    property int modelIndex: index
    // Visual order is reversed so top of the list is highest Z.
    property int displayIndex: repeater.count - 1 - modelIndex
    property bool isSelected: Lucent.SelectionManager.selectedIndices && Lucent.SelectionManager.selectedIndices.indexOf(modelIndex) !== -1
    property bool isBeingDragged: panel.draggedIndex === modelIndex
    property real dragOffsetY: 0
    property bool hasParent: !!parentId
    property bool isLayer: itemType === "layer"
    property bool isGroup: itemType === "group"
    property bool isContainer: isLayer || isGroup

    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined
    height: container.itemHeight
    y: displayIndex * (container.itemHeight + container.itemSpacing)

    transform: Translate {
        y: delegateRoot.dragOffsetY
    }
    z: isBeingDragged ? 100 : 0

    property bool isDropTarget: delegateRoot.isContainer && panel.draggedIndex >= 0 && panel.draggedItemType !== "layer" && panel.dropTargetContainerId === delegateRoot.itemId

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Lucent.Styles.rad.sm
        color: delegateRoot.isDropTarget ? themePalette.highlight : delegateRoot.isSelected ? themePalette.highlight : nameHoverHandler.hovered ? themePalette.midlight : "transparent"
        border.width: delegateRoot.isDropTarget ? 2 : 0
        border.color: themePalette.highlight

        Rectangle {
            // Separator between items; thickens and highlights when this is the insertion target
            property bool isInsertTarget: delegateRoot.displayIndex === panel.dropInsertIndex
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: isInsertTarget ? 3 : 1
            color: isInsertTarget ? themePalette.highlight : themePalette.mid
            visible: delegateRoot.displayIndex > 0 || isInsertTarget
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: delegateRoot.hasParent ? 20 : 4
            anchors.rightMargin: 8
            spacing: 4

            Item {
                id: dragHandle
                Layout.preferredWidth: 28
                Layout.fillHeight: true

                Lucent.PhIcon {
                    anchors.centerIn: parent
                    name: {
                        if (delegateRoot.itemType === "layer")
                            return "stack";
                        if (delegateRoot.itemType === "group")
                            return "folder-simple";
                        if (delegateRoot.itemType === "rectangle")
                            return "rectangle";
                        if (delegateRoot.itemType === "ellipse")
                            return "circle";
                        if (delegateRoot.itemType === "path")
                            return "pen-nib";
                        if (delegateRoot.itemType === "text")
                            return "text-t";
                        return "shapes";
                    }
                    size: 18
                    color: delegateRoot.isSelected ? themePalette.highlightedText : themePalette.text
                }

                DragHandler {
                    id: dragHandler
                    target: null
                    yAxis.enabled: true
                    xAxis.enabled: false

                    onActiveChanged: {
                        try {
                            if (active) {
                                panel.draggedIndex = delegateRoot.modelIndex;
                                panel.draggedItemType = delegateRoot.itemType;
                                panel.draggedItemParentId = delegateRoot.parentId;
                                container.dragStartContentY = flickable.contentY;
                                container.dragActive = true;
                                panel.autoScrollTimer.start();
                            } else {
                                container.dragActive = false;
                                panel.autoScrollTimer.stop();
                                if (panel.draggedIndex >= 0) {
                                    // Guard against empty model or stale indices after a reset
                                    if (repeater.count <= 0) {
                                        delegateRoot.dragOffsetY = 0;
                                        panel.draggedIndex = -1;
                                        panel.draggedItemType = "";
                                        panel.dropTargetContainerId = "";
                                        panel.draggedItemParentId = null;
                                        panel.dropTargetParentId = null;
                                        panel.dropInsertIndex = -1;
                                        return;
                                    }
                                    // Calculate target model index for potential reordering
                                    let totalItemHeight = container.itemHeight + container.itemSpacing;
                                    let indexDelta = Math.round(delegateRoot.dragOffsetY / totalItemHeight);
                                    let targetDisplayIndex = panel.dropInsertIndex >= 0 ? panel.dropInsertIndex : delegateRoot.displayIndex + indexDelta;
                                    let rowCount = repeater.count;
                                    targetDisplayIndex = Math.max(0, Math.min(rowCount - 1, targetDisplayIndex));
                                    let targetModelIndex = panel.modelIndexForDisplay(targetDisplayIndex);
                                    if (targetModelIndex < 0 || targetModelIndex >= rowCount) {
                                        delegateRoot.dragOffsetY = 0;
                                        panel.draggedIndex = -1;
                                        panel.draggedItemType = "";
                                        panel.dropTargetContainerId = "";
                                        panel.draggedItemParentId = null;
                                        panel.dropTargetParentId = null;
                                        panel.dropInsertIndex = -1;
                                        return;
                                    }

                                    // Determine the action based on drag context
                                    if (panel.dropTargetContainerId !== "" && panel.draggedItemType !== "layer") {
                                        // Check if dropping onto the SAME parent (sibling reorder, not reparent)
                                        if (panel.dropTargetContainerId === panel.draggedItemParentId) {
                                            // Same parent - just reorder within the container
                                            if (targetModelIndex !== panel.draggedIndex) {
                                                canvasModel.moveItem(panel.draggedIndex, targetModelIndex);
                                            }
                                        } else {
                                            // Different container - reparent to that container
                                            let insertModelIndex = targetModelIndex;
                                            canvasModel.reparentItem(panel.draggedIndex, panel.dropTargetContainerId, insertModelIndex);
                                        }
                                    } else if (panel.dropTargetParentId && panel.draggedItemType !== "layer") {
                                        // Dropping onto a gap between children of a layer
                                        const isSameParent = panel.draggedItemParentId === panel.dropTargetParentId;
                                        let insertModelIndex = targetModelIndex;
                                        if (isSameParent) {
                                            if (insertModelIndex !== panel.draggedIndex) {
                                                canvasModel.moveItem(panel.draggedIndex, insertModelIndex);
                                            }
                                        } else {
                                            canvasModel.reparentItem(panel.draggedIndex, panel.dropTargetParentId, insertModelIndex);
                                        }
                                    } else if (panel.draggedItemParentId && panel.dropTargetParentId === panel.draggedItemParentId) {
                                        // Dropping onto a sibling (same parent) - just reorder, keep parent
                                        if (targetModelIndex !== panel.draggedIndex) {
                                            canvasModel.moveItem(panel.draggedIndex, targetModelIndex);
                                        }
                                    } else if (panel.draggedItemParentId && !panel.dropTargetParentId && panel.dropTargetContainerId === "") {
                                        // Dropping a child onto a top-level item - unparent
                                        canvasModel.reparentItem(panel.draggedIndex, "", targetModelIndex);
                                    } else {
                                        // Normal z-order reordering for top-level items
                                        if (targetModelIndex !== panel.draggedIndex) {
                                            canvasModel.moveItem(panel.draggedIndex, targetModelIndex);
                                        }
                                    }
                                }
                                delegateRoot.dragOffsetY = 0;
                                panel.draggedIndex = -1;
                                panel.draggedItemType = "";
                                panel.dropTargetContainerId = "";
                                panel.draggedItemParentId = null;
                                panel.dropTargetParentId = null;
                                panel.dropInsertIndex = -1;
                            }
                        } catch (e) {
                            console.warn("LayerListItem drag error:", e);
                            // Reset state - guard against delegate destruction during model reset
                            if (typeof delegateRoot !== 'undefined' && delegateRoot) {
                                delegateRoot.dragOffsetY = 0;
                            }
                            if (typeof panel !== 'undefined' && panel) {
                                panel.draggedIndex = -1;
                                panel.draggedItemType = "";
                                panel.dropTargetContainerId = "";
                                panel.dropTargetContainerId = "";
                                panel.draggedItemParentId = null;
                                panel.dropTargetParentId = null;
                                panel.dropInsertIndex = -1;
                            }
                        }
                    }

                    onTranslationChanged: {
                        if (active) {
                            // Compensate for flickable contentY changes during auto-scroll
                            let compensatedY = translation.y + (flickable.contentY - container.dragStartContentY);
                            delegateRoot.dragOffsetY = compensatedY;
                            // Calculate which item we're hovering over
                            updateDropTarget();
                            // Auto-scroll handled via timer using scene position
                            const p = delegateRoot.mapToItem(flickable, 0, dragHandler.centroid.position.y);
                            panel.lastDragYInFlick = p.y;
                        }
                    }

                    function updateDropTarget() {
                        if (repeater.count === 0)
                            return;
                        if (!dragHandler.centroid || !dragHandler.centroid.position)
                            return;

                        // Use pointer position within the list to determine target row
                        const totalItemHeight = container.itemHeight + container.itemSpacing;
                        const rowCount = repeater.count;
                        const p = delegateRoot.mapToItem(column, 0, dragHandler.centroid.position.y);
                        let yInColumn = p.y;
                        // Clamp to column bounds
                        yInColumn = Math.max(0, Math.min(column.contentHeight - 1, yInColumn));

                        let targetDisplayIndex = Math.floor(yInColumn / totalItemHeight);
                        targetDisplayIndex = Math.max(0, Math.min(rowCount - 1, targetDisplayIndex));

                        // Calculate fractional position within the target row using absolute pointer
                        const positionInRow = yInColumn / totalItemHeight;
                        const fractionalPart = positionInRow - Math.floor(positionInRow);
                        const isLayerParentingZone = fractionalPart > 0.25 && fractionalPart < 0.75;

                        const targetModelIndex = panel.modelIndexForDisplay(targetDisplayIndex);
                        const targetItem = repeater.itemAt(targetModelIndex);
                        if (targetItem && targetItem.isContainer && panel.draggedItemType !== "layer" && isLayerParentingZone) {
                            // Center of a container - show as drop target for parenting
                            panel.dropTargetContainerId = targetItem.itemId;
                            panel.dropTargetParentId = null;
                            panel.dropInsertIndex = -1;
                        } else {
                            // Edge zone - show insertion indicator
                            panel.dropTargetContainerId = "";
                            panel.dropTargetParentId = targetItem ? targetItem.parentId : null;
                            // Insert indicator shows on the item below the insertion gap
                            if (fractionalPart >= 0.5) {
                                // Dropping below target row, indicator on next item
                                panel.dropInsertIndex = Math.min(targetDisplayIndex + 1, rowCount - 1);
                            } else {
                                // Dropping above target row, indicator on target item
                                panel.dropInsertIndex = targetDisplayIndex;
                            }
                            // Hide indicator when dragging over self or adjacent position (no move would occur)
                            const draggedDisplayIndex = delegateRoot.displayIndex;
                            if (panel.dropInsertIndex === draggedDisplayIndex || panel.dropInsertIndex === draggedDisplayIndex + 1) {
                                panel.dropInsertIndex = -1;
                            }
                        }
                    }
                }

                HoverHandler {
                    cursorShape: Qt.OpenHandCursor
                }
            }

            Item {
                id: nameEditor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80
                Layout.preferredWidth: 120
                implicitWidth: Math.max(80, nameLabel.implicitWidth)
                implicitHeight: nameLabel.implicitHeight
                property bool isEditing: false
                property string draftName: delegateRoot.name
                property string originalName: delegateRoot.name

                function startEditing() {
                    originalName = delegateRoot.name;
                    draftName = delegateRoot.name;
                    isEditing = true;
                    nameField.text = draftName;
                    nameField.selectAll();
                    nameField.forceActiveFocus();
                }

                function commitEditing() {
                    if (!isEditing)
                        return;
                    draftName = nameField.text;
                    isEditing = false;
                    if (draftName !== delegateRoot.name) {
                        canvasModel.renameItem(delegateRoot.modelIndex, draftName);
                    }
                    // Return focus to the list so global shortcuts (undo/redo) work
                    nameField.focus = false;
                    flickable.forceActiveFocus();
                }

                function cancelEditing() {
                    if (!isEditing)
                        return;
                    isEditing = false;
                    draftName = originalName;
                    nameField.text = originalName;
                    nameField.focus = false;
                    flickable.forceActiveFocus();
                }

                HoverHandler {
                    id: nameHoverHandler
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !nameEditor.isEditing
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    preventStealing: true
                    onClicked: function (mouse) {
                        if (mouse.button === Qt.RightButton) {
                            panel.setSelectionFromDelegate(delegateRoot.modelIndex, false);
                            itemContextMenu.popup();
                        } else {
                            panel.setSelectionFromDelegate(delegateRoot.modelIndex, mouse.modifiers & Qt.ControlModifier);
                        }
                    }
                    onDoubleClicked: function (mouse) {
                        panel.setSelectionFromDelegate(delegateRoot.modelIndex, mouse.modifiers & Qt.ControlModifier);
                        nameEditor.startEditing();
                    }

                    Menu {
                        id: itemContextMenu

                        Action {
                            text: qsTr("Rename")
                            onTriggered: nameEditor.startEditing()
                        }

                        Action {
                            text: qsTr("Export Layer...")
                            enabled: delegateRoot.itemType === "layer"
                            onTriggered: appController.openExportDialog(delegateRoot.itemId, delegateRoot.name || "Layer")
                        }

                        MenuSeparator {}

                        Action {
                            text: qsTr("Delete")
                            onTriggered: {
                                Lucent.SelectionManager.selectedIndices = [delegateRoot.modelIndex];
                                Lucent.SelectionManager.selectedItemIndex = delegateRoot.modelIndex;
                                Lucent.SelectionManager.selectedItem = canvasModel.getItemData(delegateRoot.modelIndex);
                                canvasModel.removeItem(delegateRoot.modelIndex);
                            }
                        }
                    }
                }

                Label {
                    id: nameLabel
                    visible: !nameEditor.isEditing
                    text: delegateRoot.name
                    font.pixelSize: 11
                    color: delegateRoot.isSelected ? themePalette.highlightedText : themePalette.text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.minimumWidth: 40
                }

                TextField {
                    id: nameField
                    visible: nameEditor.isEditing
                    text: nameEditor.draftName
                    font.pixelSize: 11
                    color: delegateRoot.isSelected ? themePalette.highlightedText : themePalette.text
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    padding: 0
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: "transparent"
                        border.color: "transparent"
                    }

                    Keys.onEscapePressed: nameEditor.cancelEditing()
                    onAccepted: nameEditor.commitEditing()
                    onActiveFocusChanged: {
                        if (!activeFocus && nameEditor.isEditing) {
                            nameEditor.cancelEditing();
                        }
                    }
                    onTextChanged: nameEditor.draftName = text
                    Keys.onPressed: function (event) {
                        if (nameEditor.isEditing)
                            return;
                        if (event.matches(StandardKey.Undo)) {
                            if (canvasModel) {
                                canvasModel.undo();
                            }
                            event.accepted = true;
                        } else if (event.matches(StandardKey.Redo)) {
                            if (canvasModel) {
                                canvasModel.redo();
                            }
                            event.accepted = true;
                        }
                    }
                }
            }

            Item {
                id: visibilityButton
                Layout.preferredWidth: 28
                Layout.fillHeight: true

                HoverHandler {
                    id: visibilityHover
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    preventStealing: true
                    onClicked: {
                        canvasModel.toggleVisibility(delegateRoot.modelIndex);
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: visibilityHover.hovered ? themePalette.midlight : "transparent"
                    radius: Lucent.Styles.rad.sm

                    Lucent.PhIcon {
                        anchors.centerIn: parent
                        name: delegateRoot.modelVisible ? "eye" : "eye-closed"
                        size: 16
                        color: delegateRoot.isSelected ? themePalette.highlightedText : themePalette.text
                    }
                }
            }

            Item {
                id: lockButton
                Layout.preferredWidth: 28
                Layout.fillHeight: true

                HoverHandler {
                    id: lockHover
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    preventStealing: true
                    onClicked: {
                        canvasModel.toggleLocked(delegateRoot.modelIndex);
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: lockHover.hovered ? themePalette.midlight : "transparent"
                    radius: Lucent.Styles.rad.sm

                    Lucent.PhIcon {
                        anchors.centerIn: parent
                        name: delegateRoot.modelLocked ? "lock" : "lock-open"
                        size: 16
                        color: delegateRoot.isSelected ? themePalette.highlightedText : themePalette.text
                    }
                }
            }

            Item {
                id: deleteButton
                Layout.preferredWidth: 28
                Layout.fillHeight: true

                HoverHandler {
                    id: deleteHover
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    preventStealing: true
                    onClicked: {
                        // Ensure selection reflects the target being deleted
                        Lucent.SelectionManager.selectedIndices = [delegateRoot.modelIndex];
                        Lucent.SelectionManager.selectedItemIndex = delegateRoot.modelIndex;
                        Lucent.SelectionManager.selectedItem = canvasModel.getItemData(delegateRoot.modelIndex);
                        canvasModel.removeItem(delegateRoot.modelIndex);
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: deleteHover.hovered ? themePalette.midlight : "transparent"
                    radius: Lucent.Styles.rad.sm

                    Lucent.PhIcon {
                        anchors.centerIn: parent
                        name: "trash"
                        size: 16
                        color: delegateRoot.isSelected ? themePalette.highlightedText : themePalette.text
                    }
                }
            }
        }
    }

    Behavior on dragOffsetY {
        enabled: !delegateRoot.isBeingDragged
        NumberAnimation {
            duration: 100
        }
    }
}

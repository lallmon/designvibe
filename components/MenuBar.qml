import QtQuick
import QtQuick.Controls
import "." as DV

// Main menu bar component
MenuBar {
    id: root

    // Property to reference the viewport for zoom operations
    property var viewport: null

    Menu {
        title: qsTr("&File")
        Action {
            text: qsTr("E&xit (Ctrl+Q)")
            shortcut: StandardKey.Quit
            onTriggered: Qt.quit()
        }
    }

    Menu {
        title: qsTr("&Edit")
        Action {
            text: qsTr("&Undo (Ctrl+Z)")
            shortcut: StandardKey.Undo
            enabled: canvasModel ? canvasModel.canUndo : false
            onTriggered: if (canvasModel)
                canvasModel.undo()
        }
        Action {
            text: qsTr("&Redo (Ctrl+Shift+Z)")
            shortcut: StandardKey.Redo
            enabled: canvasModel ? canvasModel.canRedo : false
            onTriggered: if (canvasModel)
                canvasModel.redo()
        }
        Action {
            text: qsTr("&Group Selection (Ctrl+G)")
            shortcut: "Ctrl+G"
            enabled: canvasModel && ((DV.SelectionManager.selectedIndices && DV.SelectionManager.selectedIndices.length > 0) || DV.SelectionManager.selectedItemIndex >= 0)
            onTriggered: {
                if (!canvasModel)
                    return;
                let indices = [];
                if (DV.SelectionManager.selectedIndices && DV.SelectionManager.selectedIndices.length > 0) {
                    indices = DV.SelectionManager.selectedIndices.slice();
                } else if (DV.SelectionManager.selectedItemIndex >= 0) {
                    indices = [DV.SelectionManager.selectedItemIndex];
                }
                if (indices.length === 0)
                    return;
                indices.sort(function (a, b) {
                    return a - b;
                });
                const first = indices[0];
                const firstData = canvasModel.getItemData(first);
                if (!firstData)
                    return;
                const parentId = firstData.parentId ? firstData.parentId : "";
                canvasModel.addItem({
                    "type": "group",
                    "parentId": parentId
                });
                const groupIndex = canvasModel.count() - 1;
                const insertAt = first;
                canvasModel.moveItem(groupIndex, insertAt);
                const groupData = canvasModel.getItemData(insertAt);
                const groupId = groupData ? groupData.id : null;
                if (groupId !== null) {
                    for (let k = 0; k < indices.length; k++) {
                        const orig = indices[k];
                        const currentIndex = orig >= insertAt ? orig + 1 : orig;
                        canvasModel.reparentItem(currentIndex, groupId);
                    }
                    // Find the group index in case reparenting changed positions
                    let finalGroupIndex = insertAt;
                    for (let i = 0; i < canvasModel.count(); i++) {
                        const data = canvasModel.getItemData(i);
                        if (data && data.type === "group" && data.id === groupId) {
                            finalGroupIndex = i;
                            break;
                        }
                    }
                    DV.SelectionManager.selectedIndices = [finalGroupIndex];
                    DV.SelectionManager.selectedItemIndex = finalGroupIndex;
                    DV.SelectionManager.selectedItem = canvasModel.getItemData(finalGroupIndex);
                }
            }
        }
        Action {
            text: qsTr("&Ungroup (Ctrl+Shift+G)")
            shortcut: "Ctrl+Shift+G"
            enabled: canvasModel && DV.SelectionManager.selectedItem && DV.SelectionManager.selectedItem.type === "group"
            onTriggered: {
                if (!canvasModel)
                    return;
                const groupIndex = DV.SelectionManager.selectedItemIndex;
                if (groupIndex < 0)
                    return;
                const groupData = canvasModel.getItemData(groupIndex);
                if (!groupData || groupData.type !== "group")
                    return;
                canvasModel.ungroup(groupIndex);
                DV.SelectionManager.selectedItemIndex = -1;
                DV.SelectionManager.selectedItem = null;
            }
        }
    }

    Menu {
        title: qsTr("&View")
        Action {
            text: qsTr("Zoom &In (Ctrl++)")
            shortcut: StandardKey.ZoomIn
            onTriggered: {
                if (root.viewport) {
                    root.viewport.zoomIn();
                }
            }
        }
        Action {
            text: qsTr("Zoom &Out (Ctrl+-)")
            shortcut: StandardKey.ZoomOut
            onTriggered: {
                if (root.viewport) {
                    root.viewport.zoomOut();
                }
            }
        }
        Action {
            text: qsTr("&Reset Zoom (Ctrl+0)")
            shortcut: "Ctrl+0"
            onTriggered: {
                if (root.viewport) {
                    root.viewport.resetZoom();
                }
            }
        }
    }
}

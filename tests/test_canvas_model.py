"""Unit tests for canvas_model module."""

from lucent.canvas_items import (
    RectangleItem,
    EllipseItem,
    LayerItem,
    PathItem,
    TextItem,
)
from lucent.commands import DEFAULT_DUPLICATE_OFFSET
from tests.test_helpers import (
    make_rectangle,
    make_ellipse,
    make_path,
    make_layer,
    make_text,
)


class TestCanvasModelBasics:
    """Tests for basic CanvasModel operations."""

    def test_initial_state_empty(self, canvas_model):
        """Test that a new CanvasModel starts empty."""
        assert canvas_model.count() == 0
        assert canvas_model.getItems() == []

    def test_add_rectangle_item(self, canvas_model, qtbot):
        """Test adding a rectangle item to the model."""
        item_data = make_rectangle(
            x=10, y=20, width=100, height=50, stroke_color="#ff0000"
        )

        with qtbot.waitSignal(canvas_model.itemAdded, timeout=1000) as blocker:
            canvas_model.addItem(item_data)

        assert canvas_model.count() == 1
        assert blocker.args == [0]

        items = canvas_model.getItems()
        assert len(items) == 1
        assert isinstance(items[0], RectangleItem)
        assert items[0].geometry.x == 10
        assert items[0].geometry.y == 20

    def test_add_ellipse_item(self, canvas_model, qtbot):
        """Test adding an ellipse item to the model."""
        item_data = make_ellipse(center_x=50, center_y=75, radius_x=30, radius_y=20)

        with qtbot.waitSignal(canvas_model.itemAdded, timeout=1000) as blocker:
            canvas_model.addItem(item_data)

        assert canvas_model.count() == 1
        assert blocker.args == [0]

        items = canvas_model.getItems()
        assert len(items) == 1
        assert isinstance(items[0], EllipseItem)
        assert items[0].geometry.center_x == 50
        assert items[0].geometry.center_y == 75

    def test_add_multiple_items(self, canvas_model, qtbot):
        """Test adding multiple items maintains correct order."""
        canvas_model.addItem(make_rectangle(x=0, y=0, width=10, height=10))
        canvas_model.addItem(
            make_ellipse(center_x=20, center_y=20, radius_x=5, radius_y=5)
        )

        assert canvas_model.count() == 2
        items = canvas_model.getItems()
        assert isinstance(items[0], RectangleItem)
        assert isinstance(items[1], EllipseItem)

    def test_add_path_item(self, canvas_model, qtbot):
        """Test adding a path item to the model."""
        item_data = make_path(
            points=[{"x": 0, "y": 0}, {"x": 10, "y": 0}, {"x": 10, "y": 10}],
            closed=True,
            stroke_width=1.5,
        )

        with qtbot.waitSignal(canvas_model.itemAdded, timeout=1000):
            canvas_model.addItem(item_data)

        assert canvas_model.count() == 1
        items = canvas_model.getItems()
        assert isinstance(items[0], PathItem)
        assert items[0].geometry.closed is True

    def test_add_unknown_item_type_ignored(self, canvas_model, qtbot):
        """Test that adding an unknown item type is safely ignored."""
        item_data = {"type": "triangle", "x": 0, "y": 0}
        canvas_model.addItem(item_data)
        assert canvas_model.count() == 0

    def test_data_invalid_index_returns_none(self, canvas_model):
        """Test that data() returns None for invalid index."""
        canvas_model.addItem(make_rectangle())
        index = canvas_model.index(999, 0)
        assert canvas_model.data(index, canvas_model.NameRole) is None


class TestCanvasModelRemove:
    """Tests for removing items from CanvasModel."""

    def test_remove_item(self, canvas_model, qtbot):
        """Test removing an item by index."""
        canvas_model.addItem(make_rectangle(name="Rect1"))
        canvas_model.addItem(make_ellipse(name="Ellipse1"))

        with qtbot.waitSignal(canvas_model.itemRemoved, timeout=1000) as blocker:
            canvas_model.removeItem(0)

        assert canvas_model.count() == 1
        assert blocker.args == [0]
        assert canvas_model.getItems()[0].name == "Ellipse1"

    def test_remove_invalid_index_no_op(self, canvas_model):
        """Test that removing invalid index does nothing."""
        canvas_model.addItem(make_rectangle())
        canvas_model.removeItem(999)
        assert canvas_model.count() == 1


class TestCanvasModelUpdate:
    """Tests for updating items in CanvasModel."""

    def test_update_item(self, canvas_model, qtbot):
        """Test updating an item's properties."""
        canvas_model.addItem(
            make_rectangle(x=0, y=0, width=10, height=10, name="Original")
        )

        new_data = make_rectangle(x=50, y=50, width=20, height=20, name="Updated")

        with qtbot.waitSignal(canvas_model.itemModified, timeout=1000):
            canvas_model.updateItem(0, new_data)

        item = canvas_model.getItems()[0]
        assert item.geometry.x == 50
        assert item.name == "Updated"


class TestCanvasModelDataRoles:
    """Tests for data roles in CanvasModel."""

    def test_name_role(self, canvas_model):
        """Test NameRole returns correct name."""
        canvas_model.addItem(make_rectangle(name="MyRect"))
        index = canvas_model.index(0, 0)
        assert canvas_model.data(index, canvas_model.NameRole) == "MyRect"

    def test_type_role(self, canvas_model):
        """Test TypeRole returns correct type."""
        canvas_model.addItem(make_rectangle())
        index = canvas_model.index(0, 0)
        assert canvas_model.data(index, canvas_model.TypeRole) == "rectangle"

    def test_visible_role(self, canvas_model):
        """Test VisibleRole returns correct visibility."""
        canvas_model.addItem(make_rectangle(visible=False))
        index = canvas_model.index(0, 0)
        assert canvas_model.data(index, canvas_model.VisibleRole) is False

    def test_locked_role(self, canvas_model):
        """Test LockedRole returns correct locked state."""
        canvas_model.addItem(make_rectangle(locked=True))
        index = canvas_model.index(0, 0)
        assert canvas_model.data(index, canvas_model.LockedRole) is True


class TestCanvasModelBoundingBox:
    """Tests for bounding box calculations."""

    def test_rectangle_bounding_box(self, canvas_model):
        """Test bounding box for rectangle."""
        canvas_model.addItem(make_rectangle(x=10, y=20, width=100, height=50))
        bbox = canvas_model.getBoundingBox(0)
        assert bbox == {"x": 10.0, "y": 20.0, "width": 100.0, "height": 50.0}

    def test_ellipse_bounding_box(self, canvas_model):
        """Test bounding box for ellipse."""
        canvas_model.addItem(
            make_ellipse(center_x=100, center_y=100, radius_x=50, radius_y=30)
        )
        bbox = canvas_model.getBoundingBox(0)
        assert bbox == {"x": 50.0, "y": 70.0, "width": 100.0, "height": 60.0}

    def test_path_bounding_box(self, canvas_model):
        """Test bounding box for path."""
        canvas_model.addItem(
            make_path(points=[{"x": -2, "y": 3}, {"x": 4, "y": 5}, {"x": 1, "y": -1}])
        )
        bbox = canvas_model.getBoundingBox(0)
        assert bbox == {"x": -2.0, "y": -1.0, "width": 6.0, "height": 6.0}


class TestCanvasModelLayers:
    """Tests for layer functionality."""

    def test_add_layer(self, canvas_model, qtbot):
        """Test adding a layer."""
        layer_data = make_layer(name="Background")

        with qtbot.waitSignal(canvas_model.itemAdded, timeout=1000):
            canvas_model.addItem(layer_data)

        assert canvas_model.count() == 1
        items = canvas_model.getItems()
        assert isinstance(items[0], LayerItem)
        assert items[0].name == "Background"

    def test_items_with_parent_layer(self, canvas_model):
        """Test items can reference a parent layer."""
        canvas_model.addItem(make_layer(name="Layer1", layer_id="layer-1"))
        canvas_model.addItem(make_rectangle(name="Rect1", parent_id="layer-1"))

        items = canvas_model.getItems()
        assert items[1].parent_id == "layer-1"


class TestCanvasModelRenderItems:
    """Tests for render item ordering."""

    def test_render_items_respects_visibility(self, canvas_model):
        """Invisible items should not be in render items."""
        canvas_model.addItem(make_rectangle(visible=True))
        canvas_model.addItem(make_rectangle(visible=False))

        render_items = canvas_model.getRenderItems()
        assert len(render_items) == 1

    def test_render_items_order(self, canvas_model):
        """Render items should be in model order."""
        canvas_model.addItem(make_path(points=[{"x": 0, "y": 0}, {"x": 10, "y": 0}]))
        canvas_model.addItem(make_rectangle())

        items = canvas_model.getRenderItems()
        assert len(items) == 2
        assert isinstance(items[0], PathItem)
        assert isinstance(items[1], RectangleItem)


class TestCanvasModelClear:
    """Tests for clearing the model."""

    def test_clear_removes_all_items(self, canvas_model, qtbot):
        """Test that clear removes all items."""
        canvas_model.addItem(make_rectangle())
        canvas_model.addItem(make_ellipse())
        canvas_model.addItem(make_path(points=[{"x": 0, "y": 0}, {"x": 1, "y": 1}]))

        with qtbot.waitSignal(canvas_model.modelReset, timeout=1000):
            canvas_model.clear()

        assert canvas_model.count() == 0


class TestCanvasModelDuplicate:
    """Tests for duplicating items."""

    def test_duplicate_rectangle(self, canvas_model, qtbot):
        """Test duplicating a rectangle creates offset copy."""
        canvas_model.addItem(
            make_rectangle(x=10, y=20, width=50, height=30, name="Original")
        )

        with qtbot.waitSignal(canvas_model.itemAdded, timeout=1000):
            canvas_model.duplicateItem(0)

        assert canvas_model.count() == 2
        items = canvas_model.getItems()
        # Duplicate should be offset
        assert items[1].geometry.x == 10 + DEFAULT_DUPLICATE_OFFSET
        assert items[1].geometry.y == 20 + DEFAULT_DUPLICATE_OFFSET


class TestCanvasModelMoveItems:
    """Tests for moving items in the model order."""

    def test_move_item_up(self, canvas_model):
        """Test moving an item up in the order."""
        canvas_model.addItem(make_rectangle(name="A"))
        canvas_model.addItem(make_rectangle(name="B"))
        canvas_model.addItem(make_rectangle(name="C"))

        canvas_model.moveItem(2, 0)

        items = canvas_model.getItems()
        assert items[0].name == "C"
        assert items[1].name == "A"
        assert items[2].name == "B"


class TestCanvasModelText:
    """Tests for text items in the model."""

    def test_add_text_item(self, canvas_model, qtbot):
        """Test adding a text item."""
        item_data = make_text(x=10, y=20, text="Hello World", font_size=24)

        with qtbot.waitSignal(canvas_model.itemAdded, timeout=1000):
            canvas_model.addItem(item_data)

        assert canvas_model.count() == 1
        items = canvas_model.getItems()
        assert isinstance(items[0], TextItem)
        assert items[0].text == "Hello World"
        assert items[0].font_size == 24


class TestCanvasModelItemData:
    """Tests for getItemData method."""

    def test_get_item_data_rectangle(self, canvas_model):
        """Test getItemData returns dictionary for rectangle."""
        canvas_model.addItem(
            make_rectangle(x=10, y=20, width=100, height=50, name="MyRect")
        )

        data = canvas_model.getItemData(0)
        assert data["type"] == "rectangle"
        assert data["name"] == "MyRect"
        assert data["geometry"]["x"] == 10
        assert data["geometry"]["width"] == 100

    def test_get_item_data_invalid_index(self, canvas_model):
        """Test getItemData returns None for invalid index."""
        assert canvas_model.getItemData(999) is None


class TestCanvasModelVisibility:
    """Tests for visibility toggling."""

    def test_toggle_visibility(self, canvas_model, qtbot):
        """Test toggling item visibility."""
        canvas_model.addItem(make_rectangle(visible=True))

        with qtbot.waitSignal(canvas_model.itemModified, timeout=1000):
            canvas_model.toggleVisibility(0)

        items = canvas_model.getItems()
        assert items[0].visible is False


class TestCanvasModelLock:
    """Tests for lock toggling."""

    def test_toggle_lock(self, canvas_model, qtbot):
        """Test toggling item lock state."""
        canvas_model.addItem(make_rectangle(locked=False))

        with qtbot.waitSignal(canvas_model.itemModified, timeout=1000):
            canvas_model.toggleLocked(0)

        items = canvas_model.getItems()
        assert items[0].locked is True

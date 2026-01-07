"""Unit tests for exporter module."""

from PySide6.QtCore import QRectF
from PySide6.QtGui import QImage
import xml.etree.ElementTree as ET

from lucent.canvas_items import (
    RectangleItem,
    EllipseItem,
    PathItem,
    LayerItem,
)
from lucent.geometry import RectGeometry, EllipseGeometry, PolylineGeometry
from lucent.appearances import Fill, Stroke
from lucent.exporter import ExportOptions, export_png, export_svg, compute_bounds


def make_rect_item(
    x=0,
    y=0,
    width=10,
    height=10,
    fill_color="#ffffff",
    fill_opacity=0.0,
    stroke_color="#ffffff",
    stroke_width=1.0,
):
    """Helper to create RectangleItem."""
    geometry = RectGeometry(x=x, y=y, width=width, height=height)
    appearances = [
        Fill(color=fill_color, opacity=fill_opacity),
        Stroke(color=stroke_color, width=stroke_width),
    ]
    return RectangleItem(geometry=geometry, appearances=appearances)


def make_ellipse_item(
    cx=0,
    cy=0,
    rx=10,
    ry=10,
    fill_color="#ffffff",
    fill_opacity=0.0,
    stroke_color="#ffffff",
    stroke_width=1.0,
):
    """Helper to create EllipseItem."""
    geometry = EllipseGeometry(center_x=cx, center_y=cy, radius_x=rx, radius_y=ry)
    appearances = [
        Fill(color=fill_color, opacity=fill_opacity),
        Stroke(color=stroke_color, width=stroke_width),
    ]
    return EllipseItem(geometry=geometry, appearances=appearances)


def make_path_item(
    points,
    closed=False,
    fill_color="#ffffff",
    fill_opacity=0.0,
    stroke_color="#ffffff",
    stroke_width=1.0,
):
    """Helper to create PathItem."""
    geometry = PolylineGeometry(points=points, closed=closed)
    appearances = [
        Fill(color=fill_color, opacity=fill_opacity),
        Stroke(color=stroke_color, width=stroke_width),
    ]
    return PathItem(geometry=geometry, appearances=appearances)


class TestExportOptions:
    """Tests for ExportOptions dataclass."""

    def test_default_values(self):
        """ExportOptions has sensible defaults."""
        opts = ExportOptions()
        assert opts.document_dpi == 72
        assert opts.target_dpi == 72
        assert opts.padding == 0.0
        assert opts.background is None

    def test_custom_values(self):
        """ExportOptions accepts custom values."""
        opts = ExportOptions(
            document_dpi=72, target_dpi=300, padding=10.0, background="#ffffff"
        )
        assert opts.document_dpi == 72
        assert opts.target_dpi == 300
        assert opts.padding == 10.0
        assert opts.background == "#ffffff"

    def test_scale_property_computes_ratio(self):
        """scale property returns target_dpi / document_dpi."""
        opts = ExportOptions(document_dpi=72, target_dpi=144)
        assert opts.scale == 2.0


class TestComputeBounds:
    """Tests for compute_bounds helper function."""

    def test_single_item(self):
        """compute_bounds returns bounds of single item."""
        items = [make_rect_item(x=10, y=20, width=100, height=50)]
        bounds = compute_bounds(items, padding=0)
        assert bounds == QRectF(10, 20, 100, 50)

    def test_multiple_items(self):
        """compute_bounds returns combined bounds of all items."""
        items = [
            make_rect_item(x=0, y=0, width=50, height=50),
            make_rect_item(x=100, y=100, width=50, height=50),
        ]
        bounds = compute_bounds(items, padding=0)
        assert bounds == QRectF(0, 0, 150, 150)

    def test_with_padding(self):
        """compute_bounds adds padding to all sides."""
        items = [make_rect_item(x=10, y=10, width=80, height=80)]
        bounds = compute_bounds(items, padding=10)
        assert bounds == QRectF(0, 0, 100, 100)

    def test_empty_items(self):
        """compute_bounds returns empty rect for no items."""
        bounds = compute_bounds([], padding=0)
        assert bounds.isEmpty()

    def test_items_with_empty_bounds(self):
        """compute_bounds returns empty rect when all items have empty bounds."""
        items = [LayerItem(name="Empty Layer")]
        bounds = compute_bounds(items, padding=0)
        assert bounds.isEmpty()


class TestExportPng:
    """Tests for PNG export functionality."""

    def test_export_creates_file(self, tmp_path, qtbot):
        """export_png creates a PNG file at the specified path."""
        items = [make_rect_item(x=0, y=0, width=100, height=100)]
        bounds = QRectF(0, 0, 100, 100)
        output_path = tmp_path / "test.png"

        result = export_png(items, bounds, output_path, ExportOptions())

        assert result is True
        assert output_path.exists()

    def test_export_correct_dimensions(self, tmp_path, qtbot):
        """export_png creates image with correct dimensions."""
        items = [make_rect_item(x=0, y=0, width=100, height=50)]
        bounds = QRectF(0, 0, 100, 50)
        output_path = tmp_path / "test.png"

        export_png(items, bounds, output_path, ExportOptions())

        img = QImage(str(output_path))
        assert img.width() == 100
        assert img.height() == 50

    def test_export_with_scale(self, tmp_path, qtbot):
        """export_png scales output for higher DPI."""
        items = [make_rect_item(x=0, y=0, width=100, height=100)]
        bounds = QRectF(0, 0, 100, 100)
        output_path = tmp_path / "test.png"
        opts = ExportOptions(document_dpi=72, target_dpi=144)  # 2x scale

        export_png(items, bounds, output_path, opts)

        img = QImage(str(output_path))
        assert img.width() == 200
        assert img.height() == 200

    def test_export_empty_items_returns_false(self, tmp_path, qtbot):
        """export_png returns False for empty bounds."""
        bounds = QRectF()  # Empty
        output_path = tmp_path / "test.png"

        result = export_png([], bounds, output_path, ExportOptions())

        assert result is False


class TestExportSvg:
    """Tests for SVG export functionality."""

    def test_export_creates_file(self, tmp_path, qtbot):
        """export_svg creates an SVG file at the specified path."""
        items = [make_rect_item(x=0, y=0, width=100, height=100)]
        bounds = QRectF(0, 0, 100, 100)
        output_path = tmp_path / "test.svg"

        result = export_svg(items, bounds, output_path, ExportOptions())

        assert result is True
        assert output_path.exists()

    def test_export_valid_svg(self, tmp_path, qtbot):
        """export_svg creates valid XML."""
        items = [make_rect_item(x=0, y=0, width=100, height=100)]
        bounds = QRectF(0, 0, 100, 100)
        output_path = tmp_path / "test.svg"

        export_svg(items, bounds, output_path, ExportOptions())

        # Should parse without error
        tree = ET.parse(output_path)
        root = tree.getroot()
        # SVG namespace check
        assert "svg" in root.tag

    def test_export_correct_viewbox(self, tmp_path, qtbot):
        """export_svg sets correct viewBox."""
        items = [make_rect_item(x=10, y=20, width=100, height=50)]
        bounds = QRectF(10, 20, 100, 50)
        output_path = tmp_path / "test.svg"

        export_svg(items, bounds, output_path, ExportOptions())

        tree = ET.parse(output_path)
        root = tree.getroot()
        viewbox = root.get("viewBox")
        assert viewbox is not None
        # viewBox should be "0 0 100 50" (translated to origin)
        parts = viewbox.split()
        assert len(parts) == 4
        assert float(parts[2]) == 100  # width
        assert float(parts[3]) == 50  # height

    def test_export_empty_items_returns_false(self, tmp_path, qtbot):
        """export_svg returns False for empty bounds."""
        bounds = QRectF()  # Empty
        output_path = tmp_path / "test.svg"

        result = export_svg([], bounds, output_path, ExportOptions())

        assert result is False

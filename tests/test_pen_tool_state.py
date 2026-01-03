"""Unit tests for pen_tool_state module."""

from lucent.pen_tool_state import PenToolState


def test_add_points_and_preview_segment():
    state = PenToolState()
    state.add_point(0, 0)
    state.add_point(10, 0)

    # Preview should reference last point to cursor
    preview = state.preview_to(12, 4)
    assert preview == ((10.0, 0.0), (12.0, 4.0))
    assert state.points == [(0.0, 0.0), (10.0, 0.0)]


def test_close_on_first_point_creates_closed_path():
    state = PenToolState()
    state.add_point(0, 0)
    state.add_point(10, 0)
    state.add_point(10, 10)

    closed = state.try_close_on(0, 0)
    assert closed is True
    assert state.closed is True
    assert state.points == [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0)]


def test_reset_clears_state():
    state = PenToolState()
    state.add_point(0, 0)
    state.preview_to(1, 1)
    state.reset()
    assert state.points == []
    assert state.closed is False
    assert state.preview_point is None


def test_to_item_data_includes_stroke_only_defaults():
    state = PenToolState()
    state.add_point(0, 0)
    state.add_point(5, 0)
    state.try_close_on(0, 0)

    data = state.to_item_data(
        {"strokeWidth": 2, "strokeColor": "#ff00ff", "strokeOpacity": 0.75}
    )
    assert data["type"] == "path"
    assert data["strokeWidth"] == 2
    assert data["strokeColor"] == "#ff00ff"
    assert data["strokeOpacity"] == 0.75
    assert data["fillOpacity"] == 0.0
    assert data["closed"] is True
    assert data["points"][0] == {"x": 0.0, "y": 0.0}

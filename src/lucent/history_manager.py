# Copyright (C) 2026 The Culture List, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

"""Undo/redo orchestration as a QObject for QML exposure."""

from __future__ import annotations

from typing import List, Optional

from PySide6.QtCore import QObject, Signal, Slot, Property

from lucent.commands import Command, TransactionCommand


class HistoryManager(QObject):
    """Maintains undo/redo stacks and transaction grouping."""

    undoStackChanged = Signal()
    redoStackChanged = Signal()

    def __init__(self, parent: Optional[QObject] = None) -> None:
        super().__init__(parent)
        self._undo_stack: List[Command] = []
        self._redo_stack: List[Command] = []
        self._transaction_commands: Optional[List[Command]] = None
        self._transaction_label: str = "Edit"

    # --- Python properties (for internal/test use) ---

    @property
    def can_undo(self) -> bool:
        return len(self._undo_stack) > 0

    @property
    def can_redo(self) -> bool:
        return len(self._redo_stack) > 0

    # --- Qt Properties (for QML binding) ---

    def _canUndo(self) -> bool:
        return len(self._undo_stack) > 0

    canUndo = Property(bool, _canUndo, notify=undoStackChanged)

    def _canRedo(self) -> bool:
        return len(self._redo_stack) > 0

    canRedo = Property(bool, _canRedo, notify=redoStackChanged)

    def _undoDescriptions(self) -> list:
        return [cmd.description for cmd in self._undo_stack]

    undoDescriptions = Property(
        "QVariantList",  # type: ignore[arg-type]
        _undoDescriptions,
        notify=undoStackChanged,
    )

    def _redoDescriptions(self) -> list:
        return [cmd.description for cmd in self._redo_stack]

    redoDescriptions = Property(
        "QVariantList",  # type: ignore[arg-type]
        _redoDescriptions,
        notify=redoStackChanged,
    )

    # --- Command execution ---

    def execute(self, command: Command) -> None:
        """Execute a command, recording it for undo unless inside a transaction."""
        command.execute()

        if self._transaction_commands is not None:
            self._transaction_commands.append(command)
            return

        self._undo_stack.append(command)
        if self._redo_stack:
            self._redo_stack.clear()
            self.redoStackChanged.emit()
        self.undoStackChanged.emit()

    @Slot(result=bool)
    def undo(self) -> bool:
        """Undo the most recent command."""
        if not self._undo_stack:
            return False
        command = self._undo_stack.pop()
        command.undo()
        self._redo_stack.append(command)
        self.undoStackChanged.emit()
        self.redoStackChanged.emit()
        return True

    @Slot(result=bool)
    def redo(self) -> bool:
        """Redo the most recently undone command."""
        if not self._redo_stack:
            return False
        command = self._redo_stack.pop()
        command.execute()
        self._undo_stack.append(command)
        self.undoStackChanged.emit()
        self.redoStackChanged.emit()
        return True

    # --- Transaction support ---

    def begin_transaction(self, label: str = "Edit") -> None:
        """Start grouping subsequent executes into a single transaction."""
        if self._transaction_commands is not None:
            return  # ignore nested calls
        self._transaction_commands = []
        self._transaction_label = label

    def end_transaction(self) -> None:
        """Finish transaction, pushing grouped commands as one undo step."""
        if self._transaction_commands is None:
            return

        if not self._transaction_commands:
            # Empty transaction: no-op
            self._transaction_commands = None
            return

        txn = TransactionCommand(self._transaction_commands, self._transaction_label)
        self._transaction_commands = None

        self._undo_stack.append(txn)
        if self._redo_stack:
            self._redo_stack.clear()
            self.redoStackChanged.emit()
        self.undoStackChanged.emit()

import * as cheetahGrid from "cheetah-grid";

// Inject dropdown CSS (once)
(function() {
  if (!document.getElementById("autocomplete-editor-styles")) {
    const style = document.createElement("style");
    style.id = "autocomplete-editor-styles";
    style.textContent = `
      .autocomplete-dropdown {
        margin: 0;
        padding: 0;
        list-style: none;
        background-color: white;
        border: 1px solid #ccc;
      }
      .autocomplete-dropdown li {
        padding: 4px 8px;
        cursor: pointer;
      }
      .autocomplete-dropdown li:hover {
        background-color: #f5f5f5;
      }
      .autocomplete-dropdown li.active {
        background-color: #e0e0e0;
      }
    `;
    document.head.appendChild(style);
  }
})();

export class AutocompleteEditor extends cheetahGrid.columns.action.InlineInputEditor {
  constructor(options = {}) {
    super(options);
    this.options = options.autocompleteOptions || [];
    this._filteredOptions = [];
    this._dropdown = null;
    this._input = null;
    this._grid = null;
    this._cell = null;
  }

  clone() {
    return new AutocompleteEditor({
      autocompleteOptions: this.options,
      classList: this._classList,
      type: this._type,
    });
  }

  onInputCellInternal(grid, cell, inputValue) {
    const { element, rect } = grid.getAttachCellsArea(
      grid.getCellRange(cell.col, cell.row)
    );
    const input = document.createElement("input");
    input.type = this.type || "text";
    super.onSetInputAttrsInternal(grid, cell, input);
    input.style.position = "absolute";
    input.style.top = `${rect.top.toFixed()}px`;
    input.style.left = `${rect.left.toFixed()}px`;
    input.style.width = `${rect.width.toFixed()}px`;
    input.style.height = `${rect.height.toFixed()}px`;
    input.style.font = grid.font || "16px sans-serif";
    input.autocomplete = "off";
    element.appendChild(input);
    input.focus();
    input.value = inputValue || "";

    this._grid = grid;
    this._cell = cell;
    this._input = input;
    this._committing = false;

    // Mirror cheetah-grid's standard InlineInputElement: stop pointer/key
    // events from reaching the grid while the editor is open, otherwise the
    // grid moves the selection or closes the editor mid-edit.
    const stop = (e) => e.stopPropagation();
    input.addEventListener("click", stop);
    input.addEventListener("mousedown", stop);
    input.addEventListener("touchstart", stop);
    input.addEventListener("dblclick", stop);

    input.addEventListener("input", () => this._onInput());
    input.addEventListener("keydown", (e) => this._onKeyDown(e));
    input.addEventListener("blur", () => {
      // Commit on focus loss (e.g. clicking outside the grid).
      if (this._input === input) this._commit(input.value);
    });
  }

  onOpenCellInternal(grid, cell) {
    grid.doGetCellValue(cell.col, cell.row, (value) => {
      this.onInputCellInternal(grid, cell, value);
    });
  }

  onChangeSelectCellInternal(grid, cell, selected) {
    // Grid is telling us the selection has moved. Commit the pending edit so
    // clicking another cell does not silently discard the user's input.
    if (this._input && this._grid === grid) {
      this._commit(this._input.value);
    } else {
      this._cleanup();
    }
  }

  onGridScrollInternal(grid) {
    super.onGridScrollInternal(grid);
    this._cleanup();
  }

  onChangeDisabledInternal() {
    super.onChangeDisabledInternal();
    this._cleanup();
  }

  onChangeReadOnlyInternal() {
    super.onChangeReadOnlyInternal();
    this._cleanup();
  }

  _onInput() {
    const value = this._input.value;
    // filter and limit to max 10 suggestions
    this._filteredOptions = this.options
      .filter(opt => opt.toLowerCase().includes(value.toLowerCase()))
      .slice(0, 10);
    this._renderDropdown();
  }

  _onKeyDown(e) {
    const items = this._dropdown
      ? Array.from(this._dropdown.querySelectorAll("li"))
      : [];
    const active = this._dropdown
      ? this._dropdown.querySelector(".active")
      : null;
    let index = items.indexOf(active);

    switch (e.key) {
      case "ArrowDown":
        if (!items.length) return;
        e.preventDefault();
        e.stopPropagation();
        index = index < items.length - 1 ? index + 1 : 0;
        this._highlight(items, index);
        break;
      case "ArrowUp":
        if (!items.length) return;
        e.preventDefault();
        e.stopPropagation();
        index = index > 0 ? index - 1 : items.length - 1;
        this._highlight(items, index);
        break;
      case "Enter":
        // Stop the grid from also processing Enter (which would re-open the
        // editor or move the selection before the value is written).
        e.preventDefault();
        e.stopPropagation();
        this._commit(active ? active.textContent : this._input.value);
        break;
      case "Tab": {
        // Mirror cheetah-grid's standard input editor: commit on Tab and let
        // the grid move the selection if `keyboardOptions.moveCellOnTab` is on.
        e.preventDefault();
        e.stopPropagation();
        const grid = this._grid;
        this._commit(active ? active.textContent : this._input.value);
        if (
          grid &&
          grid.keyboardOptions &&
          grid.keyboardOptions.moveCellOnTab &&
          typeof grid.onKeyDownMove === "function"
        ) {
          grid.onKeyDownMove(e);
        }
        break;
      }
      case "Escape":
        e.preventDefault();
        e.stopPropagation();
        this._cleanup();
        if (this._grid && this._grid.focus) this._grid.focus();
        break;
    }
  }

  _renderDropdown() {
    this._cleanupDropdown();
    if (!this._filteredOptions.length) return;

    const { element, rect } = this._grid.getAttachCellsArea(
      this._grid.getCellRange(this._cell.col, this._cell.row)
    );

    const dropdown = document.createElement("ul");
    dropdown.className = "autocomplete-dropdown";
    dropdown.style.position = "absolute";
    dropdown.style.top = `${rect.bottom.toFixed()}px`;
    dropdown.style.left = `${rect.left.toFixed()}px`;
    dropdown.style.width = `${rect.width.toFixed()}px`;
    dropdown.style.zIndex = "1000";

    this._filteredOptions.forEach((opt) => {
      const li = document.createElement("li");
      li.textContent = opt;
      // mousedown rather than click so the input does not blur first; stop
      // propagation so the underlying grid does not move the selection.
      li.addEventListener("mousedown", (e) => {
        e.preventDefault();
        e.stopPropagation();
        this._commit(opt);
      });
      dropdown.appendChild(li);
    });

    element.appendChild(dropdown);
    this._dropdown = dropdown;
  }

  _highlight(items, index) {
    items.forEach(i => i.classList.remove("active"));
    const item = items[index];
    if (item) item.classList.add("active");
  }

  // Write the new value through the grid's editor API and tear the editor
  // down. doChangeValue fires CHANGED_VALUE, which the widget already listens
  // for to push the updated cell into Shiny.
  _commit(value) {
    if (this._committing) return;
    this._committing = true;
    const grid = this._grid;
    const cell = this._cell;
    if (!grid || !cell) {
      this._cleanup();
      return;
    }
    grid.doChangeValue(cell.col, cell.row, () => value);
    const range = grid.getCellRange(cell.col, cell.row);
    this._cleanup();
    if (grid.invalidateCellRange) grid.invalidateCellRange(range);
    if (grid.focus) grid.focus();
  }

  _cleanupDropdown() {
    if (this._dropdown) {
      this._dropdown.remove();
      this._dropdown = null;
    }
  }

  _cleanup() {
    this._cleanupDropdown();
    if (this._input) {
      this._input.remove();
      this._input = null;
    }
  }
}

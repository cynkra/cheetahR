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

    input.addEventListener("input", () => this._onInput());
    input.addEventListener("keydown", (e) => this._onKeyDown(e));
  }

  onOpenCellInternal(grid, cell) {
    grid.doGetCellValue(cell.col, cell.row, (value) => {
      this.onInputCellInternal(grid, cell, value);
    });
  }

  onChangeSelectCellInternal(grid, cell, selected) {
    super.onChangeSelectCellInternal(grid, cell, selected);
    this._cleanup();
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
    if (!this._dropdown) return;
    const items = Array.from(this._dropdown.querySelectorAll("li"));
    const active = this._dropdown.querySelector(".active");
    let index = items.indexOf(active);

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        index = index < items.length - 1 ? index + 1 : 0;
        this._highlight(items, index);
        break;
      case "ArrowUp":
        e.preventDefault();
        index = index > 0 ? index - 1 : items.length - 1;
        this._highlight(items, index);
        break;
      case "Enter":
        e.preventDefault();
        // commit either the highlighted option or raw input text
        const newValue = active ? active.textContent : this._input.value;
        this._selectOption(newValue);
        // optionally blur to ensure editor finishes
        if (this._input) this._input.blur();
        break;
      case "Escape":
        this._cleanup();
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

    this._filteredOptions.forEach((opt, i) => {
      const li = document.createElement("li");
      li.textContent = opt;
      li.addEventListener("mousedown", (e) => {
        e.preventDefault();
        this._selectOption(opt);
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

   _selectOption(value) {
    // notify grid of the change
    if (typeof this._grid.doChangeValue === 'function') {
      this._grid.doChangeValue(this._cell.col, this._cell.row, () => value);
    }
    // finish editing (detach input)
    super.onChangeSelectCellInternal(this._grid, this._cell, false);
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

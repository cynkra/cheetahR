import * as cheetahGrid from "cheetah-grid";

export class AutocompleteEditor extends cheetahGrid.columns.action.InlineInputEditor {
  constructor(options) {
    super(options);
    this.options = options.autocompleteOptions || [];
    this.highlightedIndex = -1;
    console.log('AutocompleteEditor initialized with options:', options);
  }

  onInputCellInternal(inputElement, cellValue) {
    super.onInputCellInternal(inputElement, cellValue);

    // Add a unique id and name for accessibility
    if (!inputElement.id) {
      inputElement.id = 'autocomplete-input-' + Math.random().toString(36).substr(2, 9);
    }
    inputElement.name = inputElement.id;

    // Set initial value
    inputElement.value = cellValue || '';
    // Create suggestion box
    const suggestionBox = document.createElement('div');
    suggestionBox.style.position = 'absolute';
    suggestionBox.style.top = '100%';
    suggestionBox.style.left = '0';
    suggestionBox.style.right = '0';
    suggestionBox.style.border = '1px solid #ccc';
    suggestionBox.style.background = '#fff';
    suggestionBox.style.zIndex = '1000';
    suggestionBox.style.maxHeight = '150px';
    suggestionBox.style.overflowY = 'auto';
    suggestionBox.style.display = 'none';
    document.body.appendChild(suggestionBox);

    // Add input event listener
    inputElement.addEventListener('input', () => {
      const value = inputElement.value.toLowerCase();
      suggestionBox.innerHTML = '';
      if (!value) {
        suggestionBox.style.display = 'none';
        return;
      }
      const filtered = this.options.filter(opt => opt.toLowerCase().includes(value));
      if (filtered.length === 0) {
        suggestionBox.style.display = 'none';
        return;
      }
      filtered.forEach((option, index) => {
        const item = document.createElement('div');
        item.textContent = option;
        item.style.padding = '4px 8px';
        item.style.cursor = 'pointer';
        item.addEventListener('mousedown', () => {
          inputElement.value = option;
          suggestionBox.style.display = 'none';
          inputElement.dispatchEvent(new Event('change', { bubbles: true }));
        });
        item.addEventListener('mouseover', () => {
          this.highlightedIndex = index;
          highlightSuggestion();
        });
        suggestionBox.appendChild(item);
      });
      this.highlightedIndex = -1;
      suggestionBox.style.display = 'block';
    });

    // Add keyboard navigation
    inputElement.addEventListener('keydown', (e) => {
      const items = Array.from(suggestionBox.children);
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (this.highlightedIndex < items.length - 1) {
          this.highlightedIndex++;
          highlightSuggestion();
        }
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (this.highlightedIndex > 0) {
          this.highlightedIndex--;
          highlightSuggestion();
        }
      } else if (e.key === 'Enter') {
        e.preventDefault();
        if (this.highlightedIndex >= 0 && this.highlightedIndex < items.length) {
          inputElement.value = items[this.highlightedIndex].textContent;
          suggestionBox.style.display = 'none';
          inputElement.dispatchEvent(new Event('change', { bubbles: true }));
        }
      } else if (e.key === 'Escape') {
        suggestionBox.style.display = 'none';
      }
    });

    // Close suggestions when clicking outside
    document.addEventListener('click', (e) => {
      if (!inputElement.contains(e.target) && !suggestionBox.contains(e.target)) {
        suggestionBox.style.display = 'none';
      }
    });

    // Helper function to highlight suggestions
    const highlightSuggestion = () => {
      const items = Array.from(suggestionBox.children);
      items.forEach((item, index) => {
        item.style.background = index === this.highlightedIndex ? '#bde4ff' : '';
      });
    };
  }
}

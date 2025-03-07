import 'widgets';
import { asHeader } from '../modules/header.js';
import * as cheetahGrid from "cheetah-grid";

HTMLWidgets.widget({

  name: 'cheetah',

  type: 'output',

  factory: function (el, width, height) {

    let id = el.id;

    return {

      renderValue: function (x) {
        let columns;
        const header = Object.keys(x.data[0])
        const defaultCol = header.map((key) => {
          return ({ field: key, caption: key, width: 'auto' });
        });

        if (x.columns !== null) {
          // Create a lookup map from user input
          const userMap = Object.fromEntries(x.columns.map(item => [item.field, item]));

          // Merge user input values into defaultCol
          columns = defaultCol.map(item => ({
            ...item,
            ...(userMap[item.field] || {})
          }));

        } else {
          columns = defaultCol
        }

        const grid = new cheetahGrid.ListGrid({
          parentElement: document.getElementById(id),
          header: columns,
          // Array data to be displayed on the grid
          records: x.data,
          // Column fixed position
          // frozenColCount: 1,
        });

        const {
          CLICK_CELL,
          CHANGED_VALUE,
        } = cheetahGrid.ListGrid.EVENT_TYPE;

        grid.listen(CLICK_CELL, (...args) => console.log(args));
        grid.listen(CHANGED_VALUE, (...args) => console.log(args));
      },

      resize: function (width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

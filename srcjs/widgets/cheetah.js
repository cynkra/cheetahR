import 'widgets';
import { asHeader } from '../modules/header.js';
import * as cheetahGrid from "cheetah-grid";

HTMLWidgets.widget({

  name: 'cheetah',

  type: 'output',

  factory: function (el, width, height) {

    let id = el.id;

    return {

      renderValue: function (x, id = el.id) {
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
          // Column fixed position
          // frozenColCount: 1,
        });

        // Search feature
        if (x.search !== 'disabled') {
          const filterDataSource = new cheetahGrid
            .data
            .FilterDataSource(
              cheetahGrid.data.DataSource.ofArray(x.data)
            );
          grid.dataSource = filterDataSource;

          $(`#${el.id}`).prepend(
            `<label>Filter:</label><input id="${el.id}-filter-input" style="margin: 10px;"/>`
          )

          $(`#${el.id}-filter-input`).on('input', (e) => {
            const filterValue = $(e.currentTarget).val();
            filterDataSource.filter = filterValue
              ? (record) => {
                // filtering method
                for (const k in record) {
                  let testCond;
                  switch (x.search) {
                    case 'contains':
                      testCond = `${record[k]}`.indexOf(filterValue) >= 0;;
                      break;
                    case 'exact':
                      let r = new RegExp(`^${filterValue}$`);
                      testCond = r.test(`${record[k]}`);
                      break;
                    default:
                      console.log(`${x.search} value not implemented yet.`);
                  }
                  if (testCond) {
                    return true;
                  }
                }
                return false;
              }
              : null;
            grid.invalidate();
          })
        } else {
          // Array data to be displayed on the grid
          grid.records = x.data;
        }

        // Only is Shiny exists
        if (HTMLWidgets.shinyMode) {
          const {
            CLICK_CELL,
            CHANGED_VALUE,
          } = cheetahGrid.ListGrid.EVENT_TYPE;

          grid.listen(
            CLICK_CELL, (...args) => {
              Shiny.setInputValue(`${id}_click_cell`, args);
            }
          );

          grid.listen(
            CHANGED_VALUE, (...args) => {
              Shiny.setInputValue(`${id}_changed_value`, args);
            }
          );
        }
      },

      resize: function (width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

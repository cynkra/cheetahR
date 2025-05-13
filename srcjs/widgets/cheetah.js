import 'widgets';
import { combineColumnsAndGroups, isDefined } from '../modules/utils.js';
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

          // Iterate over the list and process the `action` property if it is not null or undefined
          columns.forEach((obj) => {
            if (obj.action != null) {  // Checks for both null and undefined
              if (obj.action.type === "inline_menu") {
                obj.columnType = new cheetahGrid.columns.type.MenuColumn({
                  options: obj.action.options,
                });

                obj.action = new cheetahGrid.columns.action.InlineMenuEditor({
                  options: obj.action.options,
                });
              }
            }
          });

        } else {
          columns = defaultCol;
        }

        if (isDefined(x.colGroup)) columns = combineColumnsAndGroups(columns, x.colGroup);

        // Create grid configuration object with only defined options
        const gridConfig = {
          parentElement: document.getElementById(id),
          header: columns
        };

        // Only add options if they are defined
        if (isDefined(x.disableColumnResize)) gridConfig.disableColumnResize = x.disableColumnResize;
        if (isDefined(x.frozenColCount)) gridConfig.frozenColCount = x.frozenColCount;
        if (isDefined(x.defaultRowHeight)) gridConfig.defaultRowHeight = x.defaultRowHeight;
        if (isDefined(x.defaultColWidth)) gridConfig.defaultColWidth = x.defaultColWidth;
        if (isDefined(x.headerRowHeight)) gridConfig.headerRowHeight = x.headerRowHeight;
        if (isDefined(x.theme)) gridConfig.theme = x.theme;
        if (isDefined(x.font)) gridConfig.font = x.font;
        if (isDefined(x.underlayBackgroundColor)) gridConfig.underlayBackgroundColor = x.underlayBackgroundColor;
        if (isDefined(x.allowRangePaste)) gridConfig.allowRangePaste = x.allowRangePaste;
        // if (isDefined(x.keyOptions)) gridConfig.keyOptions = x.keyOptions;

        const grid = new cheetahGrid.ListGrid(gridConfig);

        // Search feature
        if (x.search !== 'disabled') {
          const filterDataSource = new cheetahGrid
            .data
            .FilterDataSource(
              cheetahGrid.data.DataSource.ofArray(x.data)
            );
          grid.dataSource = filterDataSource;

          const widget = document.getElementById(el.id);
          const label = document.createElement('label');
          label.textContent = 'Filter:';
          // Create input
          const input = document.createElement('input');
          input.id = `${el.id}-filter-input`;
          input.style.margin = '10px';
          widget.prepend(label, input);

          const filterInput = document.getElementById(`${el.id}-filter-input`);
          filterInput.addEventListener('input', (e) => {
            const filterValue = document.getElementById(e.currentTarget.id).value;
            filterDataSource.filter = filterValue
              ? (record) => {
                // filtering method
                for (const k in record) {
                  let testCond;
                  switch (x.search) {
                    case 'contains':
                      testCond = `${record[k]}`.indexOf(filterValue) >= 0;
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

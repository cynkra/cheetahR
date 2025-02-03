import 'widgets';
import { asHeader } from '../modules/header.js';
import * as cheetahGrid from "cheetah-grid";

HTMLWidgets.widget({

  name: 'cheetah',

  type: 'output',

  factory: function(el, width, height) {

    let id = el.id;

    return {

      renderValue: function(x) {

        // initialize
      const columns = [
        { field: 'mpg', caption: 'MPG', width: 100 },
        { field: 'cyl', caption: 'Cylinders', width: 100 },
        { field: 'disp', caption: 'Displacement', width: 120 },
        { field: 'hp', caption: 'Horsepower', width: 120 },
        { field: 'drat', caption: 'Rear Axle Ratio', width: 120 },
        { field: 'wt', caption: 'Weight (1000 lbs)', width: 140 },
        { field: 'qsec', caption: '1/4 Mile Time', width: 120 },
        { field: 'vs', caption: 'Engine Shape', width: 120 },
        { field: 'am', caption: 'Transmission', width: 120 },
        { field: 'gear', caption: 'Gears', width: 100 },
        { field: 'carb', caption: 'Carburetors', width: 120 },
      ];

      const grid = new cheetahGrid.ListGrid({
        parentElement: document.getElementById(id),
        header: columns,
        // Array data to be displayed on the grid
        records: x.data,
        // Column fixed position
        frozenColCount: 1,
      });
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

export function combineColumnsAndGroups(columnsList, colGroups) {
    // 1. Build a lookup by field
    const colsByField = {};
    columnsList.forEach(col => {
      colsByField[col.field] = col;
    });
  
    // 2. Find each group's first member and all members
    const groupFirst   = colGroups.map(g => g.columns[0]);
    const groupMembers = colGroups.reduce((acc, g) => acc.concat(g.columns), []);
  
    const result = [];
  
    // 3. Iterate in original order
    columnsList.forEach(col => {
      const f = col.field;
      const gi = groupFirst.indexOf(f);
  
      if (gi !== -1) {
        // this is the first field of group gi → emit the group
        const grp = colGroups[gi];
  
        // build nested column definitions
        const nested = grp.columns.map(fieldName => colsByField[fieldName]);
  
        // extract everything except `columns` from grp
        const { columns, ...grpMeta } = grp;
  
        result.push({ ...grpMeta, columns: nested });
  
      } else if (groupMembers.includes(f)) {
        // a member of some group but not its first → skip
  
      } else {
        // standalone column
        result.push(colsByField[f]);
      }
    });
  
    return result;
  }
  
  
/**
  * Checks if a value is defined and not null
*/
export function isDefined(value) {
    return value !== undefined && value !== null;
}

/**
 * Converts an array of objects (row-wise data) to a column-wise list format.
 * This format is easier for R/Shiny to convert to a data frame/tibble.
 * 
 * Example:
 * Input:  [{ name: "John", age: 30 }, { name: "Jane", age: 25 }]
 * Output: { name: ["John", "Jane"], age: [30, 25] }
 * 
 * In R, use: as.data.frame(lapply(input$grid_data_state, unlist))
 * Or: tibble::as_tibble(lapply(input$grid_data_state, unlist))
 * 
 * @param {Array} arr - Array of objects (each object is a row)
 * @returns {Object} - Object with arrays as values (each key is a column)
 */
export function arrayToList(arr) {
    if (!arr || arr.length === 0) {
        return {};
    }
    
    // Get all unique keys from all objects
    const keys = [...new Set(arr.flatMap(obj => Object.keys(obj)))];
    
    // Create the column-wise structure with primitive values only
    const result = {};
    keys.forEach(key => {
        result[key] = arr.map(obj => {
            const val = obj[key];
            // Ensure primitive values (convert objects/arrays to string if needed)
            if (val === undefined || val === null) {
                return null;
            } else if (typeof val === 'object') {
                return JSON.stringify(val);
            } else {
                return val;
            }
        });
    });
    
    return result;
}


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
  
  
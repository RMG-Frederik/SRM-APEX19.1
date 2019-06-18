/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Filters
     **/
Rmg.Srm.Filters = Rmg.Srm.Filters || {}

/**
 * @function buildStatusFilter
 * @example Rmg.Srm.Filters.buildStatusFilter();
 **/
Rmg.Srm.Filters.buildFilterDdlSingleOnOneColumn = function(gridRegion, columnName, itemAttached) {
    var vRegion = apex.region(gridRegion);
    var vFilters = vRegion.call("getFilters");
    var vGrid = vRegion.call("getViews", "grid");
    var vFilterColId = vGrid.modelColumns[columnName].id;
    for (var i in vFilters) {
        if (vFilters[i].columnId == vFilterColId) {
            vRegion.call("deleteFilter", vFilters[i].id);
        }
    }

    if ($v2(itemAttached) != 'ALL') {
        vRegion.call("addFilter", {
            type: 'column',
            columnType: 'column',
            columnName: columnName,
            operator: 'EQ',
            value: $v2(itemAttached),
            isCaseSensitive: false
        })
    }
}
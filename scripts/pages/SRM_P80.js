/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Page80
     **/
Rmg.Srm.Page80 = Rmg.Srm.Page80 || {}

/**
 * @function configTakenLijstGrid
 * @example Rmg.Srm.Page80.configTakenLijstGrid(config);
 **/
Rmg.Srm.Page80.configTakenLijstGrid = function(config) {
        if (!config.toolbar) {
            config.toolbar = {};
        }
        if (!config.views) {
            config.views = {};
        }
        config.toolbar.actionMenu = false;
        config.toolbar.searchField = true;
        return config;
    }
    /**
     * @function buildStatusFilter
     * @example Rmg.Srm.Page80.buildStatusFilter();
     **/
Rmg.Srm.Page80.buildStatusFilter = function() {
    var vRegion = apex.region("view_tasks");
    var vFilters = vRegion.call("getFilters");
    var vGrid = vRegion.call("getViews", "grid");
    var vFilterColId = vGrid.modelColumns["TAAK_STATE_CODE"].id;
    for (var i in vFilters) {
        if (vFilters[i].columnId == vFilterColId) {
            vRegion.call("deleteFilter", vFilters[i].id);
        }
    }

    if ($v2('P11_DDL_STATUS') != 'ALL') {
        vRegion.call("addFilter", {
            type: 'column',
            columnType: 'column',
            columnName: 'TAAK_STATE_CODE',
            operator: 'EQ',
            value: $v2('P11_DDL_STATUS'),
            isCaseSensitive: false
        })
    }
}
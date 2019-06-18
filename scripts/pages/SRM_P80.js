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
    config.toolbar.actionMenu = true;
    config.toolbar.searchField = true;
    config.toolbarData = [{
            controls: [{
                type: "BUTTON",
                action: "show-filter-dialog",
                iconBeforeLabel: true
            }]
        },
        {
            groupTogether: true,
            controls: [{
                    type: "TEXT",
                    id: "search_field",
                    enterAction: "search"
                },
                {
                    type: "BUTTON",
                    action: "search"
                }
            ]
        }
    ];
    var $ = apex.jQuery,
        toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(),
        toolbarGroup = toolbarData[toolbarData.length - 1]; // this is the last group with reset button

    // add our own button
    toolbarGroup.controls.push({
        type: "BUTTON",
        action: "my-action"
    });
    config.toolbarData = toolbarData;

    config.initActions = function(actions) {
        // can modify state of existing actions or add your own
        // can also pass in an array of actions to add
        actions.add({
            name: "my-action",
            label: "Hello",
            action: function(event, focusElement) {
                alert("Hello World!");
            }
        });
    }
    return config;
}
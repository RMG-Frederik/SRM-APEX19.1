/*
 * Simple Grid APEX region plugin for grid widget
 */
/*global window,apex*/
(function(util, widgetUtil, region, $) {
    "use strict";

    window.simpleGridRegionInit = function(options) {
        var model, grid$, sizer$, columnMenu$, data, moreData /* intentionally undefined */ ,
            storage = null,
            values = null,
            total = null,
            currentFilters = null,
            curColumnMenuContext = null,
            requestChangeColumns = false;

        apex.debug.info("Init simple grid region: ", options);

        function createModel() {
            var f,
                fields = options.columns[0],
                idFields = [];

            for (f in fields) {
                if (fields.hasOwnProperty(f)) {
                    if (fields[f].pk) {
                        idFields.push(f);
                    }
                }
            }
            if (idFields.length === 0) {
                idFields = null;
            }
            model = apex.model.create(options.modelName, $.extend({}, options.modelOptions, {
                shape: "table",
                recordIsArray: true,
                identityField: idFields,
                fields: options.columns[0],
                paginationType: "progressive",
                regionId: options.regionId,
                ajaxIdentifier: options.ajaxIdentifier,
                pageItemsToSubmit: options.itemsToSubmit,
                // Neither the model or the view expects the field/column configuration to change but that is something
                // this region supports.
                // Using this undocumented option to allow getting new columns from the server at the same time as getting new data
                // This is not what it is intended for but until there is a better way for views to hook into the
                // model requests this will have to do. Would not be needed if willing to have two requests when the columns change.
                // see commented out code in changeColumns
                callServer: function(mData, mOptions) {
                    var p;
                    if (requestChangeColumns) {
                        mData.regions[0].getColumns = true;
                        // must clear sorts because they don't apply to the new columns
                        delete mData.regions[0].fetchData.sorts;
                        delete mData.regions[0].fetchData.filters;
                        // use success so we get access to the response data before the model does; assumes model doesn't use success
                        mOptions.success = function(responseData) {
                            var fetched = responseData.regions[0].fetchedData,
                                columns = responseData.regions[0].columns;
                            // save the data for the creation of a new model
                            values = fetched.values;
                            moreData = fetched.moreData;
                            total = fetched.totalRows;
                            // now lie and say there is no data because it doesn't fit the old columns anyway
                            fetched.values = [];
                            fetched.moreData = false;
                            setTimeout(function() {
                                // update column metadata for use by grid and new model
                                options.columns[0] = columns;
                                loadColumnState(columns);
                                createModel(); // overwrite definition of existing model
                                // update grid with new column metadata
                                grid$.grid("option", "columns")[0] = columns;
                                // tell the grid the columns have changed and by setting the modelName
                                // it will switch to use the new model that was just created including subscribing to model notifications
                                // and also causes refreshing the grid widget.
                                grid$.grid("refreshColumns")
                                    .grid("option", "modelName", options.modelName);
                            }, 1);
                        }
                    }
                    requestChangeColumns = false;
                    p = apex.server.plugin(mData, mOptions);
                    return p;
                },
            }), values, total, moreData);
            // after the model is created don't use the initial data any more
            total = values = null;
            moreData = undefined;
        }

        function updateModelFetchData() {
            var p, col,
                colMap = options.columns[0],
                sorts = [],
                fetchData = model.getOption("fetchData");

            fetchData.sorts = sorts;
            for (p in colMap) {
                if (colMap.hasOwnProperty(p)) {
                    col = colMap[p];
                    if (col.sortDirection) {
                        sorts.push({
                            column: p,
                            direction: col.sortDirection.toUpperCase(),
                            index: col.sortIndex
                        });
                    }
                }
            }
            if (currentFilters && currentFilters.length > 0) {
                fetchData.filters = currentFilters;
            } else {
                fetchData.filters = [];
            }
        }

        function resize(init) {
            var w = sizer$.width(),
                h = sizer$.height();

            util.setOuterWidth(grid$, w);
            if (options.hasSize) {
                util.setOuterHeight(grid$, h);
            }
            if (!init) {
                grid$.grid("resize");
            }
        }

        function getColumnStateKey() {
            return (options.persistColumnStatePrefix ? options.persistColumnStatePrefix + "_" : "") + "columns";
        }

        function persistColumnState(columns) {
            var i, c,
                cols = [];

            if (!storage) {
                return;
            }

            for (i = 0; i < columns.length; i++) {
                c = columns[i];
                cols.push({
                    name: c.property,
                    width: c.width,
                    seq: c.seq,
                    frozen: c.frozen,
                    hidden: c.hidden
                });
            }
            storage.setItem(getColumnStateKey(), JSON.stringify(cols));
        }

        function loadColumnState(columns) {
            var i, c, dest_col, cols;

            if (!storage) {
                return;
            }

            cols = storage.getItem(getColumnStateKey());
            if (cols) {
                try {
                    cols = JSON.parse(cols);
                    for (i = 0; i < cols.length; i++) {
                        c = cols[i];
                        dest_col = columns[c.name];
                        if (dest_col) {
                            if (c.seq && typeof c.seq === "number") {
                                dest_col.seq = c.seq;
                            }
                            if (c.width && typeof c.width === "number" && c.width > 20) {
                                dest_col.width = c.width
                            }
                            if ((c.hidden === true || c.hidden === false) && dest_col.canHide) {
                                dest_col.hidden = c.hidden;
                            }
                            if (c.frozen === true || c.frozen === false) {
                                dest_col.frozen = c.frozen;
                            }
                        }
                    }
                } catch (e) {
                    apex.debug.warn("Failed to load columns from session storage.", e.toString());
                }
            }
        }

        if (options.persistColumnState) {
            storage = apex.storage.getScopedSessionStorage({
                prefix: "SG",
                usePageId: true,
                regionId: options.regionId
            });
        }

        if (!options.lazyLoad) {
            data = window["gSGdata_" + options.regionId];
            values = data.values;
            if (data.totalRows) {
                total = data.totalRows;
            }
            moreData = data.moreData;
        }

        createModel();

        updateModelFetchData();

        // column menu

        options.sortChange = options.sortChange || function(event, ui) {
                var i, col, index,
                    originalIndex = ui.column.sortIndex,
                    columns = grid$.grid("getColumns");

                index = 1;
                for (i = 0; i < columns.length; i++) {
                    col = columns[i];
                    if (col.sortIndex) {
                        if (ui.action === "change") {
                            if (col === ui.column) {
                                index = col.sortIndex;
                            }
                        } else if (ui.action === "add") {
                            if (col.sortIndex >= index) {
                                index = col.sortIndex + 1;
                            }
                        } else if (ui.action === "remove") {
                            if (col === ui.column) {
                                delete col.sortIndex;
                                delete col.sortDirection;
                            } else if (col.sortIndex > originalIndex) {
                                col.sortIndex -= 1;
                            }
                        } else if (ui.action === "clear" || ui.action === "set") {
                            delete col.sortIndex;
                            delete col.sortDirection;
                        }
                    }
                }

                if (ui.action !== "clear" && ui.action !== "remove") {
                    ui.column.sortIndex = index;
                    ui.column.sortDirection = ui.direction;
                }
                grid$.grid("refreshColumns");
                updateModelFetchData();
                model.clearData();
            },
            options.columnReorder = options.columnReorder || function(event, ui) {
                persistColumnState(grid$.grid("getColumns"));
            };
        options.columnResize = options.columnResize || function(event, ui) {
            persistColumnState(grid$.grid("getColumns"));
        };

        grid$ = $("#" + options.regionStaticId + "_g");
        sizer$ = grid$.parent();
        sizer$.css("overflow", "hidden");
        if (options.hasSize) {
            sizer$.css("height", options.gridHeight || 200);
        }
        resize(true); // before grid widget is created
        loadColumnState(options.columns[0]);
        grid$.grid(options);

        // This is currently undocumented but it detects when an element's size changes. IG uses this.
        widgetUtil.onElementResize(grid$.parent()[0], function() {
            resize();
        });

        // This is currently undocumented but I have blogged about it.
        widgetUtil.onVisibilityChange(grid$[0], function(show) {
            if (show) {
                widgetUtil.updateResizeSensors(sizer$[0]);
                resize();
            }
        });

        apex.region.create(options.regionStaticId, {
            type: "grid",
            widgetName: "grid",
            focus: function() {
                grid$.grid("focus");
            },
            refresh: function() {
                model.clearData();
            },
            widget: function() {
                return grid$;
            },
            alternateLoadingIndicator: function(element, loadingIndicator$) {
                var cell$ = grid$.grid("getActiveCellFromColumnItem", element);
                if (cell$) {
                    return util.showSpinner(cell$, {
                        spinnerClass: "u-Processing--cellRefresh"
                    });
                }
            },
            // extra methods
            getModel: function() {
                return model;
            },
            /**
             * An array of filter objects.
             * @param Array filters
             * @param string filters.column
             * @param integer filters.type
             * @param string filters.value
             * @param string filters.fromValue
             * @param string filters.toValue
             * @param string filters.values
             */
            setFilters: function(filters) {
                currentFilters = filters;
                updateModelFetchData();
                model.clearData();
            },
            getFilters: function() {
                return currentFilters;
            },
            changeColumns: function(persistColumnStatePrefix) {
                // request new columns and data only if the prefix has changed
                if (persistColumnStatePrefix !== options.persistColumnStatePrefix) {
                    requestChangeColumns = true;
                    options.persistColumnStatePrefix = persistColumnStatePrefix;
                    model.clearData();
                }
                /* the two request way
                                var p;
                                // todo make use of key
                                // error if this happens while a refresh is also happening.
                                //  need guard,
                                // todo should also debounce change events that drive this
                                p = apex.server.plugin({
                                    regions: [ {
                                        id: options.regionStaticId,
                                        ajaxIdentifier: options.ajaxIdentifier,
                                        getColumns: true
                                    }],
                                    pageItems: options.itemsToSubmit
                                }, {
                                    dataType: "json"
                                } );
                                p.done(function(data) {
                                    options.columns[0] = data.regions[0].columns;
                                    createModel(); // overwrite definition of existing model
                                    grid$.grid("option", "columns")[0] = data.regions[0].columns;
                                    grid$.grid("refreshColumns")
                                        .grid("option", "modelName", options.modelName);
                                });
                */
            }
        });
    };
})(apex.util, apex.widget.util, apex.region, apex.jQuery);
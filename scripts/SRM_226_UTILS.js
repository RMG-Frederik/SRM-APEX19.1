/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Utils
     **/
Rmg.Srm.Utils = Rmg.Srm.Utils || {}
    /**
     * Hide a give region
     * @param {string} ID - The Id of a region
     * @example
     *     Rmg.Srm.Utils.hideRegion('#my_region_static_ID')
     */
Rmg.Srm.Utils.hideRegion = function(ID) {
        if (typeof ID !== 'undefined') $(ID).hide()
    }
    /**
     * Show a give region
     * @param {string} ID - The Id of a region
     * @example
     *     Rmg.Srm.Utils.showRegion('#my_region_static_ID')
     */
Rmg.Srm.Utils.showRegion = function(ID) {
        if (typeof ID !== 'undefined') $(ID).show()
    }
    /**
     * Go back to the browsers previous page
     * @example
     *     Rmg.Srm.Utils.goBackNoWarning()
     */
Rmg.Srm.Utils.goBackNoWarning = function() {
        window.history.go(-1)
    }
    /**
     * Goes back to the previous browser page after pressing comfirmation with given message
     * @param {string} message - The message inside the comfirmation
     * @example
     *     Rmg.Srm.Utils.goBackWithComfirmation('Are you sure you want to go back ?')
     */
Rmg.Srm.Utils.goBackWithComfirmation = function(message) {
        if (confirm(message)) {
            window.history.back()
        }
    }
    /**
     * Checks a row of an IR for a link and makes the entire row clickable
     * @param {string} target - The target page
     * @example
     *     Rmg.Srm.Utils.makeEntireRowLink('81')
     */
Rmg.Srm.Utils.makeEntireRowLink = function(target) {
    $('a[href*="' + target + '"]').each(function(index) {
        lnk = $(this).attr('href');
        $(this).parent()
            .parent('tr')
            .attr('data-href', lnk)
            .click(function() {
                window.location = $(this).attr('data-href');
            })
            .mouseover(function() {
                $(this).css('cursor', 'pointer');
            })
            .mouseleave(function() {
                $(this).css('cursor', 'default');
            })
    });
}

Rmg.Srm.Utils.makeRowLinkExcept = function(target, noLink) {
    $('a[href*="' + target + '"]').each(function(index) {
        lnk = $(this).attr('href');
        $(this).parent()
            .siblings('td[headers !="' + noLink + '"]')
            .attr('data-href', lnk)
            .click(function() {
                window.location = $(this).attr('data-href');
            })
            .mouseover(function() {
                $(this).css('cursor', 'pointer');
            })
            .mouseleave(function() {
                $(this).css('cursor', 'default');
            })
    });
}

/**
 * Confine DatePicker to selected dates
 */
Rmg.Srm.Utils.limitDatePicker = function(datepicker, availableDates, enabled) {
    apex.debug('Picking dates');

    function disableArrayOfDays(d) {
        // normalize the date for searching in array
        var dmy = "";
        dmy += ("00" + d.getDate()).slice(-2) + "-";
        dmy += ("00" + (d.getMonth() + 1)).slice(-2) + "-";
        dmy += d.getFullYear();
        apex.debug(dmy);
        if ($.inArray(dmy, availableDates) != -1) {
            apex.debug('Date found');
            return [true, null, null];
        } else {
            return [false, null, null];
        }
    }

    function enableArrayOfDays(d) {
        // normalize the date for searching in array
        var dmy = "";
        dmy += ("00" + d.getDate()).slice(-2) + "-";
        dmy += ("00" + (d.getMonth() + 1)).slice(-2) + "-";
        dmy += d.getFullYear();
        apex.debug(dmy);
        if ($.inArray(dmy, availableDates) == -1) {
            apex.debug('Date found');
            return [true, null, null];
        } else {
            return [false, null, null];
        }
    }
    if (enabled)
        $(datepicker).datepicker("option", "beforeShowDay", function(date) { return enableArrayOfDays(date); }).next('button').addClass('a-Button a-Button--calendar');
    else
        $(datepicker).datepicker("option", "beforeShowDay", function(date) { return disableArrayOfDays(date); }).next('button').addClass('a-Button a-Button--calendar');
}

Rmg.Srm.Utils.highlightDatePicker = function(datepicker, availableDates, enabled, pClass) {
    apex.debug('Picking dates');

    function disableArrayOfDays(d) {
        // normalize the date for searching in array
        var dmy = "";
        dmy += ("00" + d.getDate()).slice(-2) + "-";
        dmy += ("00" + (d.getMonth() + 1)).slice(-2) + "-";
        dmy += d.getFullYear();
        apex.debug(dmy);
        if ($.inArray(dmy, availableDates) != -1) {
            apex.debug('Date found');
            return [true, pClass, null];
        } else {
            return [true, null, null];
        }
    }

    function enableArrayOfDays(d) {
        // normalize the date for searching in array
        var dmy = "";
        dmy += ("00" + d.getDate()).slice(-2) + "-";
        dmy += ("00" + (d.getMonth() + 1)).slice(-2) + "-";
        dmy += d.getFullYear();
        apex.debug(dmy);
        if ($.inArray(dmy, availableDates) == -1) {
            apex.debug('Date found');
            return [true, pClass, null];
        } else {
            return [true, null, null];
        }
    }
    if (enabled)
        $(datepicker).datepicker("option", "beforeShowDay", function(date) { return enableArrayOfDays(date); }).next('button').addClass('a-Button a-Button--calendar');
    else
        $(datepicker).datepicker("option", "beforeShowDay", function(date) { return disableArrayOfDays(date); }).next('button').addClass('a-Button a-Button--calendar');
}

/**
 * Shows an apex comfirmation message with custom labels for the buttons
 * @param {string} pMessage - The message that needs to be displayed
 * @param {string} pCallback - Callback url
 * @param {string} pOkLabel - The text on the ok button
 * @param {string} pCancelLabel - The text on the cancel button
 * @example
 *     
 */
Rmg.Srm.Utils.customComfirm = function(pMessage, pCallback, pOkLabel, pCancelLabel) {
    var l_original_messages = { "APEX.DIALOG.OK": apex.lang.getMessage("APEX.DIALOG.OK"), "APEX.DIALOG.CANCEL": apex.lang.getMessage("APEX.DIALOG.CANCEL") };
    //change the button labels messages
    apex.lang.addMessages({ "APEX.DIALOG.OK": pOkLabel });
    apex.lang.addMessages({ "APEX.DIALOG.CANCEL": pCancelLabel });
    //show the confirm dialog
    apex.message.confirm(pMessage, pCallback);
    //changes the button labels messages back to their original values
    apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_messages["APEX.DIALOG.OK"] });
    apex.lang.addMessages({ "APEX.DIALOG.CANCEL": l_original_messages["APEX.DIALOG.CANCEL"] });
}

Rmg.Srm.Utils.showItem = function(pItem) {
    apex.item(pItem).show();
}

Rmg.Srm.Utils.validateArrayMails = function(pItem) {
    var item = apex.item(pItem);
    var mailString = item.getValue();
    var mailArray = mailString.replace(/\s/g, '').split(";");
    var isValid = true;
    var regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    var errors = "";
    if (mailString == "") { isValid = true; } else {
        for (var i = 0; i < mailArray.length; i++) {
            if (mailArray[i] != "") {
                if (!regex.test(mailArray[i])) {
                    isValid = false;
                    errors += mailArray[i];
                }
            }
        }
    }
    if (isValid) {
        item.node.setCustomValidity(""); // valid 
    } else {
        item.node.setCustomValidity("Er zitten fouten in de lijst van mailadressen: " + errors);
    }
}
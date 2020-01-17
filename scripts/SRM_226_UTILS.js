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
 * detect IE
 * returns version of IE or false, if browser is not Internet Explorer
 */    
Rmg.Srm.Utils.detectIE = function() {
    var ua = window.navigator.userAgent;
    // Test values; Uncomment to check result …
    // IE 10
    // ua = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)'; 
    // IE 11
    // ua = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko';   
    // Edge 12 (Spartan)
    // ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0';
    // Edge 13
    // ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586';
  
    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
      // IE 10 or older => return version number
      return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }
  
    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
      // IE 11 => return version number
      var rv = ua.indexOf('rv:');
      return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }
  
    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
      // Edge (IE 12+) => return version number
      return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }
  
    // other browser
    return false;       
    }
    /**
     * Sets the size of a modal to a percentage of total screen, with a minimum
     * @param {string} affectedClass - The class of the affected modal
     * @param {string} percentage - The percentage of total screen size used
     * @param {string} minH - The minimum heugth applied
     * @param {string} minW - The minimum width applied
     */
Rmg.Srm.Utils.setModalSizePercentage = function(affectedClass, percentage, minH, minW) {
        var w = window.innerWidth / 100 * percentage;
        var h = window.innerHeight / 100 * percentage;
        if (Number(h) < Number(minH)) h = minH;
        if (Number(w) < Number(minW)) w = minW;
        $(affectedClass).dialog({ height: h, width: w });
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

Rmg.Srm.Utils.makeRowLinkExcept2 = function(target, noLink, noLink2) {
    $('a[href*="' + target + '"]').each(function(index) {
        lnk = $(this).attr('href');
        $(this).parent()
            .siblings('td[headers !="' + noLink2 + '"]')
            .not('td[headers ="' + noLink + '"]')
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
        if ($.inArray(dmy, availableDates) != -1) {
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
        if ($.inArray(dmy, availableDates) == -1) {
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
        if ($.inArray(dmy, availableDates) != -1) {
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
        if ($.inArray(dmy, availableDates) == -1) {
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
 * Shows an apex confirmation message with custom labels for the buttons
 * @param {string} pMessage - The message that needs to be displayed
 * @param {string} pCallback - Callback url
 * @param {string} pOkLabel - The text on the ok button
 * @param {string} pCancelLabel - The text on the cancel button
 * @example
 *     
 */
Rmg.Srm.Utils.customConfirm = function(pMessage, pCallback, pOkLabel, pCancelLabel) {
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

Rmg.Srm.Utils.setDefaultEnterOnButton = function(pInputId,pButtonId) {
    var input = document.getElementById(pInputId);
    input.addEventListener("keyup", function(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            document.getElementById(pButtonId).click();
        }
    });
}
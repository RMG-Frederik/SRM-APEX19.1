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
        window.history.back()
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
    /**
     * Shows an apex comfirmation message with custom labels for the buttons
     * @param {string} pMessage - The message that needs to be displayed
     * @param {string} pCallback - Callback url
     * @param {string} pOkLabel - The text on the ok button
     * @param {string} pCancelLabel - The text on the cancel button
     * @example
     *     Rmg.Srm.Utils.makeEntireRowLink('81')
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
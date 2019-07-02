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
    console.log('Hidden: ', ID)
}

Rmg.Srm.Utils.showRegion = function(ID) {
    if (typeof ID !== 'undefined') $(ID).show()
    console.log('Shown: ', ID)
}

Rmg.Srm.Utils.goBackNoWarning = function() {
    console.log('Keerekeeweere')
    window.history.back();
}

Rmg.Srm.Utils.goBackWithComfirmation = function(message) {
    console.log('Keerekeeweere')
    if (confirm(message)) {
        window.history.back();
    }
}

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
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

Rmg.Srm.Utils.hideRegion = function(ID) {
    if (typeof ID !== 'undefined') $(ID).hide()
    console.log('Hidden: ', ID)
}

Rmg.Srm.Utils.showRegion = function(ID) {
    if (typeof ID !== 'undefined') $(ID).show()
    console.log('Shown: ', ID)
}
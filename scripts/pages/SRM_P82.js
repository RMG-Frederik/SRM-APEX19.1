/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Page82
     **/
Rmg.Srm.Page82 = Rmg.Srm.Page82 || {}

/**
 * @function initPageOnLoad
 * @example Rmg.Srm.Page82.initPageOnLoad();
 **/
Rmg.Srm.Page82.initPageOnLoad = function() {

    }
    /**
     * @function setUnitAndPersonLov
     * @example Rmg.Srm.Page82.setUnitAndPersonLov();
     **/
Rmg.Srm.Page82.setUnitAndPersonLov = function() {
    var vUnit = $v2('P82_OWNER_ORG_UNIT_ID');
    var vPerson = $v2('P82_OWNER_PERSOON_ID');
    if ((vUnit === '0') && (vPerson === '0')) {
        apex.item("P82_OWNER_ORG_UNIT_ID").enable();
        apex.item("P82_OWNER_PERSOON_ID").enable();
    } else if (vUnit === '0') {
        apex.item("P82_OWNER_PERSOON_ID").enable();
        apex.item("P82_OWNER_ORG_UNIT_ID").disable();
    } else if (vPerson === '0') {
        apex.item("P82_OWNER_PERSOON_ID").enable();
        apex.item("P82_OWNER_ORG_UNIT_ID").enable();
    } else {
        apex.item("P82_OWNER_PERSOON_ID").enable();
        apex.item("P82_OWNER_ORG_UNIT_ID").enable();
    }
}
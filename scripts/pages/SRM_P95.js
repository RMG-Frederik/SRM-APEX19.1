/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Page95
     **/
Rmg.Srm.Page95 = Rmg.Srm.Page95 || {}

/**
 * @function initPageOnLoad
 * @example Rmg.Srm.Page95.initPageOnLoad();
 **/
Rmg.Srm.Page95.initPageOnLoad = function() {
        document.getElementById('P95_AANTAL_DAGEN_DEADLINE').type = 'number';
    }
    /**
     * @function setToewijzingswaardeVeld
     * @example Rmg.Srm.Page95.setToewijzingswaardeVeld();
     **/
Rmg.Srm.Page95.setToewijzingswaardeVeld = function() {
    var vToewijzing = $v2('P95_TOEWIJZING_ID');
    switch (vToewijzing) {
        case '1':
            apex.item("P95_TOEWIJZING_PERSOON").show();
            apex.item("P95_TOEWIJZING_UNIT").hide();
            break;
        case '3':
            apex.item("P95_TOEWIJZING_PERSOON").hide();
            apex.item("P95_TOEWIJZING_UNIT").show();
            break;
        default:
            apex.item("P95_TOEWIJZING_PERSOON").hide();
            apex.item("P95_TOEWIJZING_UNIT").hide();
    }
}
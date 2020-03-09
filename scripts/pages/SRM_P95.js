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
    var vToewijzing = $v2('P96_TOEWIJZING_ID');
    switch (vToewijzing) {
        apex.item("P96_TOEW_PERSOON_ID").setValue('');
        apex.item("P96_TOEW_ORG_UNIT_ID").setValue('');
        case '1':
            apex.item("P96_TOEW_PERSOON_ID").show();
            apex.item("P96_TOEW_ORG_UNIT_ID").show();
            break;
        case '3':
            apex.item("P96_TOEW_PERSOON_ID").hide();
            apex.item("P96_TOEW_ORG_UNIT_ID").show();
            break;
        case '0':
            apex.item("P96_TOEW_PERSOON_ID").hide();
            apex.item("P96_TOEW_ORG_UNIT_ID").hide();
            break;
        default:
            apex.item("P96_TOEW_PERSOON_ID").hide();
            apex.item("P96_TOEW_ORG_UNIT_ID").hide();
    }
}
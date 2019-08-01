/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Page10
     **/
Rmg.Srm.Page10 = Rmg.Srm.Page10 || {}
    /**
     * @function offerteVersturen
     * @example Rmg.Srm.Page10.offerteVersturen();
     **/
Rmg.Srm.Page10.offerteVersturen = function() {
    var comfirmationString = voornaam + ", ben je zeker dat je de offerte wilt versturen ?";
    Rmg.Srm.Utils.customComfirm(comfirmationString, function(okPressed) {
        if (okPressed) {
            apex.server.process("TAAK_OVERNEMEN", {
                x01: id,
                x02: persoonId
            }, {
                dataType: 'text',
                success: function(pData) {
                    apex.item('P81_TAAK_STATE_CODE').setValue("In execution");
                    apex.message.alert("Taak succesvol overgenomen");
                    var url = "f?p=" + $v('pFlowId') + ":TASK_OVERVIEW:" + $v('pInstance') + ":::::";
                    window.location.assign(url);
                }
            });
        }
    }, "Ja", "Nee");
}
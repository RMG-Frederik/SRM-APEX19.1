/**
 * @namespace Rmg
 **/
var Rmg = Rmg || {}
    /**
     * @namespace Rmg.Srm
     **/
Rmg.Srm = Rmg.Srm || {}
    /**
     * @namespace Rmg.Srm.Page81
     **/
Rmg.Srm.Page81 = Rmg.Srm.Page81 || {}
    /**
     * @function taakOvernemen
     * @example Rmg.Srm.Page81.taakOvernemen(taakId,persoonId,voornaam);
     **/
Rmg.Srm.Page81.taakOvernemen = function(id, persoonId, voornaam) {
        var comfirmationString = voornaam + ", ben je zeker dat je de taak " + id + " wilt overnemen ?";
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
                    }
                });
            }
        }, "Ja", "Nee");
    }
    /**
     * @function taakSluiten
     * @example Rmg.Srm.Page81.taakSluiten(taakId,status,opmerking,voornaam);
     **/
Rmg.Srm.Page81.taakSluiten = function(id, state, remark, voornaam) {
    var comfirmationString = voornaam + ", ben je zeker dat je de taak " + id + " wilt sluiten ?";
    apex.message.confirm(comfirmationString, function(okPressed) {
        if (okPressed) {
            apex.server.process("TAAK_SLUITEN", {
                x01: id,
                x02: state,
                x03: remark
            }, {
                dataType: 'text',
                success: function(pData) {
                    var url = "f?p=" + $v('pFlowId') + ":TASK_OVERVIEW:" + $v('pInstance') + ":::::";
                    window.location.assign(url);
                }
            });
        }
    });
}
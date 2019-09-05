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
        var comfirmationString = voornaam + ", bent u zeker dat u de taak " + id + " wilt overnemen ?";
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
    /**
     * @function taakSluiten
     * @example Rmg.Srm.Page81.taakSluiten(taakId,status,opmerking,voornaam);
     **/
Rmg.Srm.Page81.taakSluiten = function(id, isCancelled, remark, voornaam) {
    var state = "COMPLETED";
    if (isCancelled) state = "CANCELLED";
    var comfirmationString = "Bent u zeker dat u deze taak wenst te sluiten?";
    Rmg.Srm.Utils.customComfirm(comfirmationString, function(okPressed) {
        if (okPressed) {
            apex.server.process("TAAK_SLUITEN", {
                x01: id,
                x02: state,
                x03: remark
            }, {
                dataType: 'text',
                success: function(pData) {
                    if (isCancelled) {
                        var url = "f?p=" + $v('pFlowId') + ":TASK_OVERVIEW:" + $v('pInstance') + ":::::";
                        window.location.assign(url);
                    } else {
                        Rmg.Srm.Utils.customComfirm("Wenst u een vervolgtaak aan te maken ?", function(okPressed) {
                            if (okPressed) {
                                var url = "f?p=" + $v('pFlowId') + ":TASK_CREATE:" + $v('pInstance') + ":::::";
                                window.location.assign(url);
                            }
                        }, "Ja", "Nee");
                    }
                }
            });
        }
    }, "Ja", "Nee");
}

/**
 * @function taakUitvoeren
 * @example Rmg.Srm.Page81.taakUitvoeren();
 **/
Rmg.Srm.Page81.taakUitvoeren = function(pOffId) {
    var url = "f?p=" + $v('pFlowId') + ":OFF:" + $v('pInstance') + "::::::P10_OFFERTE_ID:" + pOffId;
    window.location.assign(url);
}
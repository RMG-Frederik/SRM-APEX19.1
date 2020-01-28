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
        var confirmationString = voornaam + ", bent u zeker dat u de taak " + id + " wilt overnemen ?";
        Rmg.Srm.Utils.customConfirm(confirmationString, function(okPressed) {
            if (okPressed) {
                apex.server.process("TAAK_OVERNEMEN", {
                    x01: id,
                    x02: persoonId
                }, {
                    dataType: 'text',
                    success: function(pData) {
                        apex.item('P81_TAAK_STATE_CODE').setValue("In execution");
                        apex.navigation.dialog.close( true,apex.util.makeApplicationUrl({pageId:80}));
                    }
                });
            }
        }, "Ja", "Nee");
    }

    /**
     * @function taakSluiten
     * @example Rmg.Srm.Page81.taakSluiten(taakId,status,opmerking,voornaam);
     **/
    Rmg.Srm.Page81.taakSluiten = function(id, isCancelled, remark, hasFu) {
        var state = "COMPLETED";
        var confirmationString = "Bent u zeker dat u deze taak wenst te sluiten?";
        if (isCancelled) {
            state = "CANCELLED";
            confirmationString = "Bent u zeker dat u deze taak wenst te annuleren?";
        } 
        Rmg.Srm.Utils.customConfirm(
            confirmationString,
            function( okPressed ) { if( okPressed ) { Rmg.Srm.Page81.processClose(id,state,remark,isCancelled,hasFu);}},
            "Ja",
            "Nee"
        );    
    
    }  
    Rmg.Srm.Page81.processClose = function(id,state,remark,isCancelled,hasFu) 
    {
        apex.server.process(
            "TAAK_SLUITEN",
            {x01: id,x02: state,x03: remark},
            {dataType: 'text',
                success: function(pData) {
                    if (isCancelled) apex.navigation.dialog.close( true,apex.util.makeApplicationUrl({pageId:80})); 
                    else Rmg.Srm.Page81.executeClose(hasFu);                 
                }
            }   
        )
    }
    
    Rmg.Srm.Page81.executeClose = function(hasFu) 
    {
        if (hasFu == 1) {
            Rmg.Srm.Utils.customConfirm(
                "Wenst u een vervolgtaak aan te maken ?",
                function(okPressed) {
                    if (okPressed) Rmg.Srm.Generated.goToModal82(); else apex.navigation.dialog.close( true,apex.util.makeApplicationUrl({pageId:80}));                  
                },
                "Ja",
                "Nee"
            ); 
        }
        else apex.navigation.dialog.close( true,apex.util.makeApplicationUrl({pageId:80})); 
    }

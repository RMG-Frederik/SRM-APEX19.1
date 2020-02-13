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
     * @example Rmg.Srm.Page81.taakOvernemen(persoonId);
     **/
    Rmg.Srm.Page81.taakOvernemen = function(persoonId) {
        apex.jQuery("#P81_OWNER_PERSOON_ID").val(persoonId).trigger("change");
       // apex.item('P81_OWNER_PERSOON_ID').setValue(persoonId);
        apex.item('P81_TAAK_STATE_CODE').setValue("In execution");
    
    }


    /**
     * @function taakSluiten
     * @example Rmg.Srm.Page81.taakSluiten(taakId,status,opmerking);
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
            function( okPressed ) { if( okPressed ) { Rmg.Srm.Page81.processClose(id,state,remark,hasFu);}},
            "Ja",
            "Nee"
        );    
    
    }  
    Rmg.Srm.Page81.processClose = function(id,state,remark,hasFu) 
    {
        apex.server.process(
            "TAAK_SLUITEN",
            {x01: id,x02: state,x03: remark},
            {dataType: 'text',
                success: function(pData) {
                     Rmg.Srm.Page81.executeClose(hasFu);                 
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
                    if (okPressed) goToModal82(); 
                    else location.reload();
                    //else apex.navigation.dialog.close( true,apex.util.makeApplicationUrl({pageId: &AI_REFERAL_PAGE.}));                  
                },
                "Ja",
                "Nee"
            ); 
        }
        else location.reload();
        //else apex.navigation.dialog.close( true,apex.util.makeApplicationUrl({pageId: &AI_REFERAL_PAGE.})); 
    }

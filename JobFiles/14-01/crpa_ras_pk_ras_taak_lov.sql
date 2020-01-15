create or replace package RAS.PK_RAS_TAAK_LOV as
/******************************************************************************
   NAME:       PK_RAS_TAAK_LOV
   PURPOSE:    Contains all functions used for creating LOV items 

   REVISIONS:
   Ver        Date        Author             Description
   ---------  ----------  ---------------    ------------------------------------
   1.0        06/01/2020  Frederik Vantroys  2. Created package
******************************************************************************/

  -- Public type declarations
  type display_value_pair is record(
    display_value varchar2(255),
    return_value  varchar2(255)
  );
  type display_value_pair_group is record(
    display_value varchar2(255),
    return_value  varchar2(255),
    group_value  varchar2(255)
  );
  type tt_dvp is table of display_value_pair;
  type tt_dvpg is table of display_value_pair_group;
  
  -- Get list of taak categories based on unit and object
  FUNCTION taak_cat_for_unit_and_obj(p_org_unit_id NUMBER,p_object_code VARCHAR2 DEFAULT 'TAAK') RETURN tt_dvp pipelined;

end PK_RAS_TAAK_LOV;
/

create or replace PACKAGE BODY RAS.PK_RAS_TAAK_LOV AS
/******************************************************************************
   NAME:       PK_RAS_TAAK_LOV
   PURPOSE:    Contains all functions used for creating LOV items 

   REVISIONS:
   Ver        Date        Author             Description
   ---------  ----------  ---------------    ------------------------------------
   1.0        06/01/2020  Frederik Vantroys  2. Created package body
******************************************************************************/

FUNCTION taak_cat_for_unit_and_obj(p_org_unit_id NUMBER,p_object_code VARCHAR2 DEFAULT 'TAAK') RETURN tt_dvp pipelined is
t_retval display_value_pair;
    cursor c_lov is
     select cat.categorie_oms as display_value,
             catobj.object_categorie_id as return_value
     FROM ras_ta_categorie cat, ras_ta_categorie_org_unit catou,ras_ta_object_categorie catobj, ras_object obj
    WHERE catou.org_unit_id IN (SELECT DISTINCT org_unit_id FROM TABLE(pk_cebe_org_general.f_get_org_units(p_org_unit_id)))
    AND catobj.categorie_id = cat.categorie_id
    AND catou.categorie_id = cat.categorie_id
    AND obj.object_code = p_object_code
    AND catobj.object_id = obj.object_id
    order by display_value;    
 
  BEGIN    
    for ii in c_lov
    loop
      t_retval.display_value := ii.display_value;
      t_retval.return_value  := ii.return_value;
      pipe row(t_retval);
    end loop;
    
  END taak_cat_for_unit_and_obj;

END PK_RAS_TAAK_LOV;
/

GRANT EXECUTE ON RAS.PK_RAS_TAAK_LOV TO SRM;

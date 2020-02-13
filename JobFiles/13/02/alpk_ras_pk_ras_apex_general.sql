create or replace PACKAGE     RAS.PK_RAS_APEX_GENERAL
authid current_user
AS
/******************************************************************************
   NAME:       PK_RAS_APEX_GENERAL
   PURPOSE:   Alle generieke apex functionaliteit eigen aan RMG applicaties.
              BV AUDITgegevens

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        5/10/2018      jvandeke       1. Created this package.
   1.1        28/01/2020     fvvantroy      2. added procedure generate js function modal redirect
******************************************************************************/

  FUNCTION f_get_audit_record(par_table IN VARCHAR2, par_key_field IN VARCHAR2, par_id IN NUMBER) RETURN OBJ_RAS_AUDIT;
  
  PROCEDURE p_generate_redirect_modal (par_page IN VARCHAR2,
                                       par_items IN VARCHAR2 default null, 
                                       par_values IN VARCHAR2 default null);

END RAS.PK_RAS_APEX_GENERAL;
/

create or replace PACKAGE BODY     RAS.PK_RAS_APEX_GENERAL
AS

/******************************************************************************
   NAME:       PK_RAS_APEX_GENERAL
   PURPOSE:   Alle generieke apex functionaliteit eigen aan RMG applicaties.
              BV AUDITgegevens

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        5/10/2018      jvandeke       1. Created this package.
******************************************************************************/

FUNCTION f_get_audit_record(par_table IN VARCHAR2, par_key_field IN VARCHAR2, par_id IN NUMBER) RETURN OBJ_RAS_AUDIT IS
  loc_audit_record OBJ_RAS_AUDIT := OBJ_RAS_AUDIT(null,null,null,null);
  loc_audit_query VARCHAR2(1024);
  loc_creatie_door VARCHAR2(10);
  loc_creatie_datum DATE;
  loc_mutatie_door VARCHAR2(10);
  loc_mutatie_datum DATE;

  TYPE AuditCurTyp IS REF CURSOR;
  audit_cursor   AuditCurTyp;
BEGIN
  loc_audit_query := 'SELECT creatie_door, creatie_datum, mutatie_door, mutatie_datum FROM ' || par_table || ' WHERE ' || par_key_field || ' = ' || par_id;
dbms_output.put_line(loc_audit_query);
  BEGIN
    OPEN audit_cursor FOR loc_audit_query;
    FETCH audit_cursor INTO loc_creatie_door, loc_creatie_datum, loc_mutatie_door, loc_mutatie_datum;
    CLOSE audit_cursor;
    loc_audit_record := OBJ_RAS_AUDIT(loc_creatie_door, loc_creatie_datum, loc_mutatie_door, loc_mutatie_datum);
--  EXCEPTION
--    WHEN OTHERS THEN loc_audit_record := NULL;
  END;

  RETURN loc_audit_record;
END f_get_audit_record;

procedure p_generate_redirect_modal (par_page in  varchar2 ,
                                     par_items in varchar2 default null, 
                                     par_values in varchar2 default null) AS

  url varchar2(4000);

BEGIN
  url := apex_page.get_url(p_page => par_page,
                           p_items  => par_items,
                           p_values =>  par_values );
      
  url := substr(url, length('javascript:')+1);
  
  htp.prn('<script>');
  htp.prn('function goToModal' || par_page || ' () {');
  htp.prn(url);
  htp.prn('}');
  htp.p('</script>');
  
  
END p_generate_redirect_modal;

END RAS.PK_RAS_APEX_GENERAL;
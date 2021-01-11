CREATE OR REPLACE VIEW XXTC_ENC_BAT_SEPA_CZ
(BATCH_NAME)
AS 
SELECT   a.checkrun_name
    FROM ap_invoice_selection_criteria a,
         ap_check_stocks b,
         fnd_lookup_values flv
   WHERE a.check_stock_id = b.check_stock_id
     AND a.org_id = b.org_id
     AND a.status = 'CONFIRMED'
     AND flv.lookup_type = 'XXTC_CITI_PAY_FORMAT_FILE'
     and flv.DESCRIPTION = 'XXTL SEPA Unstrd SD Payment SK'
     AND flv.attribute12 = a.bank_account_name
     AND b.NAME = flv.attribute13
     AND a.org_id = flv.attribute14
     and trunc(a.creation_date) >= '05-JAN-2020'
     AND NOT EXISTS (SELECT *
                       FROM xxtc_citi_pay_batch_sts aa
                      WHERE a.checkrun_id = aa.checkrun_id)
     AND (a.org_id, a.checkrun_name) IN (
            SELECT fpov.profile_option_value,
                   fndr.argument1
              FROM apps.fnd_profile_options_vl fpo,
                   apps.fnd_responsibility_vl frv,
                   apps.fnd_profile_option_values fpov,
                   apps.hr_organization_units hou,
                   apps.fnd_concurrent_requests fndr
             WHERE fpov.profile_option_value = TO_CHAR (hou.organization_id)
               AND fpo.profile_option_id = fpov.profile_option_id
               AND fpo.user_profile_option_name = 'MO: Operating Unit'
               AND frv.responsibility_id = fpov.level_value
               AND frv.responsibility_id = fndr.responsibility_id
               AND fndr.concurrent_program_id = 32475)
ORDER BY a.creation_date DESC
/

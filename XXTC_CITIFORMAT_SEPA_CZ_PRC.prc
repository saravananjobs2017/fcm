CREATE OR REPLACE PROCEDURE APPS.XXTC_CITIFORMAT_SEPA_CZ_PRC (errbuf  OUT VARCHAR2
                                           , retcode OUT NUMBER
                                           , p_batch IN  VARCHAR2) AS
      v_format_pgm     VARCHAR2(240);
      v_org_id     NUMBER:= fnd_profile.value('org_id');
      l_errbuff VARCHAR2(2000);
      l_retcode VARCHAR2(10);     
      g_num_rec_id       NUMBER;
      l_count NUMBER:=0;

 BEGIN
      
    SELECT count(*)
        INTO l_count
    FROM APPS.XXTC_CITI_PAY_BATCH_STS sts, ap_invoice_selection_criteria apv
    WHERE sts.BATCH_NAME =  p_batch
        AND  sts.STATUS = 'TRANSFERRED'
        AND sts.CHECKRUN_ID = apv.CHECKRUN_ID
        and apv.org_id = v_org_id;

    IF l_count > 0  THEN
        RAISE_APPLICATION_ERROR(-20001,'This Payment Batch File is already transfered to Citi Bank');
    END IF;   
										
	SELECT  distinct flv.description INTO v_format_pgm
      FROM fnd_lookup_values flv, ap_check_stocks_all apc, ap_invoice_selection_criteria aisc
     WHERE flv.lookup_type = 'XXTC_CITI_PAY_FORMAT_FILE'
       AND flv.ATTRIBUTE14 = aisc.org_id
       AND UPPER(flv.ATTRIBUTE13) = UPPER(apc.NAME)
       AND apc.bank_account_id = aisc.bank_account_id
       and apc.org_id = aisc.org_id
       and flv.attribute12 = aisc.bank_account_name
       and apc.check_stock_id = aisc.check_stock_id
       and aisc.checkrun_name = p_batch
       and aisc.status = 'CONFIRMED'
       and aisc.org_id = v_org_id;									
	   
     IF v_format_pgm = 'XXTL SEPA Unstrd SD Payment SK' THEN
          fnd_file.put_line(fnd_file.log,'Call SEPA Unstrd SD Payment Program for SK');
          retcode:=0;
      ELSE
          fnd_file.put_line(fnd_file.log,'Submit the respective SEPA CDFF Program');
          retcode:=2;
          errbuf:=SQLERRM;          
     END IF;
     

 EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Exception in main program');
       DBMS_OUTPUT.PUT_LINE(SQLCODE||' Error :'||SQLERRM);
 --       RAISE_APPLICATION_ERROR(-20001,'Batch is not comfirmed');
 retcode:=2;
    errbuf:=SQLERRM;
 END;
/

CREATE OR REPLACE PROCEDURE APPS.XXTC_CITIFORMAT_PGM_PRC (errbuf  OUT VARCHAR2
                                           , retcode OUT NUMBER
                                           , p_batch IN  VARCHAR2) AS
      v_format_pgm     VARCHAR2(240);
      v_org_id     NUMBER:= fnd_profile.value('org_id');
      l_errbuff VARCHAR2(2000);
      l_retcode VARCHAR2(10);

 BEGIN
										
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


     IF v_format_pgm = 'XXTC TCORE Electronic' THEN
          fnd_file.put_line(fnd_file.log,'Calling CZK Payment Batch Program');
        XXTC_CITI_PAYMENT_BATCH_FCZ.format_CZ(l_errbuff,l_retcode, p_batch);
      ELSE
          fnd_file.put_line(fnd_file.log,'Calling Foreign Currency Payment Batch Program');
        XXTC_CITI_PAY_BTH_CZ_SK.format(l_errbuff,l_retcode, p_batch);
     END IF;

      IF    l_errbuff    IS    NOT    NULL    THEN
        retcode:=1;
        errbuf:=l_errbuff;
        fnd_file.put_line(fnd_file.log,'Warning in Calling program ....'||l_errbuff);
    ELSE
        retcode:=0;
        fnd_file.put_line(fnd_file.log,'No error');
    END    IF;


 EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Exception in main program');
       DBMS_OUTPUT.PUT_LINE(SQLCODE||' Error :'||SQLERRM);
 --       RAISE_APPLICATION_ERROR(-20001,'Batch is not comfirmed');
 retcode:=2;
    errbuf:=SQLERRM;
 END;
/

<?xml version="1.0" encoding="UTF-8"?>
<!-- $Header: APSEPATEMPLATE_UNSTRD_en.xsl 115.10 2012/01/17 06:51:24 asarada noship $ -->
<!-- dbdrv: exec java oracle/apps/xdo/oa/util XDOLoader.class java &phase=dat checkfile:~PROD:patch/115/publisher/templates:APSEPATEMPLATE_UNSTRD_en.xsl UPLOAD -DB_USERNAME &un_apps -DB_PASSWORD &pw_apps -JDBC_CONNECTION &jdbc_db_addr -LOB_TYPE TEMPLATE -APPS_SHORT_NAME SQLAP -LOB_CODE APXSEPAU_XSL -LANGUAGE en -XDO_FILE_TYPE XSL-XML -FILE_NAME &fullpath:~PROD:patch/115/publisher/templates:APSEPATEMPLATE_UNSTRD_en.xsl -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>
<!-- This is the primary template which decides the Final XML output Structure -->
<xsl:template match="/">
<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <CstmrCdtTrfInitn>
                <xsl:call-template name="GroupHeader"/><!-- The Header Section of the Payment Format Message -->
                <!-- The SEPA Payment Format can be only be Mixed as part of SEPA 3.3 -->
                <!-- Payment Information Block repeats only once for the related Credit Blocks -->
                <xsl:if test="/XXTC_CZSEPA_XML/LIST_PMTINF/PMTINF != ''">
					<PmtInf>
                        <xsl:call-template name="PaymentInf"/>
                        <xsl:for-each select="/XXTC_CZSEPA_XML/LIST_PMTINF/PMTINF/LIST_CDTTRFTXINF/CDTTRFTXINF"><!-- Loop for Generating XML Group for each Credit Transaction -->
                                <xsl:call-template name="CreditTransaction"/><!-- The Credit Information Block -->
                        </xsl:for-each>
					</PmtInf>
				</xsl:if>
				 <!-- The EFT Payment Format can be only be Mixed as part of EFT 3.3 -->
                <!-- Payment Information Block repeats only once for the related Credit Blocks -->
				<xsl:if test="/XXTC_CZSEPA_XML/LIST_PMTINFF/PMTINFF != ''">
					<PmtInf>
                        <xsl:call-template name="PaymentInff"/>
                        <xsl:for-each select="/XXTC_CZSEPA_XML/LIST_PMTINFF/PMTINFF/LIST_CDTTRFTXINFF/CDTTRFTXINFF"><!-- Loop for Generating XML Group for each Credit Transaction -->
                                <xsl:call-template name="CreditTransactionn"/><!-- The Credit Information Block -->
                        </xsl:for-each>
					</PmtInf>
				</xsl:if>
        </CstmrCdtTrfInitn>
</Document>
<xsl:text>&#10;</xsl:text>
</xsl:template>
<xsl:template name="GroupHeader"><!-- Template for Generating the Header Information -->
        <xsl:variable name="path" select="/XXTC_CZSEPA_XML/LIST_GRPHDR/GRPHDR"/><!-- variable $path set to avoid repeatation of the absolute path -->
                <GrpHdr>
                        <MsgId><xsl:value-of select="$path/MSGID"/></MsgId><!-- Unique Message Id for the Payment -->
                        <CreDtTm><xsl:value-of select="$path/CREDTTM"/></CreDtTm><!-- Creation Time of the Message -->
                        <NbOfTxs><xsl:value-of select="$path/NBOFTXS"/></NbOfTxs><!-- Number of Credit Transactions in the Payment -->
                        <CtrlSum><xsl:value-of select="format-number($path/CTRLSUM, '###0.00')"/></CtrlSum><!-- Sum of all the payment amounts avinash-->
                        <InitgPty><!-- Initiating Party Details Starts -->
                                <Nm><xsl:value-of select="$path/NM"/></Nm><!-- Name of the Party -->
								<xsl:if test="$path/TAXIDNB != ''">
                                <Id>
                                        <OrgId>
                                                <Othr>
                                                        <Id><xsl:value-of select="$path/TAXIDNB"/></Id><!-- VAT registration number -->
                                                </Othr>
                                        </OrgId>
                                </Id>
								</xsl:if>
                        </InitgPty><!-- Initiating Party Details Ends -->
                </GrpHdr>
</xsl:template>
<xsl:template name="PaymentInf"><!-- Template for Generating the Payment Information/Debitor Information -->
        <xsl:variable name="path" select="/XXTC_CZSEPA_XML/LIST_PMTINF/PMTINF"/><!-- variable $path set to avoid repeatation of the absolute path -->
        <xsl:variable name="batchpath" select="/XXTC_CZSEPA_XML/LIST_GRPHDR/GRPHDR"/><!-- variable $batchpath set to avoid repeatation of the absolute path to get BtchBookg -->
                        <PmtInfId><xsl:value-of select="$path/PINF"/></PmtInfId><!-- Payment Information Identification/ Payment Batch Name -->
                        <PmtMtd><xsl:value-of select="$path/PMTMTD"/></PmtMtd><!-- Payment Method/ Transfer in case of SEPA -->
                        <BtchBookg><xsl:value-of select="$batchpath/BTCHBOOKG"/></BtchBookg><!-- Batch Booking mode if True/False for the payment -->
                        <NbOfTxs><xsl:value-of select="count($path/LIST_CDTTRFTXINF/CDTTRFTXINF)"/></NbOfTxs><!-- Number of Credit Transactions in the Payment -->
                        <CtrlSum><xsl:value-of select="format-number(sum($path/LIST_CDTTRFTXINF/CDTTRFTXINF/INSTDAMT), '###0.00')"/></CtrlSum><!-- Sum of all the payment amounts -->
                        <PmtTpInf><!-- Added for Bug 6832912 -->
                                <InstrPrty><xsl:value-of select="$path/INSTRPRTY"/></InstrPrty><!-- Indicator of the urgency or order of importance -->
                                <SvcLvl>
                                        <Cd>
                                                <xsl:value-of select="$path/SRVLVL"/>
                                        </Cd>
                                </SvcLvl><!-- Service Level/ For SEPA the Service Level is SEPA ; moved for Bug 6832912-->
								<LclInstrm> <!-- Avinash start -->
										<Cd>
												<xsl:value-of select="$path/LOCINST"/>
										</Cd>
								</LclInstrm><!-- Avinash end -->
                                <CtgyPurp>
									<Cd><xsl:value-of select="$path/CTGYPURP"/></Cd> <!-- Payment category -->
								</CtgyPurp>
                        </PmtTpInf>
                        <ReqdExctnDt><xsl:value-of select="$path/REQDEXCTNDT"/></ReqdExctnDt><!-- Requested Execution Date/ The Date when the initiating party requests clearing agent to process the payment -->
                        <Dbtr><!-- Debitor Details Starts -->
                                <Nm><xsl:value-of select="$path/NM"/></Nm><!-- Name of the Debitor -->
                                <PstlAdr>
										<Ctry><xsl:value-of select="$path/CTRY"/></Ctry><!-- Country -->
                                        <AdrLine><xsl:value-of select="$path/ADRLINE1"/></AdrLine><!-- Address line one of legal entity -->
                                        <xsl:if test="not($path/ADRLINE2 ='')"><!-- Condition to check Null Values -->
                                                <AdrLine><xsl:value-of select="$path/ADRLINE2"/></AdrLine><!-- Address line two of legal entity -->
                                        </xsl:if>
                                </PstlAdr>
                                <Id>
                                        <OrgId>
                                                <Othr><Id><xsl:value-of select="$path/BIC"/></Id></Othr>
                                        </OrgId>
                                </Id>
                        </Dbtr>
                        <DbtrAcct>
                                <Id>
                                        <IBAN>
                                                <xsl:value-of select="$path/ID"/><!-- Debitor Account -->
                                        </IBAN>
                                </Id>
                                <Ccy><xsl:value-of select="$path/CCY"/></Ccy><!-- Currency of the debtor bank account -->
                        </DbtrAcct>
                        <DbtrAgt>
                                <FinInstnId>
                                        <BIC><xsl:value-of select="$path/BIC"/></BIC><!-- Debitor Bank -->
                                </FinInstnId>
                        </DbtrAgt>
                        <ChrgBr><xsl:value-of select="$path/BNKCHR"/></ChrgBr><!-- Bank Charge Bearer/ Its SLEV for SEPA always -->
</xsl:template>
<xsl:template name="CreditTransaction"><!-- Template for Generating the Credit Transaction Information/Supplier Information and Invoice Details -->
<xsl:text>&#10;</xsl:text>
<CdtTrfTxInf>
                                <PmtId>
                                        <InstrId><xsl:value-of select="INSTRID"/></InstrId>
                                        <EndToEndId><xsl:value-of select="ENDTOENDIDD"/></EndToEndId><!-- Unique Payment Identification Id/ CHECK_NUMBER used for Payment -->
                                </PmtId>
                                <Amt>
                                        <InstdAmt>
                                        <xsl:attribute name="Ccy">
                                        <xsl:value-of select="CURR"/><!-- Payment Currency -->
                                        </xsl:attribute>
                                        <xsl:value-of select="format-number(INSTDAMT, '###0.00')"/><!-- Amount of Money to be moved -->
                                        </InstdAmt>
                                </Amt>
                                <CdtrAgt>
                                        <FinInstnId>
                                                <BIC><xsl:value-of select="BIC"/></BIC><!-- Benificiary Bank/ Supplier Bank -->
                                        </FinInstnId>
                                </CdtrAgt>
                                <Cdtr>
                                <!-- Creditor Details Starts -->
                                        <Nm><xsl:value-of select="NM"/></Nm><!-- Name of the Creditor -->
                                        <PstlAdr>
												<Ctry><xsl:value-of select="CTRY"/></Ctry><!-- Country -->
                                                <AdrLine><xsl:value-of select="ADRLINE1"/></AdrLine><!-- Address Line 1 -->
                                                <xsl:if test="not(ADRLINE2 ='')"><!-- Condition to check Null Values -->
                                                        <AdrLine><xsl:value-of select="ADRLINE2"/></AdrLine><!-- Address Line 2 -->
                                                </xsl:if>
                                        </PstlAdr>
										<Id>
                                                <OrgId>
                                                    <Othr>
														<Id><xsl:value-of select="BIC"/></Id>
													</Othr>
                                                </OrgId>
                                        </Id>
                                </Cdtr>
                                <CdtrAcct>
                                        <Id>
                                                <IBAN>
                                                        <xsl:value-of select="ID"/><!-- Creditor Account -->
                                                </IBAN>
                                        </Id>
                                </CdtrAcct>
                                <Purp>
                                        <Cd><xsl:value-of select="CD"/></Cd>
                                </Purp>
                                <RmtInf>
                                    <!-- Start of Unstructured Remmittance Information -->
                                        <!-- Delimiter used is ',' and for differentiating different Invoices delimiter is ':' -->
					<!-- Bug 10396809 - CHANGE SEPARATOR CHARACTER IN SEPA UNSTRUCTURED PAYMENT FORMAT FOR 11I - Delimiter is now ':'-->
                                        <Ustrd> <!-- Modified tag for Bug 7324969 -->
                                        <!-- Begin:7355566 Variable RmtInfo to hold value of Remittance Information-->
                                                <xsl:variable name="RmtInfo">
                                                        <xsl:for-each select="LIST_RMTINF/RMTINF">
                                                        <!-- Loop to generate a group for every Invoice in the Credit Transaction Block -->
                                                        <xsl:value-of select="RFRDDOCNB"/><!-- Invoice Number --><xsl:value-of select="','" />
                                                        <xsl:value-of select="RFRDDOCRLTDDT"/><!-- Invoice Date --><xsl:value-of select="','" />
                                                        <xsl:value-of select="format-number(DUEPYBLAMT, '###0.00')"/><!-- Invoice Amount --><xsl:value-of select="','" />
                                                        <xsl:value-of select="format-number(RMTDAMT, '###0.00')"/><!-- Payment Amount --><xsl:value-of select="':'" />
                                                        </xsl:for-each>
                                                </xsl:variable>
                                                <!--7355566: RmtInfo substringed to 125 chars to make RmtInf(Including Ustrd tags) 140 chars long-->
                                                <xsl:value-of select="substring($RmtInfo,1,125)"/>
                                                <!--End: bug#7355566-->
                                        </Ustrd> <!-- Modified tag for Bug 7324969 -->
                                </RmtInf>
</CdtTrfTxInf>
</xsl:template>
<xsl:template name="PaymentInff"><!-- Template for Generating the Payment Information/Debitor Information -->
        <xsl:variable name="pathh" select="/XXTC_CZSEPA_XML/LIST_PMTINFF/PMTINFF"/><!-- variable $path set to avoid repeatation of the absolute path -->
        <xsl:variable name="batchpathh" select="/XXTC_CZSEPA_XML/LIST_GRPHDR/GRPHDR"/><!-- variable $batchpath set to avoid repeatation of the absolute path to get BtchBookg -->
                        <PmtInfId><xsl:value-of select="$pathh/PINFF"/></PmtInfId><!-- Payment Information Identification/ Payment Batch Name -->
                        <PmtMtd><xsl:value-of select="$pathh/PMTMTDD"/></PmtMtd><!-- Payment Method/ Transfer in case of SEPA -->
                        <BtchBookg><xsl:value-of select="$batchpathh/BTCHBOOKG"/></BtchBookg><!-- Batch Booking mode if True/False for the payment -->
                        <NbOfTxs><xsl:value-of select="count($pathh/LIST_CDTTRFTXINFF/CDTTRFTXINFF)"/></NbOfTxs><!-- Number of Credit Transactions in the Payment -->
                        <CtrlSum><xsl:value-of select="format-number(sum($pathh/LIST_CDTTRFTXINFF/CDTTRFTXINFF/INSTDAMTT), '###0.00')"/></CtrlSum><!-- Sum of all the payment amounts -->
                        <PmtTpInf><!-- Added for Bug 6832912 -->
                                <InstrPrty><xsl:value-of select="$pathh/INSTRPRTYY"/></InstrPrty><!-- Indicator of the urgency or order of importance -->
                                <SvcLvl>
                                        <Cd>
                                                <xsl:value-of select="$pathh/SRVLVLL"/>
                                        </Cd>
                                </SvcLvl><!-- Service Level/ For SEPA the Service Level is SEPA ; moved for Bug 6832912-->
								<LclInstrm> <!-- Avinash start -->
										<Prtry>
												<xsl:value-of select="$pathh/LOCINSTT"/>
										</Prtry>
								</LclInstrm><!-- Avinash end -->
                                <CtgyPurp>
									<Cd><xsl:value-of select="$pathh/CTGYPURPP"/></Cd> <!-- Payment category -->
								</CtgyPurp>
                        </PmtTpInf>
                        <ReqdExctnDt><xsl:value-of select="$pathh/REQDEXCTNDTT"/></ReqdExctnDt><!-- Requested Execution Date/ The Date when the initiating party requests clearing agent to process the payment -->
                        <Dbtr><!-- Debitor Details Starts -->
                                <Nm><xsl:value-of select="$pathh/NMM"/></Nm><!-- Name of the Debitor -->
                                <PstlAdr>
										<Ctry><xsl:value-of select="$pathh/CTRYY"/></Ctry><!-- Country -->
                                        <AdrLine><xsl:value-of select="$pathh/ADRLINE11"/></AdrLine><!-- Address line one of legal entity -->
                                        <xsl:if test="not($pathh/ADRLINE22 ='')"><!-- Condition to check Null Values -->
                                                <AdrLine><xsl:value-of select="$pathh/ADRLINE22"/></AdrLine><!-- Address line two of legal entity -->
                                        </xsl:if>
                                </PstlAdr>
                                <Id>
                                        <OrgId>
                                                <Othr><Id><xsl:value-of select="$pathh/BICC"/></Id></Othr>
                                        </OrgId>
                                </Id>
                        </Dbtr>
                        <DbtrAcct>
                                <Id>
                                        <IBAN>
                                                <xsl:value-of select="$pathh/IDD"/><!-- Debitor Account -->
                                        </IBAN>
                                </Id>
                                <Ccy><xsl:value-of select="$pathh/CCYY"/></Ccy><!-- Currency of the debtor bank account -->
                        </DbtrAcct>
                        <DbtrAgt>
                                <FinInstnId>
                                        <BIC><xsl:value-of select="$pathh/BICC"/></BIC><!-- Debitor Bank -->
                                </FinInstnId>
                        </DbtrAgt>
                        <ChrgBr><xsl:value-of select="$pathh/BNKCHRR"/></ChrgBr><!-- Bank Charge Bearer/ Its SLEV for SEPA always -->
</xsl:template>
<xsl:template name="CreditTransactionn"><!-- Template for Generating the Credit Transaction Information/Supplier Information and Invoice Details -->
<xsl:text>&#10;</xsl:text>
<CdtTrfTxInf>
                                <PmtId>
                                        <InstrId><xsl:value-of select="INSTRIDD"/></InstrId>
                                        <EndToEndId><xsl:value-of select="ENDTOENDIDD2"/></EndToEndId><!-- Unique Payment Identification Id/ CHECK_NUMBER used for Payment -->
                                </PmtId>
                                <Amt>
                                        <InstdAmt>
                                        <xsl:attribute name="Ccy">
                                        <xsl:value-of select="CURRR"/><!-- Payment Currency -->
                                        </xsl:attribute>
                                        <xsl:value-of select="format-number(INSTDAMTT, '###0.00')"/><!-- Amount of Money to be moved -->
                                        </InstdAmt>
                                </Amt>
                                <CdtrAgt>
                                        <FinInstnId> <!-- Customised If BIC is missing-->
											<xsl:choose>
												<xsl:when test="BICC != ''">
													<BIC><xsl:value-of select="BICC"/></BIC> <!-- BIC Number -->
												</xsl:when>
												<xsl:otherwise>
													<Nm><xsl:value-of select="SBKNM"/></Nm> <!-- Bank Name -->
														<PstlAdr>
															<AdrLine><xsl:value-of select="SBKAD1"/></AdrLine> <!-- Bank address details -->
															<AdrLine><xsl:value-of select="SBKAD2"/></AdrLine>
															<AdrLine><xsl:value-of select="SBKCTY"/></AdrLine>
														</PstlAdr>
												</xsl:otherwise>
											</xsl:choose>
                                        </FinInstnId>
                                </CdtrAgt>
                                <Cdtr>
                                <!-- Creditor Details Starts -->
                                        <Nm><xsl:value-of select="NMM"/></Nm><!-- Name of the Creditor -->
                                        <PstlAdr>
												<Ctry><xsl:value-of select="CTRYY"/></Ctry><!-- Country -->
                                                <AdrLine><xsl:value-of select="ADRLINE11"/></AdrLine><!-- Address Line 1 -->
                                                <xsl:if test="not(ADRLINE22 ='')"><!-- Condition to check Null Values -->
                                                        <AdrLine><xsl:value-of select="ADRLINE22"/></AdrLine><!-- Address Line 2 -->
                                                </xsl:if>
                                        </PstlAdr>
										<xsl:if test="BICC != ''">
											<Id>
                                                <OrgId>
                                                    <Othr>
														<Id><xsl:value-of select="BICC"/></Id>
													</Othr>
                                                </OrgId>
											</Id>
										</xsl:if>
                                </Cdtr>
                                <CdtrAcct>
										<xsl:if test="((IDDD != '') or (SBANU!= ''))">
											<Id>
												<xsl:choose>
													<xsl:when test="IDDD != ''">
														<IBAN>
															<xsl:value-of select="IDDD" />
														</IBAN>
													</xsl:when>
													<xsl:otherwise>
														<Othr>
															<Id>
																<xsl:value-of select="SBANU" />
															</Id>
														</Othr>
													</xsl:otherwise>
												</xsl:choose>                                         
											</Id>
										</xsl:if>
                                </CdtrAcct>
                                <Purp>
                                        <Cd><xsl:value-of select="CDD"/></Cd>
                                </Purp>
                                <RmtInf>
                                    <!-- Start of Unstructured Remmittance Information -->
                                        <!-- Delimiter used is ',' and for differentiating different Invoices delimiter is ':' -->
					<!-- Bug 10396809 - CHANGE SEPARATOR CHARACTER IN SEPA UNSTRUCTURED PAYMENT FORMAT FOR 11I - Delimiter is now ':'-->
                                        <Ustrd> <!-- Modified tag for Bug 7324969 -->
                                        <!-- Begin:7355566 Variable RmtInfo to hold value of Remittance Information-->
                                                <xsl:variable name="RmtInfoo">
                                                        <xsl:for-each select="LIST_RMTINFF/RMTINFF">
                                                        <!-- Loop to generate a group for every Invoice in the Credit Transaction Block -->
                                                        <xsl:value-of select="RFRDDOCNBB"/><!-- Invoice Number --><xsl:value-of select="','" />
                                                        <xsl:value-of select="RFRDDOCRLTDDTT"/><!-- Invoice Date --><xsl:value-of select="','" />
                                                        <xsl:value-of select="format-number(DUEPYBLAMTT, '###0.00')"/><!-- Invoice Amount --><xsl:value-of select="','" />
                                                        <xsl:value-of select="format-number(RMTDAMTT, '###0.00')"/><!-- Payment Amount --><xsl:value-of select="':'" />
                                                        </xsl:for-each>
                                                </xsl:variable>
                                                <!--7355566: RmtInfo substringed to 125 chars to make RmtInf(Including Ustrd tags) 140 chars long-->
                                                <xsl:value-of select="substring($RmtInfoo,1,125)"/>
                                                <!--End: bug#7355566-->
                                        </Ustrd> <!-- Modified tag for Bug 7324969 -->
                                </RmtInf>
</CdtTrfTxInf>
</xsl:template>
</xsl:stylesheet>

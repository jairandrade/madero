
#DEFINE CONSULTAR 	1
#DEFINE CANCELAR 	2
#DEFINE ENVIAR        3

#include "protheus.ch" 
#include "tbiconn.ch"
#INCLUDE "FILEIO.CH"
#include "topconn.ch"

Static __nOperation

//-----------------------------------------------------------------------
/*/{Protheus.doc} nfseXMLEnv
Fun��o que monta o XML Unico de envio para NFS-e TSS / TOTVS Colaboracao 2.0

@author Marcos Taranta
@since 19.01.2012

@param	cTipo		Tipo do documento.
@param	dDtEmiss	Data de emiss�o do documento.
@param	cSerie		Serie do documento.
@param	cNota		Numero do documento.
@param	cClieFor	Cliente/Fornecedor do documento.
@param	cLoja		Loja do cliente/fornecedor do documento.
@param	cMotCancela	Motivo do cancelamento do documento.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
User function nfseXMLUni( cCodMun, cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela, aAIDF )

	Local nX		:= 0
	Local nW		:= 0
	Local nZ		:= 0

	Local cString    := ""
	Local cAliasSE1  := "SE1"
	Local cAliasSD2  := "SD2"
	local cCFPS      := ""
	Local cNatOper   := ""
	Local cModFrete  := ""
	Local cScan      := ""
	Local cEspecie   := ""
	Local cMensCli   := ""
	Local cMensFis   := ""
	Local cMV_LJTPNFE:= GetMV("MV_LJTPNFE", ," ")
	lOCAL cMVSUBTRIB := IIf(FindFunction("GETSUBTRIB"), GetSubTrib(), GetMV("MV_SUBTRIB"))
	Local cLJTPNFE   := ""
	Local cWhere     := ""
	Local cMunISS    := ""
	Local cTipoPcc   := "PIS','COF','CSL','CF-','PI-','CS-"
	Local cCodCli    := ""
	Local cLojCli    := ""
	Local cDescMunP  := ""
	local cMunPSIAFI := ""
	local cMunPrest  := ""
	Local cDescrNFSe := ""
	Local cDiscrNFSe := ""
	Local cField     := ""
	Local cTpCliente := ""
	Local cMVBENEFRJ := AllTrim(GetNewPar("MV_BENEFRJ"," "))
	Local cF4Agreg   := ""
	Local cNatOP     := "1"
	Local cFieldMsg  := ""
	Local cTpPessoa  := ""
	Local cCamSC5    := GetMV("MV_NFSECOM", .F., "") // Parametro que aponta para o campo do SC5 com a data da competencia
	Local lMvNFSEIR		:= GetMV("MV_NFSEIR", .F., .F.) // Pramentro para buscar o IRRF gravado n SD2 e n�o considerar apenas o acumulado

	Local aObra		 := &(GetMV("MV_XMLOBRA", ,"{,,,,,,,,,,,,,,}"))
	Local cLogradOb  := ""
	Local cCompleOb  := "" 
	Local cNumeroOb  := ""
	Local cBairroOb  := ""
	Local cCepOb     := ""
	Local cCodMunob  := ""
	Local cNomMunOb  := ""
	Local cUfOb 	   := ""
	Local cCodPaisOb := ""
	Local cNomPaisOb := ""
	Local cNumArtOb  := ""
	Local cNumCeiOb  := ""
	Local cNumProOb  := ""
	Local cNumMatOb  := ""
	Local cNumEncap  := "" // NumeroEncapsulamento
	Local cNatPCC		:= GetNewPar("MV_1DUPNAT","SA1->A1_NATUREZ") //-- Natureza considerada para retencao de PIS, COF, CSLL 
	Local cObsDtc	 := "" // Observacao DTC TMS
	Local cFntCtrb	:= ""
	Local cCondPag   := "" // Condi��o de pagamento E4_COND

	Local dDateCom 	:= Date()

	Local nRetPis   := 0
	Local nRetCof   := 0
	Local nRetCsl   := 0
	Local nPosI     := 0
	Local nPosF     := 0
	Local nAliq     := 0
	Local nCont     := 0
	Local nDescon   := 0
	Local nScan     := 0
	Local nRetDesc  := 0
	Local nValTotPrd:= 0
	Local nBasCsl   := 0
	Local nBasCof   := 0
	Local nBasPis   := 0

	Local lQuery    := .F.
	Local lCalSol   := .F.
	Local lEasy     := GetMV("MV_EASY") == "S"
	Local lEECFAT   := GetMV("MV_EECFAT")
	Local lAglutina := AllTrim(GetNewPar("MV_ITEMAGL","N")) == "S" //-- Aglutinar ITENS do RPS na geracao do XML
	Local lNatOper  := GetNewPar("MV_NFESERV","1") == "1" //-- Descr do servico 1-pedido vendas+SX5 ou 2-somente SX5
	Local lNFeDesc  := GetNewPar("MV_NFEDESC",.F.) //-- Descr do servico = pela tab. 60 e do produto = pedidos de vendas
	Local lNfsePcc  := GetNewPar("MV_NFSEPCC",.F.) //-- Considerar retencao de PIS, COF, CSLL
	Local lCrgTrib  := GetNewPar("MV_CRGTRIB",.F.)
	Local cNatPCC	  := GetNewPar("MV_1DUPNAT","SA1->A1_NATUREZ") //-- Natureza considerada para retencao de PIS, COF, CSLL 
	Local cNatBusc   := ""

	Local cMVREGIESP	:= getMV( "MV_REGIESP",, "" ) //-- Informar o Regime especial de tributacao para que seja gerada a TAG <RegimeEspecialTributacao>
	Local cMVOPTSIMP	:= allTrim( GetMV( "MV_OPTSIMP",, "2" ) ) //-- Contribuinte optante do simples: 1=sim;2=nao
	Local cMVINCEFIS	:= AllTrim(GetNewPar("MV_INCEFIS","2"))	

	Local aNota     := {}
	Local aDupl     := {}
	Local aDest     := {}
	Local aEntrega  := {}
	Local aProd     := {}
	Local aICMS     := {}
	Local aICMSST   := {}
	Local aIPI      := {}
	Local aPIS      := {}
	Local aCOFINS   := {}
	Local aPISST    := {}
	Local aCOFINSST := {}
	Local aISSQN    := {}
	Local aISS      := {}
	Local aCST      := {}
	Local aRetido   := {}
	Local aTransp   := {}
	Local aImp      := {}
	Local aVeiculo  := {}
	Local aReboque  := {}
	Local aEspVol   := {}
	Local aNfVinc   := {}
	Local aPedido   := {}
	Local aTotal    := {0,0,"",0,""}
	Local aOldReg   := {}
	Local aOldReg2  := {}
	Local aMed      := {}
	Local aArma     := {}
	Local aveicProd := {}
	Local aIEST     := {}
	Local aDI       := {}
	Local aAdi      := {}
	Local aExp      := {}
	Local aPisAlqZ  := {}
	Local aCofAlqZ  := {}
	Local aDeducao  := {}
	Local aRetServ  := {}
	Local aDeduz    := {}
	Local aConstr   := {}
	Local aInterm	:= {}
	Local aRetISS   := {}
	Local aRetPIS   := {}
	Local aRetCOF   := {}
	Local aRetCSL   := {}
	Local aRetIRR   := {}
	Local aRetINS   := {}
	Local cViaPublic := ""		

	Private aUF     := {}
	Private nLote := 0

	DEFAULT cCodMun     := PARAMIXB[1]
	DEFAULT cTipo       := PARAMIXB[2]
	DEFAULT cSerie      := PARAMIXB[4]
	DEFAULT cNota       := PARAMIXB[5]
	DEFAULT cClieFor    := PARAMIXB[6]
	DEFAULT cLoja       := PARAMIXB[7]
	DEFAULT cMotCancela := PARAMIXB[8]
	//	DEFAULT aAIDF       := PARAMIXB[9]

	//������������������������������������������������������������������������Ŀ
	//�Preenchimento do Array de UF                                            �
	//��������������������������������������������������������������������������
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	If cTipo == "1" .And. Empty(cMotCancela)
		//������������������������������������������������������������������������Ŀ
		//�Posiciona NF                                                            �
		//��������������������������������������������������������������������������
		dbSelectArea("SF2")
		dbSetOrder(1) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, R_E_C_N_O_, D_E_L_E_T_
		DbGoTop()
		If DbSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja)

			aadd(aNota,SF2->F2_SERIE)
			aadd(aNota,IIF(Len(SF2->F2_DOC)==6,"000","")+SF2->F2_DOC)
			aadd(aNota,SF2->F2_EMISSAO)
			aadd(aNota,cTipo)
			aadd(aNota,SF2->F2_TIPO)
			aadd(aNota,"1")
			aadd(aNota,IIF(Len(SF2->F2_DOC)==6,"000","")+AllTrim(SF2->F2_NFSUBST))
			aadd(aNota,AllTrim(SF2->F2_SERSUBS))
			aadd(aNota,AllTrim(SF2->F2_HORA) + ":" + SUBSTR(Time(), 7, 2))
			dbSelectArea("SE4")
			dbSetOrder(1)			
			If DbSeek(xFilial("SE4")+SF2->F2_COND)
				aadd(aNota,SE4->E4_DESCRI)
				cCondPag := SE4->E4_COND
			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Posiciona cliente ou fornecedor                                         �
			//��������������������������������������������������������������������������
			If !SF2->F2_TIPO $ "DB"
				If IntTMS()
					DT6->(DbSetOrder(1))
					If DT6->(DbSeek(xFilial("DT6")+SF2->(F2_FILIAL+F2_DOC+F2_SERIE)))
						cCodCli := DT6->DT6_CLIDEV
						cLojCli := DT6->DT6_LOJDEV
					Else
						cCodCli := SF2->F2_CLIENTE
						cLojCli := SF2->F2_LOJA
					EndIf
				Else
					cCodCli := SF2->F2_CLIENTE
					cLojCli := SF2->F2_LOJA
				EndIf

				dbSelectArea("SA1")
				dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
				DbSeek(xFilial("SA1")+cCodCli+cLojCli)

				aadd(aDest,AllTrim(SA1->A1_CGC))
				aadd(aDest,SA1->A1_NOME)
				aadd(aDest,myGetEnd(SA1->A1_END,"SA1")[1])
				aadd(aDest,convType(IIF(myGetEnd(SA1->A1_END,"SA1")[2]<>0,myGetEnd(SA1->A1_END,"SA1")[2],"SN")))
				aadd(aDest,IIF(SA1->(FieldPos("A1_COMPLEM")) > 0 .And. !Empty(SA1->A1_COMPLEM),SA1->A1_COMPLEM,myGetEnd(SA1->A1_END,"SA1")[4]))
				aadd(aDest,SA1->A1_BAIRRO)
				If !Upper(SA1->A1_EST) == "EX"
					aadd(aDest,SA1->A1_COD_MUN)
					aadd(aDest,SA1->A1_MUN)
				Else
					aadd(aDest,"9999999")
					aadd(aDest,"EXTERIOR")
				EndIf
				aadd(aDest,Upper(SA1->A1_EST))
				aadd(aDest,SA1->A1_CEP)
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
				aadd(aDest,SA1->A1_DDD+SA1->A1_TEL)
				aadd(aDest,vldIE(SA1->A1_INSCR,IIF(SA1->(FIELDPOS("A1_CONTRIB"))>0,SA1->A1_CONTRIB<>"2",.T.)))
				aadd(aDest,SA1->A1_SUFRAMA)
				aadd(aDest,SA1->A1_EMAIL)
				aadd(aDest,SA1->A1_INSCRM)
				aadd(aDest,SA1->A1_CODSIAF)
				aadd(aDest,SA1->A1_NATUREZ) //19 - Natureza no cliente
				aadd(aDest,Iif(!Empty(SA1->A1_SIMPNAC),SA1->A1_SIMPNAC,"2"))
				aadd(aDest,Iif(SA1->(FieldPos("A1_INCULT"))> 0 , Iif(!Empty(SA1->A1_INCULT),SA1->A1_INCULT,"2"), "2"))
				aadd(aDest,SA1->A1_TPESSOA)
				aadd(aDest,SF2->F2_DOC)
				aadd(aDest,SF2->F2_SERIE)
				aadd(aDest,Iif(SA1->(FieldPos("A1_OUTRMUN"))> 0 ,SA1->A1_OUTRMUN,""))	//25							
				aadd(aDest,Iif(SA1->(FieldPos("A1_PFISICA"))> 0 ,SA1->A1_PFISICA,""))	//26

				//������������������������������������������������������������������������Ŀ
				//�Posiciona Natureza                                                      �
				//��������������������������������������������������������������������������
				cNatBusc := NatPCC ( aDest , cNatPCC )
				DbSelectArea("SED")
				DbSetOrder(1) //ED_FILIAL+ED_CODIGO
				DbSeek(xFilial("SED")+ cNatBusc ) 

				If SF2->(FieldPos("F2_CLIENT"))<>0 .And. !Empty(SF2->F2_CLIENT+SF2->F2_LOJENT) .And. SF2->F2_CLIENT+SF2->F2_LOJENT<>SF2->F2_CLIENTE+SF2->F2_LOJA
					dbSelectArea("SA1")
					dbSetOrder(1)
					DbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)

					aadd(aEntrega,SA1->A1_CGC)
					aadd(aEntrega,myGetEnd(SA1->A1_END,"SA1")[1])
					aadd(aEntrega,convType(IIF(myGetEnd(SA1->A1_END,"SA1")[2]<>0,myGetEnd(SA1->A1_END,"SA1")[2],"SN")))
					aadd(aEntrega,myGetEnd(SA1->A1_END,"SA1")[4])
					aadd(aEntrega,SA1->A1_BAIRRO)
					aadd(aEntrega,SA1->A1_COD_MUN)
					aadd(aEntrega,SA1->A1_MUN)
					aadd(aEntrega,Upper(SA1->A1_EST))

				EndIf

			Else
				dbSelectArea("SA2")
				dbSetOrder(1)
				DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)

				aadd(aDest,AllTrim(SA2->A2_CGC))
				aadd(aDest,SA2->A2_NOME)
				aadd(aDest,myGetEnd(SA2->A2_END,"SA2")[1])
				aadd(aDest,convType(IIF(myGetEnd(SA2->A2_END,"SA2")[2]<>0,myGetEnd(SA2->A2_END,"SA2")[2],"SN")))
				aadd(aDest,IIF(SA2->(FieldPos("A2_COMPLEM")) > 0 .And. !Empty(SA2->A2_COMPLEM),SA2->A2_COMPLEM,myGetEnd(SA2->A2_END,"SA2")[4]))				
				aadd(aDest,SA2->A2_BAIRRO)
				If !Upper(SA2->A2_EST) == "EX"
					aadd(aDest,SA2->A2_COD_MUN)
					aadd(aDest,SA2->A2_MUN)
				Else
					aadd(aDest,"9999999")			
					aadd(aDest,"EXTERIOR")
				EndIf
				aadd(aDest,Upper(SA2->A2_EST))
				aadd(aDest,SA2->A2_CEP)
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR")))
				aadd(aDest,SA2->A2_DDD+SA2->A2_TEL)
				aadd(aDest,vldIE(SA2->A2_INSCR))
				aadd(aDest,"")//SA2->A2_SUFRAMA
				aadd(aDest,SA2->A2_EMAIL)
				aadd(aDest,SA2->A2_INSCRM)
				aadd(aDest,SA2->A2_CODSIAF)
				aadd(aDest,SA2->A2_NATUREZ)
				aadd(aDest,SA2->A2_SIMPNAC)
				aadd(aDest,"")	//Nota para empresa hospitalar utilizar apenas com SF2
				aadd(aDest,"")	//Serie para empresa hospitalar utilizar apenas com SF2
				aadd(aDest,"")//Nota para empresa hospitalar utilizar apenas com SF2
				aadd(aDest,"")//Serie para empresa hospitalar utilizar apenas com SF2
				aadd(aDest,"")//A1_OUTRMUN
				aadd(aDest,Iif(SA2->(FieldPos("A2_PFISICA"))> 0 ,SA2->A2_PFISICA,""))//26

				//������������������������������������������������������������������������Ŀ
				//�Posiciona Natureza                                                      �
				//��������������������������������������������������������������������������
				DbSelectArea("SED")
				DbSetOrder(1)
				DbSeek(xFilial("SED")+SA2->A2_NATUREZ)

			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Posiciona transportador                                                 �
			//��������������������������������������������������������������������������
			If !Empty(SF2->F2_TRANSP)
				dbSelectArea("SA4")
				dbSetOrder(1)
				DbSeek(xFilial("SA4")+SF2->F2_TRANSP)
				aadd(aTransp,AllTrim(SA4->A4_CGC))
				aadd(aTransp,SA4->A4_NOME)
				aadd(aTransp,SA4->A4_INSEST)
				aadd(aTransp,SA4->A4_END)
				aadd(aTransp,SA4->A4_MUN)
				aadd(aTransp,Upper(SA4->A4_EST)	)
				If !Empty(SF2->F2_VEICUL1)
					dbSelectArea("DA3")
					dbSetOrder(1)
					DbSeek(xFilial("DA3")+SF2->F2_VEICUL1)
					aadd(aVeiculo,DA3->DA3_PLACA)
					aadd(aVeiculo,DA3->DA3_ESTPLA)
					aadd(aVeiculo,"")//RNTC
					If !Empty(SF2->F2_VEICUL2)
						dbSelectArea("DA3")
						dbSetOrder(1)
						DbSeek(xFilial("DA3")+SF2->F2_VEICUL2)
						aadd(aReboque,DA3->DA3_PLACA)
						aadd(aReboque,DA3->DA3_ESTPLA)
						aadd(aReboque,"") //RNTC
					EndIf
				EndIf
			EndIf
			dbSelectArea("SF2")
			//������������������������������������������������������������������������Ŀ
			//�Volumes                                                                 �
			//��������������������������������������������������������������������������
			cScan := "1"
			While ( !Empty(cScan) )
				cEspecie := Upper(FieldGet(FieldPos("F2_ESPECI"+cScan)))
				If !Empty(cEspecie)
					nScan := aScan(aEspVol,{|x| x[1] == cEspecie})
					If ( nScan==0 )
						aadd(aEspVol,{ cEspecie, FieldGet(FieldPos("F2_VOLUME"+cScan)) , SF2->F2_PLIQUI , SF2->F2_PBRUTO})
					Else
						aEspVol[nScan][2] += FieldGet(FieldPos("F2_VOLUME"+cScan))
					EndIf
				EndIf
				cScan := Soma1(cScan,1)
				If ( FieldPos("F2_ESPECI"+cScan) == 0 )
					cScan := ""
				EndIf
			EndDo

			//������������������������������������������������������������������������Ŀ
			//�Procura duplicatas                                                      �
			//��������������������������������������������������������������������������

			If !Empty(SF2->F2_DUPL)	
				cLJTPNFE := (StrTran(cMV_LJTPNFE," ,"," ','"))+" "
				cWhere := cLJTPNFE
				dbSelectArea("SE1")
				dbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				#IFDEF TOP
				lQuery  := .T.
				cAliasSE1 := GetNextAlias()
				BeginSql Alias cAliasSE1
					COLUMN E1_VENCORI AS DATE
					SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCORI,E1_VALOR,E1_ORIGEM,E1_CSLL,E1_COFINS,E1_PIS,E1_IRRF,E1_INSS,E1_ISS,E1_MOEDA,E1_CLIENTE,E1_LOJA,E1_BASECSL,E1_BASECOF,E1_BASEPIS
					FROM %Table:SE1% SE1
					WHERE
					SE1.E1_FILIAL = %xFilial:SE1% AND
					SE1.E1_PREFIXO = %Exp:SF2->F2_PREFIXO% AND 
					SE1.E1_NUM = %Exp:SF2->F2_DUPL% AND 
					((SE1.E1_TIPO = %Exp:MVNOTAFIS%) OR
					SE1.E1_TIPO IN (%Exp:cTipoPcc%) OR
					(SE1.E1_ORIGEM = 'LOJA701' AND SE1.E1_TIPO IN (%Exp:cWhere%))) AND
					SE1.%NotDel%
					ORDER BY %Order:SE1%
				EndSql

				#ELSE
				DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)
				#ENDIF
				While !Eof() .And. xFilial("SE1") == (cAliasSE1)->E1_FILIAL .And.;
				SF2->F2_PREFIXO == (cAliasSE1)->E1_PREFIXO .And.;
				SF2->F2_DOC == (cAliasSE1)->E1_NUM
					If 	(cAliasSE1)->E1_TIPO = MVNOTAFIS .OR. ((cAliasSE1)->E1_ORIGEM = 'LOJA701' .AND. (cAliasSE1)->E1_TIPO $ cWhere)

						//aadd(aDupl,{/*Neogrid n�o processa alfanumerico*/ "000"+Alltrim((cAliasSE1)->E1_NUM)+Alltrim((cAliasSE1)->E1_PARCELA),(cAliasSE1)->E1_VENCORI,(cAliasSE1)->E1_VALOR,(cAliasSE1)->E1_PARCELA})
						If GetMv("MV_TPABISS") == "2" .AND. SF2->F2_RECISS == "1"//1-ABATE VALOR LIQ / 2-GERA TITULO ISS
							nValFatura := (cAliasSE1)->(E1_VALOR-(E1_COFINS+E1_PIS+E1_CSLL+E1_IRRF+E1_INSS+E1_ISS))
							aadd(aDupl,{/*Neogrid n�o processa alfanumerico*/ "000"+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_VENCORI,nValFatura,(cAliasSE1)->E1_PARCELA})
						Else
							nValFatura := (cAliasSE1)->(E1_VALOR - (E1_COFINS+E1_PIS+E1_CSLL+E1_IRRF+E1_INSS))
							aadd(aDupl,{/*Neogrid n�o processa alfanumerico*/ "000"+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_VENCORI,nValFatura,(cAliasSE1)->E1_PARCELA})
						EndIf
					EndIf
					//-- Tratamento para saber se existem titulos de reten��o de PIS,COFINS e CSLL
					If lNfsePcc
						If Alltrim((cAliasSE1)->E1_TIPO) $ "NF"
							nRetCsl += (cAliasSE1)->E1_CSLL 
							nRetCof += (cAliasSE1)->E1_COFINS
							nRetPis += (cAliasSE1)->E1_PIS
						EndIf
					Else
						If 	(cAliasSE1)->E1_TIPO $ cTipoPcc
							If (cAliasSE1)->E1_TIPO $ "PIS,PI-"
								nRetPis	+= 	(cAliasSE1)->E1_VALOR
							ElseIf (cAliasSE1)->E1_TIPO $ "COF,CF-"
								nRetCof	+= 	(cAliasSE1)->E1_VALOR
							ElseIf (cAliasSE1)->E1_TIPO $ "CSL,CS-"
								nRetCsl	+= 	(cAliasSE1)->E1_VALOR
							EndIf
						EndIf
					EndIf
					If Alltrim((cAliasSE1)->E1_TIPO) $ "NF"
						nBasCsl := (cAliasSE1)->E1_BASECSL
						nBasCof := (cAliasSE1)->E1_BASECOF
						nBasPis := (cAliasSE1)->E1_BASEPIS			
					EndIf

					dbSelectArea(cAliasSE1)
					dbSkip()
				EndDo
				If lQuery
					dbSelectArea(cAliasSE1)
					dbCloseArea()
					dbSelectArea("SE1")
				EndIf
			Else
				aDupl := {}
			EndIf

			dbSelectArea("SF3")
			dbSetOrder(4)
			If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)

				//�������������������������������Ŀ
				//�Verifica se recolhe ISS Retido �
				//���������������������������������
				If SF3->(FieldPos("F3_RECISS"))>0
					If SF3->F3_RECISS $"1S"
						//������������������������������Ŀ
						//�Pega retencao de ISS por item �
						//��������������������������������
						SFT->(dbSetOrder(1))
						SFT->(dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))
						While !SFT->(EOF()) .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
							aAdd(aRetISS,SFT->FT_VALICM)
							SFT->(dbSkip())
						EndDo

						dbSelectArea("SD2")
						dbSetOrder(3)
						dbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)

						aadd(aRetido,{"ISS",0,SF3->F3_VALICM,SD2->D2_ALIQISS,val(SF3->F3_RECISS),aRetISS})
					Endif
				EndIf

				//�����������������Ŀ
				//�Pega as dedu��es �
				//�������������������
				If SF3->(FieldPos("F3_ISSSUB"))>0  .And. SF3->F3_ISSSUB > 0
					If len(aDeducao) > 0
						aDeducao [len(aDeducao)] := SF3->F3_ISSSUB  
					Else
						aadd(aDeducao,{SF3->F3_ISSSUB})
					EndIf
				EndIf

				If SF3->(FieldPos("F3_ISSMAT"))>0 .And. SF3->F3_ISSMAT > 0 
					If len(aDeducao) > 0
						for nW := 1 To len(aDeducao)
							aDeducao[nW][1] += SF3->F3_ISSMAT
							exit
						next nW
					Else
						aadd(aDeducao,{SF3->F3_ISSMAT})
					EndIf
				EndIf
			EndIf

			//������������������������������������������������������������������������Ŀ
			//�Analisa os impostos de retencao                                         �
			//��������������������������������������������������������������������������

			aadd(aRetido,{"PIS",nBasPis,nRetPis,SED->ED_PERCPIS,aRetPIS})

			aadd(aRetido,{"COFINS",nBasCof,nRetCof,SED->ED_PERCCOF,aRetCOF})

			aadd(aRetido,{"CSLL",nBasCsl,nRetCsl,SED->ED_PERCCSL,aRetCSL})

			If SF2->(FieldPos("F2_VALIRRF"))<>0 .and. SF2->F2_VALIRRF>0
				aadd(aRetido,{"IRRF",SF2->F2_BASEIRR,SF2->F2_VALIRRF,SED->ED_PERCIRF,aRetIRR})
			EndIf
			If SF2->(FieldPos("F2_BASEINS"))<>0 .and. SF2->F2_BASEINS>0
				aadd(aRetido,{"INSS",SF2->F2_BASEINS,SF2->F2_VALINSS,SED->ED_PERCINS,aRetINS})
			EndIf

			//Verifica tipo do cliente.
			cTpCliente := Alltrim(SF2->F2_TIPOCLI)

			//������������������������������������������������������������������������Ŀ
			//�Pesquisa itens de nota                                                  �
			//��������������������������������������������������������������������������
			//////INCLUSAO DE CAMPOS NA QUERY////////////

			cField := "%"

			If SD2->(FieldPos("D2_TOTIMP"))<>0
				cField  +=",D2_TOTIMP"
			EndIf

			If SD2->(FieldPos("D2_DESCICM"))<>0
				cField  +=",D2_DESCICM"
			EndIf

			cField += "%"


			dbSelectArea("SD2")
			dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM	
			#IFDEF TOP
			lQuery  := .T.
			cAliasSD2 := GetNextAlias()
			BeginSql Alias cAliasSD2
				SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
				D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
				D2_CLASFIS,D2_PRCVEN,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_BASEISS,D2_VALIMP1,D2_VALIMP2,D2_VALIMP3,D2_VALIMP4,D2_VALIMP5,D2_PROJPMS %Exp:cField%,
				D2_VALPIS,D2_VALCOF,D2_VALCSL,D2_VALIRRF,D2_VALINS,D2_ORIGLAN,D2_VALICM						
				FROM %Table:SD2% SD2
				WHERE
				SD2.D2_FILIAL = %xFilial:SD2% AND
				SD2.D2_SERIE = %Exp:SF2->F2_SERIE% AND 
				SD2.D2_DOC = %Exp:SF2->F2_DOC% AND 
				SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND 
				SD2.D2_LOJA = %Exp:SF2->F2_LOJA% AND 
				SD2.%NotDel%
				ORDER BY %Order:SD2%
			EndSql

			#ELSE
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			#ENDIF

			//������������������������������������������������������������������������Ŀ
			//�Posiciona na Constru��o Cilvil                                          �
			//��������������������������������������������������������������������������
			If !Empty((cAliasSD2)->D2_PROJPMS)
				dbSelectArea("AF8")
				dbSetOrder(1)
				DbSeek(xFilial("AF8")+((cAliasSD2)->D2_PROJPMS))
				If !Empty(AF8->AF8_ART)
					aadd(aConstr,(AF8->AF8_PROJET))
					aadd(aConstr,(AF8->AF8_ART))
					aadd(aConstr,(AF8->AF8_TPPRJ))
				EndIf

			Else
				dbSelectArea("SC5")
				SC5->( dbSetOrder(1) ) //C5_FILIAL+C5_NUM
				If SC5->( MsSeek( xFilial("SC5") + (cAliasSD2)->D2_PEDIDO) )
					If ( SC5->(FieldPos("C5_OBRA")) > 0 .And. !Empty(SC5->C5_OBRA) ) .And. SC5->(FieldPos("C5_ARTOBRA")) > 0
						aadd(aConstr,(SC5->C5_OBRA)) //-- Codigo da Obra
						aadd(aConstr,(SC5->C5_ARTOBRA))
					EndIf
					If SC5->(FieldPos("C5_TIPOBRA")) > 0 .And. !Empty(SC5->C5_TIPOBRA)
						If Len(aConstr) == 0
							aadd(aConstr,"")
							aadd(aConstr,"")
						EndIf
						aadd(aConstr,(SC5->C5_TIPOBRA))
					EndIf
					// Dados do intermedi�rio de servi�o
					If SC5->(FieldPos("C5_CLIINT")) > 0 .And. SC5->(FieldPos("C5_CGCINT")) > 0 .And. SC5->(FieldPos("C5_IMINT")) > 0;
					.And. !Empty(SC5->C5_CLIINT) .And. !Empty(SC5->C5_CGCINT) .And. !Empty(SC5->C5_IMINT)

						aadd(aInterm,(SC5->C5_CLIINT))
						aadd(aInterm,(SC5->C5_CGCINT))
						aadd(aInterm,(SC5->C5_IMINT))

					EndIf
				EndIf
			EndIf

			If Len(aConstr) < 3
				For nX := 1 To 3
					If Len(aConstr) < 3 
						aadd(aConstr,"")							
					EndIf
				Next nX
			EndIf	
			If ValType(aObra) <> "U" .And. len (aObra) >= 15
				cLogradOb  := AllTrim(If(!Empty(aObra[01]) .And. SC5->(FieldPos(aObra[01])) > 0 , &(aObra[01]),"")) //Logradouro para Obra
				cCompleOb  := AllTrim(If(!Empty(aObra[02]) .And. SC5->(FieldPos(aObra[02])) > 0 , &(aObra[02]),"")) //Complemento para obra
				cNumeroOb  := AllTrim(If(!Empty(aObra[03]) .And. SC5->(FieldPos(aObra[03])) > 0 , &(aObra[03]),"")) // Numero para Obra
				cBairroOb  := AllTrim(If(!Empty(aObra[04]) .And. SC5->(FieldPos(aObra[04])) > 0 , &(aObra[04]),"")) // Bairro para Obra
				cCepOb     := AllTrim(If(!Empty(aObra[05]) .And. SC5->(FieldPos(aObra[05])) > 0 , &(aObra[05]),"")) // Cep para Obra
				cCodMunob  := AllTrim(If(!Empty(aObra[06]) .And. SC5->(FieldPos(aObra[06])) > 0 , &(aObra[06]),"")) // Cod do Municipio para Obra
				cNomMunOb  := AllTrim(If(!Empty(aObra[07]) .And. SC5->(FieldPos(aObra[07])) > 0 , &(aObra[07]),"")) // Nome do municipio para Obra
				cUfOb 	   := AllTrim(If(!Empty(aObra[08]) .And. SC5->(FieldPos(aObra[08])) > 0 , &(aObra[08]),"")) // UF para Obra
				cCodPaisOb := AllTrim(If(!Empty(aObra[09]) .And. SC5->(FieldPos(aObra[09])) > 0 , &(aObra[09]),"")) // Codigo do Pais para Obra
				cNomPaisOb := AllTrim(If(!Empty(aObra[10]) .And. SC5->(FieldPos(aObra[10])) > 0 , &(aObra[10]),"")) // Nome do Pais para Obra
				cNumArtOb  := AllTrim(If(!Empty(aObra[11]) .And. SC5->(FieldPos(aObra[11])) > 0 , &(aObra[11]),"")) // Numero Art para Obra
				cNumCeiOb  := AllTrim(If(!Empty(aObra[12]) .And. SC5->(FieldPos(aObra[12])) > 0 , &(aObra[12]),"")) // Numero CEI para Obra
				cNumProOb  := AllTrim(If(!Empty(aObra[13]) .And. SC5->(FieldPos(aObra[13])) > 0 , &(aObra[13]),"")) // Numero Projeto para Obra
				cNumMatOb  := AllTrim(If(!Empty(aObra[14]) .And. SC5->(FieldPos(aObra[14])) > 0 , &(aObra[14]),"")) // Numero de Mtricula para Obra
				cNumEncap  := AllTrim(If(!Empty(aObra[15]) .And. SC5->(FieldPos(aObra[15])) > 0 , &(aObra[15]),"")) // NumeroEncapsulamento

				If(!Empty(cLogradOb),aadd(aConstr,(cLogradOb)),aadd(aConstr,"") ) //Logradouro para Obra
				If(!Empty(cCompleOb),aadd(aConstr,(cCompleOb)),aadd(aConstr,"") ) //Complemento para obra
				If(!Empty(cNumeroOb),aadd(aConstr,(cNumeroOb)),aadd(aConstr,"") ) // Numero para Obra
				If(!Empty(cBairroOb),aadd(aConstr,(cBairroOb)),aadd(aConstr,"") ) // Bairro para Obra
				If(!Empty(cCepOb),aadd(aConstr,(cCepOb)),aadd(aConstr,"") ) // Cep para Obra
				If(!Empty(cCodMunob),aadd(aConstr,(cCodMunob)),aadd(aConstr,"") ) // Cod do Municipio para Obra
				If(!Empty(cNomMunOb),aadd(aConstr,(cNomMunOb)),aadd(aConstr,"") ) // Nome do municipio para Obra
				If(!Empty(cUfOb),aadd(aConstr,(cUfOb)),aadd(aConstr,"") ) // UF para Obra
				If(!Empty(cCodPaisOb),aadd(aConstr,(cCodPaisOb)),aadd(aConstr,"") ) // Codigo do Pais para Obra
				If(!Empty(cNomPaisOb),aadd(aConstr,(cNomPaisOb)),aadd(aConstr,"") ) // Nome do Pais para Obra
				If(!Empty(cNumArtOb),aadd(aConstr,(cNumArtOb)),aadd(aConstr,"") ) // Numero Art para Obra
				If(!Empty(cNumCeiOb),aadd(aConstr,(cNumCeiOb)),aadd(aConstr,"") ) // Numero CEI para Obra
				If(!Empty(cNumProOb),aadd(aConstr,(cNumProOb)),aadd(aConstr,"") ) // Numero Projeto para Obra
				If(!Empty(cNumMatOb),aadd(aConstr,(cNumMatOb)),aadd(aConstr,"") ) // Numero de Mtricula para Obra
				If(!Empty(cNumEncap),aadd(aConstr,(cNumEncap)),aadd(aConstr,"") ) // NumeroEncapsulamento

			Else
				if IsBlind()
					conout ("Configure o Parametro MV_XMLOBRA {,,,,,,,,,,,,,,}  15 posicoes")
				Else
					MsgAlert("Configure o Par�metro MV_XMLOBRA {,,,,,,,,,,,,,,} 15 posi��es","NFS-e")
				Endif
			EndIf
			While !(cAliasSD2)->(Eof()) .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
			SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
			SF2->F2_DOC == (cAliasSD2)->D2_DOC

				SF4->(dbSeek(xFilial('SF4')+(cAliasSD2)->D2_TES))

				nCont++

				//������������������������������������������������������������������������Ŀ
				//�Verifica a natureza da operacao                                         �
				//��������������������������������������������������������������������������
				dbSelectArea("SC5")
				dbSetOrder(1) //C5_FILIAL+C5_NUM
				If DbSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO)
					lSC5 := .T.
				Else
					lSC5 := .F.
				EndIf

				//������������������������Ŀ
				//�Pega retencoes por item �
				//��������������������������
				aAdd(aRetPIS,Iif(nRetPis > 0, (cAliasSD2)->D2_VALPIS, 0))
				nScan := aScan(aRetido,{|x| x[1] == "PIS"})
				If nScan > 0
					aRetido[nScan][5] := aRetPIS
				EndIf

				aAdd(aRetCOF,Iif(nRetCof > 0, (cAliasSD2)->D2_VALCOF, 0))
				nScan := aScan(aRetido,{|x| x[1] == "COFINS"})
				If nScan > 0
					aRetido[nScan][5] := aRetCOF
				EndIf

				aAdd(aRetCSL,Iif(nRetCsl > 0, (cAliasSD2)->D2_VALCSL, 0))
				nScan := aScan(aRetido,{|x| x[1] == "CSLL"})
				If nScan > 0
					aRetido[nScan][5] := aRetCSL
				EndIf

				aAdd(aRetIRR,Iif(SF2->(FieldPos("F2_VALIRRF")) <> 0 .and. SF2->F2_VALIRRF > 0, (cAliasSD2)->D2_VALIRRF, 0))
				nScan := aScan(aRetido,{|x| x[1] == "IRRF"})
				If nScan > 0
					aRetido[nScan][5] := aRetIRR
				EndIf

				aAdd(aRetINS,Iif(SF2->(FieldPos("F2_BASEINS")) <> 0 .and. SF2->F2_BASEINS > 0, (cAliasSD2)->D2_VALINS, 0))
				nScan := aScan(aRetido,{|x| x[1] == "INSS"})
				If nScan > 0
					aRetido[nScan][5] := aRetINS
				EndIf

				//TRATAMENTO - INTEGRACAO COM TMS-GESTAO DE TRANSPORTES
				If IntTms()
					DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					If DT6->(DbSeek(xFilial("DT6")+SF2->(F2_FILIAL+F2_DOC+F2_SERIE)))
						cModFrete := DT6->DT6_TIPFRE

						SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
						If SA1->(DbSeek(xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES)))
							cMunPSIAFI := SA1->A1_CODSIAFI
						EndIf

						If DUY->(FieldPos("DUY_CODMUN")) > 0
							DUY->(DbSetOrder(1))
							If DUY->(DbSeek(xFilial("DUY")+DT6->DT6_CDRDES))
								nPosUF:=aScan(aUF,{|X| X[1] == DUY->DUY_EST})
								If nPosUF > 0 
									cMunPrest:=aUF[nPosUF][2]+AllTrim(DUY->DUY_CODMUN)
								Else
									cMunPrest:=DUY->DUY_CODMUN
								EndIf
							EndIf
						Else
							SA1->(DbSetOrder(1))
							If SA1->(DbSeek(xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES)))
								cMunPrest := SA1->A1_COD_MUN
							EndIf
						EndIf
					Else
						If lSC5 .And. SC5->(FieldPos("C5_MUNPRES")) > 0 .And. !Empty(SC5->C5_MUNPRES)
							//Quando for preenchido os campos C5_ESTPRES e C5_MUNPRES concatena as informacoes
							If ( len(Alltrim(SC5->C5_MUNPRES)) == 5 .AND. !empty(SC5->C5_ESTPRES) )

								For nZ := 1 to len(aUf)
									If Alltrim(SC5->C5_ESTPRES) == aUf[nZ][1]
										cMunPrest := Alltrim(aUf[nZ][2] + Alltrim(SC5->C5_MUNPRES))
										exit
									EndIf
								Next
							Else
								cMunPrest := SC5->C5_MUNPRES
							EndIf

							cDescMunP := SC5->C5_DESCMUN

						Else
							cMunPrest := aDest[07]
							cDescMunP := aDest[08]
						EndIf
					EndIf
				Else
					If lSC5 .And. SC5->(FieldPos("C5_MUNPRES")) > 0 .And. !Empty(SC5->C5_MUNPRES)
						//Quando for preenchido os campos C5_ESTPRES e C5_MUNPRES concatena as informacoes
						If ( len(Alltrim(SC5->C5_MUNPRES)) == 5 .AND. !empty(SC5->C5_ESTPRES) )

							For nZ := 1 to len(aUf)
								If Alltrim(SC5->C5_ESTPRES) == aUf[nZ][1]
									cMunPrest := Alltrim(aUf[nZ][2] + Alltrim(SC5->C5_MUNPRES))
									exit
								EndIf
							Next
						Else
							cMunPrest := SC5->C5_MUNPRES
						EndIf

						cDescMunP := SC5->C5_DESCMUN

					Else
						cMunPrest := aDest[07]
						cDescMunP := aDest[08]
					EndIf
					// Tratamento para notas com data de Competencia
					If ! Empty(cCamSC5)
						If Fieldpos(cCamSC5)>0
							dDateCom := SC5->&(cCamSC5)
						Else
							dDateCom := CToD("")
						Endif
					Endif
				EndIf

				dbSelectArea("SF4")
				dbSetOrder(1) //F4_FILIAL+F4_CODIGO
				DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)

				cF4Agreg := SF4->F4_AGREG
				//If SF4->(FieldPos("F4_NATOP")) > 0
				//	cNatOP := AllTrim(SF4->F4_NATOP)
				//EndIf
				If SF4->(FieldPos("F4_NATOPNF")) > 0
					cNatOP := AllTrim(SF4->F4_NATOPNF)
				EndIf

				//Pega descricao do pedido de venda-Parametro MV_NFESERV
				cFieldMsg := GetNewPar("MV_CMPUSR","")
				If !lNFeDesc
					If lNatOper .And. lSC5 .And. nCont == 1 .and. !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
						cNatOper := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(&("SC5->"+cFieldMsg))),&("SC5->"+cFieldMsg))+" "
					ElseIf lNatOper .And. lSC5 .And. !Empty(SC5->C5_MENNOTA).And. nCont == 1
						cNatOper += If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)
						// cNatOper += "$$$"
					ElseIf SF2->(FieldPos("F2_MENNOTA")) <> 0 .and. !AllTrim(SF2->F2_MENNOTA) $ cMensCli .and. !Empty(AllTrim(SF2->F2_MENNOTA))
						cDiscrNFSe +=If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SF2->F2_MENNOTA)),AllTrim(SF2->F2_MENNOTA))
					EndIf
				Else
					If lSC5 .And. nCont == 1 .and. !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
						cDiscrNFSe := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(&("SC5->"+cFieldMsg))),&("SC5->"+cFieldMsg))+" "
					ElseIf lSC5 .And. !Empty(SC5->C5_MENNOTA).And. nCont == 1
						cDiscrNFSe := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)
						// cDiscrNFSe += "$$$"
					ElseIf !Empty(AllTrim(SF2->F2_MENNOTA)) .And. nCont == 1
						cDiscrNFSe +=If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SF2->F2_MENNOTA)),AllTrim(SF2->F2_MENNOTA))
					EndIf
				EndIf

				//-- Pega a descricao da SX5 tabela 60
				dbSelectArea("SB1")
				dbSetOrder(1) //B1_FILIAL+B1_COD
				DbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)

				dbSelectArea("SX5")
				dbSetOrder(1) //X5_FILIAL+X5_TABELA+X5_CHAVE
				If dbSeek(xFilial("SX5")+"60"+SB1->B1_CODISS)
					If !lNFeDesc
						If nCont == 1
							cNatOper   += If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SubStr(SX5->X5_DESCRI,1,55))),AllTrim(SubStr(SX5->X5_DESCRI,1,55)))
						EndIf
					ElseIf nCont == 1
						cDescrNFSe := If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SubStr(SX5->X5_DESCRI,1,55))),AllTrim(SubStr(SX5->X5_DESCRI,1,55)))
					EndIf
				EndIf

				If SF4->(FieldPos("F4_CFPS")) > 0
					cCFPS:=SF4->F4_CFPS
				EndIf
				//������������������������������������������������������������������������Ŀ
				//�Verifica as notas vinculadas                                            �
				//��������������������������������������������������������������������������
				If !Empty((cAliasSD2)->D2_NFORI) 
					If (cAliasSD2)->D2_TIPO $ "DBN"
						dbSelectArea("SD1")
						dbSetOrder(1)
						If DbSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
							dbSelectArea("SF1")
							dbSetOrder(1)
							DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
							If SD1->D1_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								DbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								DbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
							EndIf

							aadd(aNfVinc,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,IIF(SD1->D1_TIPO $ "DB",IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA1->A1_CGC),IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA2->A2_CGC)),SM0->M0_ESTCOB,SF1->F1_ESPECIE})
						EndIf
					Else
						aOldReg  := SD2->(GetArea())
						aOldReg2 := SF2->(GetArea())
						dbSelectArea("SD2")
						dbSetOrder(3)
						If DbSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
							dbSelectArea("SF2")
							dbSetOrder(1)
							DbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
							If !SD2->D2_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								DbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
							EndIf

							aadd(aNfVinc,{SF2->F2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,SM0->M0_CGC,SM0->M0_ESTCOB,SF2->F2_ESPECIE})
						EndIf
						RestArea(aOldReg)
						RestArea(aOldReg2)
					EndIf
				EndIf
				//������������������������������������������������������������������������Ŀ
				//�Obtem os dados do produto                                               �
				//��������������������������������������������������������������������������
				dbSelectArea("SB1")
				dbSetOrder(1) //B1_FILIAL+B1_COD
				DbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)

				dbSelectArea("SB5")
				dbSetOrder(1) //B5_FILIAL+B5_COD
				DbSeek(xFilial("SB5")+(cAliasSD2)->D2_COD)
				//-- Veiculos Novos
				If AliasIndic("CD9")
					dbSelectArea("CD9")
					dbSetOrder(1) //CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD
					DbSeek(xFilial("CD9")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM)
				EndIf
				//-- Medicamentos
				If AliasIndic("CD7")
					dbSelectArea("CD7")
					dbSetOrder(1) //CD7_FILIAL+CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA+CD7_ITEM+CD7_COD
					DbSeek(xFilial("CD7")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM)
				EndIf
				//-- Armas de Fogo
				If AliasIndic("CD8")
					dbSelectArea("CD8")
					dbSetOrder(1) //CD8_FILIAL+CD8_TPMOV+CD8_SERIE+CD8_DOC+CD8_CLIFOR+CD8_LOJA+CD8_ITEM+CD8_COD
					DbSeek(xFilial("CD8")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM)
				EndIf
				//-- Msg Zona Franca de Manaus / ALC
				dbSelectArea("SF3")
				dbSetOrder(4) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
				If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
					If !SF3->F3_DESCZFR == 0
						cMensFis := "Total do desconto Ref. a Zona Franca de Manaus / ALC. R$ "+str(SF3->F3_VALOBSE-SF2->F2_DESCONT,13,2)
					EndIf
				EndIf

				dbSelectArea("SC6")
				dbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				DbSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD)

				cFieldMsg := GetNewPar("MV_CMPUSR","")
				If !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
					//Permite ao cliente customizar o conteudo do campo dados adicionais por meio de um campo MEMO proprio.
					cMensCli := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(&("SC5->"+cFieldMsg))),&("SC5->"+cFieldMsg))+" "
				ElseIf !AllTrim(SC5->C5_MENNOTA) $ cMensCli
					cMensCli +=If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SC5->C5_MENNOTA)),AllTrim(SC5->C5_MENNOTA))
				EndIf
				If !Empty(SC5->C5_MENPAD) .And. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
					cMensFis += If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(FORMULA(SC5->C5_MENPAD))),AllTrim(FORMULA(SC5->C5_MENPAD)))
				EndIf

				cModFrete := IIF(SC5->C5_TPFRETE=="C","0","1")

				If Empty(aPedido)
					aPedido := {"",AllTrim(SC6->C6_PEDCLI),""}
				EndIf
				//�������������������������������Ŀ
				//�Verifica se recolhe ISS Retido �
				//���������������������������������
				If SF3->(FieldPos("F3_RECISS"))>0
					If SF3->F3_RECISS $"1S"
						//������������������������������Ŀ
						//�Pega retencao de ISS por item �
						//��������������������������������
						SFT->(dbSetOrder(1))
						If SFT->(dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+PadR((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD))
							aAdd(aRetISS,SFT->FT_VALICM)
						EndIf

						dbSelectArea("SD2")
						dbSetOrder(3)
						dbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)

						aadd(aRetido,{"ISS",0,SF3->F3_VALICM,SD2->D2_ALIQISS,val(SF3->F3_RECISS),aRetISS})
					Endif
				EndIf
				dbSelectArea("CD2")
				If !(cAliasSD2)->D2_TIPO $ "DB"
					dbSetOrder(1) //CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI+CD2_ITEM+CD2_CODPRO+CD2_IMP
				Else
					dbSetOrder(2)
				EndIf
				If !DbSeek(xFilial("CD2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+PadR((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD)

				EndIf
				aadd(aISSQN,{0,0,0,"","",0})
				While !Eof() .And. xFilial("CD2") == CD2->CD2_FILIAL .And.;
				"S" == CD2->CD2_TPMOV .And.;
				SF2->F2_SERIE == CD2->CD2_SERIE .And.;
				SF2->F2_DOC == CD2->CD2_DOC .And.;
				SF2->F2_CLIENTE == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_CODCLI,CD2->CD2_CODFOR) .And.;
				SF2->F2_LOJA == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_LOJCLI,CD2->CD2_LOJFOR) .And.;
				(cAliasSD2)->D2_ITEM == SubStr(CD2->CD2_ITEM,1,Len((cAliasSD2)->D2_ITEM)) .And.;
				(cAliasSD2)->D2_COD == CD2->CD2_CODPRO

					Do Case
						Case AllTrim(CD2->CD2_IMP) == "ICM"
						aTail(aICMS) := {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,CD2->CD2_PREDBC,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,0,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "SOL"
						aTail(aICMSST) := {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,CD2->CD2_PREDBC,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_MVA,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						lCalSol := .T.
						Case AllTrim(CD2->CD2_IMP) == "IPI"
						aTail(aIPI) := {"","",0,"999",CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_QTRIB,CD2->CD2_PAUTA,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_MODBC,CD2->CD2_PREDBC}
						Case AllTrim(CD2->CD2_IMP) == "PS2"
						If (cAliasSD2)->D2_VALISS==0
							aTail(aPIS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Else
							If Empty(aISS)
								aISS := {0,0,0,0,0}
							EndIf
							aISS[04]+= CD2->CD2_VLTRIB	
						EndIf
						Case AllTrim(CD2->CD2_IMP) == "CF2"
						If (cAliasSD2)->D2_VALISS==0
							aTail(aCOFINS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Else
							If Empty(aISS)
								aISS := {0,0,0,0,0}
							EndIf
							aISS[05] += CD2->CD2_VLTRIB	
						EndIf
						Case AllTrim(CD2->CD2_IMP) == "PS3" .And. (cAliasSD2)->D2_VALISS==0
						aTail(aPISST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "CF3" .And. (cAliasSD2)->D2_VALISS==0
						aTail(aCOFINSST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "ISS"
						If Empty(aISS)
							aISS := {0,0,0,0,0}
						EndIf
						aISS[01] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
						aISS[02] += CD2->CD2_BC
						aISS[03] += CD2->CD2_VLTRIB
						If !Empty(cMunPrest) .and. (Empty(aDest[01]) .and. Empty(aDest[02]) .and. Empty(aDest[07]) .and. Empty(aDest[09]))
							cMunISS := cMunPrest
						Else
							cMunISS := convType(aUF[aScan(aUF,{|x| x[1] == aDest[09]})][02]+aDest[07])
						EndIf
						If CD2->CD2_ALIQ > 0
							If lAglutina
								aISSQN[1][1] += CD2->CD2_BC
								aISSQN[1][3] += CD2->CD2_VLTRIB
								aISSQN[1][6] += (cAliasSD2)->D2_DESCON
							Else
								lAglutina := .F.
								aTail(aISSQN) := {CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,cMunISS,AllTrim((cAliasSD2)->D2_CODISS),(cAliasSD2)->D2_DESCON}
							EndIf
						Else
							aTail(aISSQN) := {CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,cMunISS,AllTrim((cAliasSD2)->D2_CODISS),(cAliasSD2)->D2_DESCON}
							nAliq := CD2->CD2_ALIQ
						EndIf
					EndCase
					dbSelectArea("CD2")
					dbSkip()
				EndDo
				If lAglutina
					If Len(aProd) > 0
						nX := aScan(aProd,{|x| x[24] == Alltrim((cAliasSD2)->D2_CODISS) .And. x[23] == IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,SB1->B1_TRIBMUN,"")})
						If nX > 0
							aProd[nx][13]+= (cAliasSD2)->D2_VALFRE // Valor Frete
							aProd[nx][14]+= (cAliasSD2)->D2_SEGURO // Valor Seguro
							aProd[nx][15]+= ((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR) // Valor Desconto
							aProd[nx][21]+= SF3->F3_ISSSUB
							aProd[nx][22]+= SF3->F3_ISSMAT
							aProd[nx][25]+= (cAliasSD2)->D2_BASEISS
							aProd[nx][26]+= (cAliasSD2)->D2_VALFRE
							aProd[nx][27]+=	 IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN,0) * (cAliasSD2)->D2_QUANT // Valor Liquido = I-Compl.ICMS;P-Compl.IPI
							aProd[nx][28]+= IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN,0) * (cAliasSD2)->D2_QUANT+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR) //Valor Total
							aProd[nx][35]+= IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTIMP"))<>0,(cAliasSD2)->D2_TOTIMP,0),0)
							//aProd[nx][29]+=	SF3->F3_ISSSUB + SF3->F3_ISSMAT	//Valor Total de deducoes       Comentado para n�o duplicar o valor na tag ValorDeducoes
						Else
							lAglutina := .F.
						EndIf
					EndIf
				EndIf
				If !lAglutina .Or. Len(aProd) == 0
					If SM0->M0_CODMUN == "4205407" //florianopolis
						nValTotPrd := IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(SM0->M0_CODMUN == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0)
					Else
						nValTotPrd := IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(SM0->M0_CODMUN == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0)+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)
					EndIf
					aadd(aProd,	{Len(aProd)+1,;
					(cAliasSD2)->D2_COD,;
					IIf(Val(SB1->B1_CODBAR)==0,"",Str(Val(SB1->B1_CODBAR),Len(SB1->B1_CODBAR),0)),;
					IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI),;
					SB1->B1_POSIPI,;
					SB1->B1_EX_NCM,;
					(cAliasSD2)->D2_CF,;
					SB1->B1_UM,;
					(cAliasSD2)->D2_QUANT,;
					IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN,0),;
					IIF(Empty(SB5->B5_UMDIPI),SB1->B1_UM,SB5->B5_UMDIPI),;
					IIF(Empty(SB5->B5_CONVDIPI),(cAliasSD2)->D2_QUANT,SB5->B5_CONVDIPI*(cAliasSD2)->D2_QUANT),;
					(cAliasSD2)->D2_VALFRE,;
					(cAliasSD2)->D2_SEGURO,;
					((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR),;
					IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN+(((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/(cAliasSD2)->D2_QUANT),0),;
					IIF(SB1->(FieldPos("B1_CODSIMP"))<>0,SB1->B1_CODSIMP,""),; // 17 - codigo ANP do combustivel
					IIF(SB1->(FieldPos("B1_CODIF"))<>0,SB1->B1_CODIF,""),; // 18 - CODIF
					RetFldProd(SB1->B1_COD,"B1_CNAE"),; //19 - Codigo da Atividade CNAE
					SF3->F3_RECISS,;
					SF3->F3_ISSSUB,;
					SF3->F3_ISSMAT,;
					IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,SB1->B1_TRIBMUN,""),;
					IIF( SC6->(FieldPos("C6_CODISS"))>0,AllTrim(SC6->C6_CODISS),AllTrim(SF3->F3_CODISS)),; //24 - Codigo Servico ISS
					(cAliasSD2)->D2_BASEISS,;
					(cAliasSD2)->D2_VALFRE,;
					IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(SM0->M0_CODMUN == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0),; // 27 - Valor Liquido
					IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(SM0->M0_CODMUN == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0)+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR),; //28 - Valor Total
					SF3->F3_ISSSUB + SF3->F3_ISSMAT,; // 29 - Valor Total de deducoes.
					(cAliasSD2)->D2_VALIMP4,; // 30
					(cAliasSD2)->D2_VALIMP5,; // 31
					RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),; // 32
					IIF(SF4->(FieldPos("F4_CFPS")) > 0,SF4->F4_CFPS,""),;// 33 - Codigo Fiscal de Prestacao de Servico (CFPS)
					IIF(SF4->(FieldPos(cMVBENEFRJ))> 0,SF4->(&(cMVBENEFRJ)),"" ),; // 34 - C�digo Beneficio Fiscal - NFS-e RJ
					IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTIMP"))<>0,(cAliasSD2)->D2_TOTIMP,0),0),; // 35 - Lei transpar�ncia
					IIF((cAliasSD2)->D2_BASEISS <> nValTotPrd, nValTotPrd - (cAliasSD2)->D2_BASEISS, (cAliasSD2)->D2_BASEISS),;	// 36 - Posicao para verifcar se existe reducao de ISS, ser� criado um campo na SFT para substituir esse calculo
					IIF( SB1->(FieldPos("B1_MEPLES"))<>0, SB1->B1_MEPLES, "" ),; //37 - campo para NFSe Sao Paulo, identifica se eh Dentro do municipio ou fora.
					IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTFED"))<>0,(cAliasSD2)->D2_TOTFED,0),0),; //38 - Lei transpar�ncia
					IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTEST"))<>0,(cAliasSD2)->D2_TOTEST,0),0),; //39 - Lei transpar�ncia
					IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTMUN"))<>0,(cAliasSD2)->D2_TOTMUN,0),0),;  //40 - Lei transpar�ncia
					IIF(SC6->(FieldPos("C6_DESCRI")) > 0,AllTrim(SC6->C6_DESCRI),"")	;	//41 - Descricao RPS SC6
					})
				EndIf

				If SC6->(FieldPos("C6_TPDEDUZ")) > 0 .And. !Empty(SC6->C6_TPDEDUZ)
					aadd(aDeduz,{	SC6->C6_TPDEDUZ,; //-- Tipo de Deducao = 1-Percentual;2-Valor
					SC6->C6_MOTDED ,;
					SC6->C6_FORDED ,;
					SC6->C6_LOJDED ,;
					SC6->C6_SERDED ,;
					SC6->C6_NFDED  ,;
					SC6->C6_VLNFD  ,;
					SC6->C6_PCDED  ,;
					if (SC6->C6_VLDED > 0, SC6->C6_VLDED, (SC6->C6_ABATISS + SC6->C6_ABATMAT)),;
					})
				EndIf

				aadd(aCST,{IIF(!Empty((cAliasSD2)->D2_CLASFIS),SubStr((cAliasSD2)->D2_CLASFIS,2,2),'50'),;
				IIF(!Empty((cAliasSD2)->D2_CLASFIS),SubStr((cAliasSD2)->D2_CLASFIS,1,1),'0')})
				aadd(aICMS,{})
				aadd(aIPI,{})
				aadd(aICMSST,{})
				aadd(aPIS,{})
				aadd(aPISST,{})
				aadd(aCOFINS,{})
				aadd(aCOFINSST,{})
				//aadd(aISSQN,{0,0,0,"","",0})
				aadd(aAdi,{})
				aadd(aDi,{})
				//������������������������������������������������������������������������Ŀ
				//�Tratamento para TAG Exporta��o quando existe a integra��o com a EEC     �
				//��������������������������������������������������������������������������
				If lEECFAT .And. !Empty((cAliasSD2)->D2_PREEMB)
					aadd(aExp,(GETNFEEXP((cAliasSD2)->D2_PREEMB)))
				Else
					aadd(aExp,{})
				EndIf
				If AliasIndic("CD7")
					aadd(aMed,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,CD7->CD7_PRECO})
				Else
					aadd(aMed,{})
				EndIf
				If AliasIndic("CD8")
					aadd(aArma,{CD8->CD8_TPARMA,CD8->CD8_NUMARMA,CD8->CD8_DESCR})
				Else
					aadd(aArma,{})
				EndIf
				If AliasIndic("CD9")
					aadd(aveicProd,{IIF(CD9->CD9_TPOPER$"03",1,IIF(CD9->CD9_TPOPER$"1",2,IIF(CD9->CD9_TPOPER$"2",3,IIF(CD9->CD9_TPOPER$"9",0,"")))),;
					CD9->CD9_CHASSI,CD9->CD9_CODCOR,CD9->CD9_DSCCOR,CD9->CD9_POTENC,CD9->CD9_CM3POT,CD9->CD9_PESOLI,;
					CD9->CD9_PESOBR,CD9->CD9_SERIAL,CD9->CD9_TPCOMB,CD9->CD9_NMOTOR,CD9->CD9_CMKG,CD9->CD9_DISTEI,CD9->CD9_RENAVA,;
					CD9->CD9_ANOMOD,CD9->CD9_ANOFAB,CD9->CD9_TPPINT,CD9->CD9_TPVEIC,CD9->CD9_ESPVEI,CD9->CD9_CONVIN,CD9->CD9_CONVEI,;
					CD9->CD9_CODMOD})
				Else
					aadd(aveicProd,{})
				EndIf

				//���������������������������������Ŀ
				//�Totaliza todas retencoes por item�
				//�����������������������������������
				nRetDesc :=	Iif(nRetPis > 0, (cAliasSD2)->D2_VALPIS, 0) + Iif(nRetCof > 0, (cAliasSD2)->D2_VALCOF, 0) + ;
				Iif(nRetCsl > 0, (cAliasSD2)->D2_VALCSL, 0) + Iif(SF2->(FieldPos("F2_VALIRRF")) <> 0 .and. SF2->F2_VALIRRF > 0, (cAliasSD2)->D2_VALIRRF, 0) + ;
				Iif(SF2->(FieldPos("F2_BASEINS")) <> 0 .and. SF2->F2_BASEINS > 0, (cAliasSD2)->D2_VALINS, 0) + Iif(Len(aRetISS) >= nCont, aRetISS[nCont], 0)

				aTotal[01] += (cAliasSD2)->D2_DESPESA
				aTotal[02] += ((cAliasSD2)->D2_TOTAL - nRetDesc)
				aTotal[03] := SF4->F4_ISSST	
				aTotal[04] += (cAliasSD2)->D2_TOTAL
				aTotal[05] := IIF(SF4->(ColumnPos('F4_TRIBPRD')),Alltrim(SF4->F4_TRIBPRD),'')
				If lCalSol
					dbSelectArea("SF3")
					dbSetOrder(4)
					If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
						nPosI	:=	At (SF3->F3_ESTADO, cMVSUBTRIB)+2
						nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
						nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
						aAdd (aIEST, SubStr (cMVSUBTRIB, nPosI, nPosF))	//01 - IE_ST
					EndIf
				EndIf
				IF Empty(aPis[Len(aPis)]) .And. SF4->F4_CSTPIS=="06"
					aadd(aPisAlqZ,{SF4->F4_CSTPIS})
				Else
					aadd(aPisAlqZ,{})
				EndIf
				IF Empty(aCOFINS[Len(aCOFINS)]) .And. SF4->F4_CSTCOF=="06"
					aadd(aCofAlqZ,{SF4->F4_CSTCOF})
				Else
					aadd(aCofAlqZ,{})
				EndIf

				//Tratamento para Calcular o Desconto para  Belo Horizonte
				nDescon += (cAliasSD2)->D2_DESCICM

				dbSelectArea(cAliasSD2)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSD2)
				dbCloseArea()
				dbSelectArea("SD2")
			EndIf

		EndIf
		IF ExistBlock("PE02NFSEUNI")		
			aParam := {aProd,cMensCli,cMensFis,aDest,aNota,nil,aDupl,aTransp,aEntrega,nil,aVeiculo,aReboque,cDiscrNFSe,cNatOper}

			aParam := ExecBlock("PE02NFSEUNI",.F.,.F.,aParam)

			If ( Len(aParam) >= 5 )
				aProd		:= aParam[1]
				cMensCli	:= aParam[2]
				cMensFis	:= aParam[3]
				aDest 		:= aParam[4]
				aNota 		:= aParam[5]
				//aInfoItem	:= aParam[6]
				aDupl		:= aParam[7]
				aTransp		:= aParam[8]
				aEntrega	:= aParam[9]
				//aRetirada	:= aParam[10]
				aVeiculo	:= aParam[11]
				aReboque	:= aParam[12]
				cDiscrNFSe  := aParam[13]
				cNatOper    := aParam[14]
			EndIf
		Endif
		//������������������������������������������������������������������������Ŀ
		//�Geracao do arquivo XML                                                  �
		//��������������������������������������������������������������������������
		If !Empty(aNota)
		
			
			nLote := GetMV("KP_LOTE",,1)
			PutMV("KP_LOTE",nLote+1)
			
			
			cString := '<LoteRps Id="Lote' + allTrim( Str( nLote ) ) + '"><NumeroLote>' + allTrim( Str( nLote ) ) + '</NumeroLote><Cnpj>'+alltrim(SM0->M0_CGC)+'</Cnpj><InscricaoMunicipal>'
			cString += iif( Empty( allTrim( SM0->M0_INSCM )),"ISENTO",allTrim( SM0->M0_INSCM ))+'</InscricaoMunicipal><QuantidadeRps>1</QuantidadeRps><ListaRps><Rps>'

			cString += ident( aNota, aProd, aTotal, aDest, aISSQN, aAIDF, dDateCom, cNatOp )
			cString += servicos( aProd, aISSQN, aRetido, cNatOper, lNFeDesc, cDiscrNFSe, aCST, aDest[22], SM0->M0_CODMUN, cF4Agreg ,nDescon, aDest, cNota, cSerie )
			cString += prest( cMunPSIAFI )			
			cString += tomador( aDest )
			cString += intermediario( aInterm )			
			cString += pagtos( aDupl )
			cString += construcao(aConstr)

			cString += '</InfRps></Rps></ListaRps></LoteRps>'
			
			cString := encodeUTF8( cString )			
			
			cIdent := GetIdEnt()
			if cIdent == ""
				cIdent := "000001"
			EndIf

			cString	:=SignNFSeA1(cCodMun,EncodeUtf8(cString),"InfRps","","000001", "", "001",Encode64(GetMV("KP_SENHA",,"ODAwNTE4MjQ=")), allTrim( aNota[1] )  + allTrim( Str( Val( aNota[02] ) ) ) ) //alterar
			cString:= cabecSoap("EnviarLoteRpsEnvio",cString)
			
			oXML := nil
			
			U_BETHAENV("recepcionarLoteRps?wsdl","EnviarLoteRpsEnvio",EncodeUtf8(cString),@oXML)
			
			if valtype(xGetInfo(oXML,"_DATARECEBIMENTO:TEXT")) == "C"
			
				DbSelectArea("ZP6")
				ZP6->(DbSetOrder(1))
				ZP6->(DbGoTop())	
				_lZP6 := ZP6->(DbSeek(xFilial("ZP6")+allTrim( aNota[1] )  + allTrim(   aNota[02]  ) ))
			
					Reclock("ZP6",!_lZP6)
					ZP6->ZP6_FILIAL 	:= xFilial("ZP6") 
					ZP6->ZP6_ID     	:= allTrim( aNota[1] )  + allTrim(   aNota[02]  )  
					ZP6->ZP6_RECEBI 	:= STOD(StrTran(substr(oXML:_DATARECEBIMENTO:TEXT,1,10),'-',''))
					ZP6->ZP6_HORA   	:= substr(oXML:_DATARECEBIMENTO:TEXT,12,8)
					ZP6->ZP6_LOTE   	:= val(cValToChar(oXML:_NUMEROLOTE:TEXT))
					ZP6->ZP6_PROTOC 	:= cValToChar(oXML:_PROTOCOLO:TEXT)
					ZP6->ZP6_CLIENT		:= SF2->F2_CLIENTE
					ZP6->ZP6_LOJA		:= SF2->F2_LOJA
					ZP6->ZP6_VALBRU		:= SF2->F2_VALBRUT
					ZP6->ZP6_EMISSA		:= SF2->F2_EMISSAO
					ZP6->ZP6_IDNFMI		:= SF2->F2_XIDVNFK
					
					// valida se o campo existe
					IF ZP6->( FieldPos("ZP6_USRCO") ) > 0
						ZP6->ZP6_USRCO  := RetCodUsr()
					EndIf
					
					MsUnlock()
				Else 
					Conout("")
					Conout("----sem retorno da betha-----")
					Conout("")
			EndIf
		EndIf
	ElseIf cTipo == "1" .And. !Empty(cMotCancela)
	
			nLote := GetMV("KP_LOTE",,1)
			PutMV("KP_LOTE",nLote+1)
				
		cString := u_nfseXMLCan(cNota,cSerie,cMotCancela,nLote)
		
			cIdent := GetIdEnt()
			if cIdent == ""
				cIdent := "000001"
			EndIf		
	
		cString	:=SignNFSeA1(cCodMun,EncodeUtf8(cString),"InfPedidoCancelamento","","000001", "", "001",Encode64(GetMV("KP_SENHA",,"ODAwNTE4MjQ=")),  'Cancelamento_'+allTrim( Str( nLote ) ) ) //alterar
		cString:= cabecSoap("CancelarNfseEnvio",cString)			
		
		oXML := ""
	
		U_BETHAENV("cancelarNfse?wsdl","CancelarNfseEnvio",cString,@oXml)
		
		
		
		If valtype(xGetInfo(oXML,"_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_MENSAGEM:TEXT")) <> "U"
			cMensagem:= ""
			If valtype(xGetInfo(oXML,"_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_CODIGO:TEXT")) <> "U"
				cMensagem+= oXML:_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_CODIGO:TEXT + " "
			EndIf
			cMensagem+= oXML:_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_MENSAGEM:TEXT
			If IsBlind()
				conout(cMensagem)
			else
				Msginfo(cMensagem)
			endIf
		EndIf
		
		If valtype(xGetInfo(oXML,"_CANCELAMENTO:_CONFIRMACAO:_INFCONFIRMACAOCANCELAMENTO:_SUCESSO:TEXT")) <> "U"
			If oXML:_CANCELAMENTO:_CONFIRMACAO:_INFCONFIRMACAOCANCELAMENTO:_SUCESSO:TEXT == "true"
			
				cQuery := " select top 1 R_E_C_N_O_ ZP6RECNO from "+RetSQLName("ZP6")+ " where D_E_L_E_T_ <> '*' and ZP6_FILIAL = '"+xFilial("ZP6")+"' and ZP6_ID = '"+cSerie+cNota+"' and ZP6_NOTA <> '' and ZP6_ERRO = '' order by R_E_C_N_O_ desc "
	
				TcQuery cQuery new alias "QZP6"
				
				_nRecZP6 := QZP6->ZP6RECNO
				
				QZP6->(DbCloseArea())
				
				DbSelectArea("ZP6")
				ZP6->(DbGoTo(_nRecZP6))
				
				If ZP6->ZP6_ID = cSerie+cNota
				
				Reclock("ZP6",.F.)
					ZP6->ZP6_CANC := "S"
					MsUnlock()
				EndIF
				
			EndIf
		EndIf
			
	EndIf
	
return { cString, cNota }

//-----------------------------------------------------------------------
/*/{Protheus.doc} assina
Fun��o para montar a tag de assinatura do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 07.02.2012

@param	aDeduz	Array contendo as informa��es de dedu��es.
@param	aNota	Array contendo as informa��es de identifica��o sobre a nota.
@param	aProd	Array contendo as informa��es dos produtos.
@param	aTotal	Array contendo os valores totais do documento.
@param	aDest	Array contendo as informa��es de destinat�rio.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function assina( aDeduz, aNota, aProd, aTotal, aDest )
	Local cAssinatura	:= ""
	Local cMVCODREG		:= GetMV( "MV_OPTSIMP" ,.T., "3" ) //-- Codigo regime tributario emitente da Nf-e = 1-Simples Nacional; 2-Simples Nacional - Excesso desub-limite de receita bruta; 3- Regime Nacional
	Local nDeduz		:= 0
	Local nX			:= 0

	For nX := 1 To Len( aDeduz )
		nDeduz += iif( aDeduz[nX][1] == "2", aDeduz[nX][8], 0 )
	Next

	cAssinatura	+= strZero( val( SM0->M0_INSCM ), 11 )
	cAssinatura	+= "NF   "
	cAssinatura	+= strZero( val( aNota[02] ), 12 )
	cAssinatura	+= dToS( aNota[03] )
	do case
		case aTotal[3] $ "2"
		if !empty( cMVCODREG ) .and. ( cMVCODREG == "2" .or. cMVCODREG == "1" )
			cAssinatura += "H "
		else
			cAssinatura += "E "
		endif
		case aTotal[3] $ "3"
		cAssinatura += "C "
		case aTotal[3] $ "4"
		cAssinatura += "F "
		case aTotal[3] $ "5"
		cAssinatura += "K "
		case aTotal[3] $ "6"
		cAssinatura += "K "
		case aTotal[3] $ "7"
		cAssinatura += "N "
		case aTotal[3] $ "8"
		cAssinatura += "M "
		otherwise
		if !empty( cMVCODREG ) .and. ( cMVCODREG == "2" .or. cMVCODREG == "1" )
			cAssinatura += "H "
		else
			cAssinatura += "T "
		endif
	endcase
	cAssinatura += "N"
	cAssinatura += iif( ( aProd[1][20] ) == '1', "S", "N" )
	cAssinatura += strZero( ( aTotal[2] - nDeduz ) * 100, 15 )
	cAssinatura += strZero( nDeduz * 100, 15 )
	cAssinatura += allTrim( strZero( val( aProd[1][19] ), 10 ) )
	cAssinatura += allTrim( strZero( val( aDest[1] ), 14 ) )
	cAssinatura := allTrim( Lower( sha1( allTrim( cAssinatura ), 2 ) ) )
	cAssinatura := '<assinatura>' + cAssinatura + '</assinatura>'

Return cAssinatura

//-----------------------------------------------------------------------
/*/{Protheus.doc} ident
Fun��o para montar a tag de identifica��o do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aNota	Array com informa��es sobre a nota.
@param	aProd	Array com informa��es sobre os servi�os da nota.
@param	aTotal	Array com informa��es sobre os totais da nota.
@param	aDest	Array com informa��es sobre o tomador da nota.
@param	aAIDF	Array com informa��es sobre o AIDF.
@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function ident( aNota, aProd, aTotal, aDest, aISSQN, aAIDF, dDateCom, cNatOp )
	Local cMVCODREG		:= GetMV( "MV_OPTSIMP" ,.T., "3" ) //-- Codigo regime tributario emitente da Nf-e = 1-Simples Nacional; 2-Simples Nacional - Excesso desub-limite de receita bruta; 3- Regime Nacional
	Local cMVREGIESP	:= getMV( "MV_REGIESP",, "" ) //-- Informar o Regime especial de tributacao para que seja gerada a TAG <RegimeEspecialTributacao>
	Local cMVINCEFIS	:= AllTrim(GetNewPar("MV_INCEFIS","2"))
	Local cString		:= ""
	Local cMVOPTSIMP	:= allTrim( GetMV( "MV_OPTSIMP",, "2" ) ) //-- Contribuinte optante do simples: 1=sim;2=nao
	Local cMVINCECUL	:= allTrim( GetMV( "MV_INCECUL",, "2" ) ) //-- Contribuinte optante do incentivo a cultura: 1=sim;2=nao
	Local cMVOPTSIMP	:= allTrim( GetMV( "MV_OPTSIMP",, "2" ) ) //-- Contribuinte optante do simples: 1=sim;2=nao

	cString	:= '<InfRps Id="'+allTrim( aNota[1] )+ allTrim( str( val( aNota[2] ) ) )  +'"><IdentificacaoRps>'

	//-- Serie e numero RPS
	If UsaAidfRps(SM0->M0_CODMUN)
		cString += "<Numero>" + allTrim( aAIDF[3] ) + "</Numero>"	
		cString += "<Serie>"  + allTrim( aAIDF[2] ) + "</Serie>"

	Else
		cString += "<Numero>" + allTrim( str( val( aNota[2] ) ) ) + "</Numero>"	
		cString += "<Serie>"  + allTrim( aNota[1] ) + "</Serie>"

	EndIf	

	//-- Tipo do documento
	cString += "<Tipo>1</Tipo>" //-- Fixo pois tanto ABRASF como DSFNET, utilizam esta tag como tipo RPS (1) - Obrigat.
	cString	+= "</IdentificacaoRps>"	

	//-- Data e hora de emissao do documento	
	cString	+= "<DataEmissao>" + subStr( dToS( aNota[3] ), 1, 4 ) + "-" + subStr( dToS( aNota[3] ), 5, 2 ) + "-" + subStr( Dtos( aNota[3] ), 7, 2 ) + "T"+time()+"</DataEmissao>"	
	cString	+= "<NaturezaOperacao>"+cNatOP+"</NaturezaOperacao>"

	If !Empty(cMVREGIESP)
		cString += '<RegimeEspecialTributacao>'+cMVREGIESP+'</RegimeEspecialTributacao>'
	EndIf	
	
	cString += '<OptanteSimplesNacional>'+cMVOPTSIMP+'</OptanteSimplesNacional>'
	cString += "<IncentivadorCultural>"    + cMVINCECUL + "</IncentivadorCultural>"

	if empty( allTrim( aNota[8] ) + allTrim( aNota[7] ) )		
		//-- Situacao do RPS
		cString += "<Status>1</Status>" //-- Fixo pois tanto ABRASF como DSFNET, utilizam esta tag como Normal (1) - Obrigat.
	else
		cString += "<Status>2</Status>" //-- Fixo pois tanto ABRASF como DSFNET, utilizam esta tag como Normal (1) - Obrigat.	

		cString += "<RpsSubstituido>"
		cString += "<Numero>"+ allTrim(str( val(aNota[7]))) +"</Numero>"
		cString += "<Serie>" + allTrim(aNota[8]) + "</Serie>"
		cString += "<Tipo>1</Tipo>"
		cString += "</RpsSubstituido>"
	EndIf

Return cString


//-----------------------------------------------------------------------
/*/{Protheus.doc} ativ
Fun��o para montar a tag de atividade do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aProd	Array contendo as informa��es sobre os servi�os da nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function ativ( aProd, aISSQN )
	Local cString := ""

	If !Empty( allTrim( aProd[1][19] ) )
		cString += "<atividade>"
		cString += "<codigo>"   + allTrim( aProd[1][19] )     + "</codigo>"
		cString += "<aliquota>" + convType(DivCem(aISSQN[1][2]),7,4) + "</aliquota>"
		cString += "</atividade>"
	EndIf

Return cStrin

//-----------------------------------------------------------------------
/*/{Protheus.doc} prest
Fun��o para montar a tag de prestador do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function prest( cMunPSIAFI )
	Local aTemp			:= {}
	Local cImPrestador	:= iif( Empty( allTrim( SM0->M0_INSCM )),"ISENTO",allTrim( SM0->M0_INSCM ))
	Local cIEPrestador	:= allTrim( SM0->M0_INSC )
	Local cMVINCECUL	:= allTrim( GetMV( "MV_INCECUL",, "2" ) ) //-- Contribuinte optante do incentivo a cultura: 1=sim;2=nao
	Local cMVOPTSIMP	:= allTrim( GetMV( "MV_OPTSIMP",, "2" ) ) //-- Contribuinte optante do simples: 1=sim;2=nao
	Local cMVNUMPROC	:= allTrim( GetMV( "MV_NUMPROC",, " " ) ) //-- Numero processo judicial ou adm suspensao da exibilidade
	Local cEmail		:= allTrim( GetMV( "MV_EMAILPT",, " " ) ) //-- email prestador
	Local cString		:= ""

	default	cMunPSIAFI	:= ""

	aTemp := fisGetEnd( SM0->M0_ENDCOB )

	cImPrestador := strTran( cImPrestador, "-", "" )
	cImPrestador := strTran( cImPrestador, "/", "" )

	cIEPrestador := strTran( cIEPrestador, "-", "" )
	cIEPrestador := strTran( cIEPrestador, "/", "" )

	cString += "<Prestador>"

	cString += "<Cnpj>" + allTrim( SM0->M0_CGC )  + "</Cnpj>"
	cString += "<InscricaoMunicipal>"       + allTrim( cImPrestador )    + "</InscricaoMunicipal>"

	cString += "</Prestador>"

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} prestacao
Fun��o para montar a tag de presta��o do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	cMunPrest	C�digo de munic�pio IBGE da presta��o do servi�o.
@param	cDescMunP	Nome do munic�pio da presta��o do servi�o.
@param	aDest		Array contendo as informa��es sobre o tomador da nota.
@param	cMunPSIAFI	C�digo de munic�pio SIAFI da presta��o do servi�o.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function prestacao( cMunPrest, cDescMunP, aDest, cMunPSIAFI )
	Local aTabIBGE		:= {}
	Local aMvEndPres	:= &(GetMV("MV_ENDPRES",,"{}"))
	Local cString		:= ""
	Local nScan			:= 0

	default	cDescMunP	:= ""
	default	cMunPrest	:= ""
	default	cMunPSIAFI	:= ""

	aTabIBGE := spedTabIBGE()

	If Len( cMunPrest ) <= 5
		nScan := aScan( aTabIBGE, { | x | x[1] == aDest[9] } )
		If nScan <= 0
			nScan := aScan( aTabIBGE, { | x | x[4] == aDest[9] } )
			cMunPrest := aTabIBGE[nScan][1] + cMunPrest
		Else
			cMunPrest := aTabIBGE[nScan][4] + cMunPrest
		EndIf
	EndIf

	If Empty( cMunPrest )
		cMunPrest := allTrim( aDest[7] )
	EndIf
	If Empty( cMunPSIAFI )
		cMunPSIAFI := allTrim( aDest[18] )
	EndIf

	cString += "<prestacao>"
	cString += "<serieprest>99</serieprest>"
	If SC5->(FieldPos("C5_ENDPRES")) > 0
		cString += "<logradouro>" +  IIF( !Empty(FisGetEnd(SC5->C5_ENDPRES)[1] ),   FisGetEnd(SC5->C5_ENDPRES)[1], aDest[3] ) + "</logradouro>"
		cString += "<numend>"     + ConvType(IIF(FisGetEnd(SC5->C5_ENDPRES)[2]<> 0, FisGetEnd(SC5->C5_ENDPRES)[2], aDest[4] )) + "</numend>"
	Else
		cString += "<logradouro>" + IIf(!Empty(aDest[3]),allTrim( aDest[3] ),"") + "</logradouro>"
		cString += "<numend>"     + allTrim( aDest[4] ) + "</numend>"
	EndIf
	If !Empty( allTrim( aDest[5] ) )
		cString += "<complend>"  + allTrim( aDest[5] ) + "</complend>"
	EndIf
	If !Empty( allTrim( cMunPrest ) )
		cString += "<codmunibge>" + allTrim( cMunPrest ) + "</codmunibge>"
	EndIf
	If !Empty( allTrim( cMunPSIAFI ) )
		cString += "<codmunsiafi>" + allTrim( cMunPSIAFI ) + "</codmunsiafi>"
	endif
	cString += "<municipio>" + allTrim( cDescMunP ) + "</municipio>"
	If SC5->(FieldPos("C5_BAIPRES")) > 0	
		cString += "<bairro>" + IIF ( !Empty(SC5->C5_BAIPRES), SC5->C5_BAIPRES, aDest[6] ) + "</bairro>"
	Else
		cString += "<bairro>" + IIf(!Empty(aDest[6]),allTrim( aDest[6] ),"") + "</bairro>"
	EndIf
	If SC5->(FieldPos("C5_ESTPRES")) > 0
		cString += "<uf>" + IIF ( !Empty(SC5->C5_ESTPRES), SC5->C5_ESTPRES, aDest[9] ) + "</uf>" 
	Else
		cString += "<uf>" + IIf(!Empty(aDest[9]),allTrim( aDest[9] ),"") + "</uf>"
	EndIf
	If SC5->(FieldPos("C5_CEPPRES")) > 0
		cString += "<cep>" + IIF ( !Empty(SC5->C5_CEPPRES), SC5->C5_CEPPRES, aDest[10]) + "</cep>"
	Else
		cString += "<cep>" + IIf(!Empty(aDest[10]),allTrim( aDest[10] ),"" ) + "</cep>"
	EndIf
	cString += "</prestacao>"

Return cString
//-----------------------------------------------------------------------
/*/{Protheus.doc} intermediario
Fun��o para montar a tag de intermedi�rio do XML de envio de NFS-e ao TSS.

@author Karyna Martins
@since 24.04.2015

@param	aInterm	Array com as informa��es do intermediario da nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function intermediario( aInterm )

	Local cString	:= "" 

	Local lSemInt:= .F.

	If len(aInterm) > 0

		If Empty(aInterm[1]) .and. Empty(aInterm[2]) .and. Empty(aInterm[3])
			lSemInt:= .T.
		EndIf

		// Monta a tag de intermedi�rio com as informa��es do pedido
		If !lSemInt 

			cString	+= "<Intermediario><IdentificacaoIntermediario>"

			cString	+= "<CpfCnpj>" +iif(len(allTrim( aInterm[2])) == 14, '<Cnpj>','<Cpf>')+ allTrim( aInterm[2])+iif(len(allTrim( aInterm[2])) == 14, '</Cnpj>','</Cpf>')+"</CpfCnpj>"
			cString	+= "<InscricaoMunicipal>"+ alltrim( aInterm[3])+"</InscricaoMunicipal></IdentificacaoIntermediario>"	
			cString	+= "<RazaoSocial>"  + allTrim( aInterm[1])+"</RazaoSocial>"			
			cString	+= "</Intermediario>"

		EndIf

	EndIf

return cString
//-----------------------------------------------------------------------
/*/{Protheus.doc} tomador
Fun��o para montar a tag de tomador do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aDest	Array com as informa��es do tomador da nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function tomador( aDest )
	Local cString   := ""
	Local cCodTom   := aDest[7]
	Local lTomador  := .T.
	Local aIntermed := {}

	If Empty(aDest[1]) .And. Empty(aDest[2])
		lTomador:=.F.
	EndIf

	If lTomador
		cString	+= "<Tomador>"   

		if alltrim(adest[9]) == "EX"
			cString	:= "<Tomador>"
			cString += "<RazaoSocial>"      + allTrim( aDest[2] ) + "</RazaoSocial>"
			cString += "<Endereco>"
			cString += "<CodigoMunicipio>9999999</CodigoMunicipio>"
			cString += "<CodigoPais>"     + allTrim( aDest[11] ) + "</CodigoPais>"
			cString += "</Endereco>"
			cString	+= "</Tomador>"
		EndIf


		cString += "<IdentificacaoTomador><CpfCnpj>"  +iif(len(allTrim( aDest[1]  )) == 14,'<Cnpj>','<Cpf>')  +  allTrim( aDest[1]  ) +iif(len(allTrim( aDest[1]  )) == 14,'</Cnpj>','</Cpf>')+ "</CpfCnpj></IdentificacaoTomador>"

		cString += "<RazaoSocial>"      + allTrim( aDest[2] ) + "</RazaoSocial>"

		cString += "<Endereco>"
		cString += "<Endereco>" + allTrim( aDest[3] ) + "</Endereco>"
		cString += "<Numero>"     + allTrim( aDest[4] ) + "</Numero>"
		If !Empty( aDest[5] )
			cString += "<Complemento>" + allTrim( aDest[5] ) + "</Complemento>"
		EndIf
		cString += "<Bairro>" + allTrim( aDest[6] ) + "</Bairro>"
		If Len(cCodTom) <= 5 .And. !(cCodTom$'99999')
			cCodTom := UfIBGEUni(aDest[09]) + cCodTom
		EndIf
		If !Empty( aDest[7] )		
			cString += "<CodigoMunicipio>" + cCodTom + "</CodigoMunicipio>"
		EndIf
		cString += "<Uf>"+ allTrim( aDest[ 9] ) +"</Uf>"
		cString += "<Cep>"+allTrim( aDest[10] )+"</Cep>"
		cString += "</Endereco>"

		cString += "<Contato>"

		//-- DDD do telefone do Tomador - Nao Obrigat.
		cString += "<Telefone>"         + allTrim( str( fisGetTel( aDest[13] )[2], 3 ) ) + allTrim( str( fisGetTel( aDest[13] )[3], 15 ) ) + "</Telefone>"

		If !Empty( aDest[16] )
			cString += "<Email>" + allTrim( aDest[16] ) + "</Email>"
		EndIf		

		cString += "</Contato>"



		cString	+= "</Tomador>"


	EndIf

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} servicos
Fun��o para montar a tag de servi�os do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aProd		Array contendo as informa��es dos produtos da nota.
@param	aISSQN		Array contendo as informa��es sobre o imposto.
@param	aRetido		Array contendo as informa��es sobre impostos retidos.
@param	cNatOper	String contendo discriminacao do servico
@param	lNFeDesc	Logico contendo conteudo do parametro MV_NFEDESC

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function servicos( aProd, aISSQN, aRetido, cNatOper, lNFeDesc, cDiscrNFSe,aCST, cTpPessoa, cCodMun, cF4Agreg, nDescon,aDest, cNota, cSerie   )	
	Local aCofinsXML	:= { 0, 0, {} }
	Local aCSLLXML		:= { 0, 0, {} }
	Local aINSSXML		:= { 0, 0, {} }
	Local aIRRFXML		:= { 0, 0, {} }
	Local aISSRet		:= { 0, 0, 0, {} }
	Local aPisXML		:= { 0, 0, {} }

	Local cString		:= ""
	Local cCargaTrb		:= ""

	Local nOutRet		:= 0
	Local nScan			:= 0
	Local nValLiq		:= 0
	Local nX			:= 0

	local cMunPrest := ""
	
	local nBase := 0
	local nValIss := 0
	
	local cNFOrig := ""
	local nY

	Default cTpPessoa	:= ""
	Default cCodMun		:= ""
	Default cF4Agreg	:= ""
	Default nDescon		:= 0

	cString += "<Servico>"

	nX := 1
	
	// Tratando o abatimento para quando houver mais de um item de servi�o
	If len(aISSQN) > 1
		For nY := 1  to len(aISSQN)
			If 	aISSQN[nY][2] > 0
				nBase 		+= aISSQN[nY][1]
				nValIss	+= aISSQN[nY][3]
			EndIf
		Next nY
	Else
		nBase 		:= aISSQN[1][1]
		nValIss	:= aISSQN[1][3]		
	EndIF
	

	nScan := aScan(aRetido,{|x| x[1] == "ISS"})
	If nScan > 0
		aIssRet[1] += aRetido[nScan][3]
		aIssRet[2] += aRetido[nScan][5]
		aIssRet[3] += aRetido[nScan][4]
		aIssRet[4] := aRetido[nScan][6]
	EndIf

	nScan := aScan(aRetido,{|x| x[1] == "PIS"})
	If nScan > 0
		aPisXml[1] := aRetido[nScan][3]
		aPisXml[2] += aRetido[nScan][4]
		aPisXml[3] := aRetido[nScan][5]
	EndIf

	nScan := aScan(aRetido,{|x| x[1] == "COFINS"})
	If nScan > 0
		aCofinsXml[1] := aRetido[nScan][3]
		aCofinsXml[2] += aRetido[nScan][4]
		aCofinsXml[3] := aRetido[nScan][5]
	EndIf

	nScan := aScan(aRetido,{|x| x[1] == "IRRF"})
	If nScan > 0
		aIrrfXml[1] := aRetido[nScan][3]
		aIrrfXml[2] += aRetido[nScan][4]
		aIrrfXml[3] := aRetido[nScan][5]
	EndIf

	nScan := aScan(aRetido,{|x| x[1] == "CSLL"})
	If nScan > 0
		aCSLLXml[1] := aRetido[nScan][3]
		aCSLLXml[2] += aRetido[nScan][4]
		aCSLLXml[3] := aRetido[nScan][5]
	EndIf

	nScan := aScan(aRetido,{|x| x[1] == "INSS"})
	If nScan > 0
		aInssXml[1] := aRetido[nScan][3]
		aInssXml[2] += aRetido[nScan][4]
		aInssXml[3] := aRetido[nScan][5]
	EndIf

	//Carga Tribut�ria
	If aProd[Nx][35] > 0
		cCargaTrb := " - Valor aproximado dos tributos: R$ " + ConvType(aProd[Nx][35],15,2) +"."
	EndIf

	//Outras reten��es, sera colocado o valor 0 (zero), pois atualmente nao existe valor de Outras retencoes 
	If Len(aRetido) > 0
		nOutRet := 0
	EndIf

	aTabIBGE := spedTabIBGE()

	If Len( cMunPrest ) <= 5
		nScan := aScan( aTabIBGE, { | x | x[1] == aDest[9] } )
		If nScan <= 0
			nScan := aScan( aTabIBGE, { | x | x[4] == aDest[9] } )
			cMunPrest := aTabIBGE[nScan][1] + cMunPrest
		Else
			cMunPrest := aTabIBGE[nScan][4] + cMunPrest
		EndIf
	EndIf

	If Empty( cMunPrest )
		cMunPrest := allTrim( aDest[7] )
	EndIf

	nValLiq := aProd[Nx][27] - aPisXml[3][Nx] - aCofinsXml[3][Nx]  - Iif(Len(aInssXml[3]) > 1 .And. len( aProd ) > 1,aInssXml[3][Nx],aInssXml[1]) - Iif(Len(aIRRFXml[3]) > 1 .And. len( aProd ) > 1,aIRRFXml[3][Nx],aIRRFXml[1]) - aCSLLXml[3][Nx] - Iif(Len(aIssRet[4]) > 1 .And. len( aProd ) > 1,aIssRet[4][Nx],aIssRet[1])
	cString += "<Valores>"

	//		cString += "<aliquota>" + allTrim((iif(!empty( convType( DivCem(aISSQN[1][2]),7,4 ) ), convType( DivCem(aISSQN[1][2]), 7, 4 ), convType(DivCem( aISSRet[3]),7,4) ))) + "</aliquota>"
	//		cString += "<cnae>"    + allTrim( aProd[nX][19] ) + "</cnae>"
	//		cString += "<codtrib>" + allTrim( aProd[nX][34] ) + allTrim( aProd[nX][32] ) + "</codtrib>"



	cString += "<ValorServicos>"  + allTrim( convType( aProd[nX][28], 15, 2 ) ) + "</ValorServicos>"
	cString += "<ValorDeducoes>"   + allTrim( convType( aProd[nX][29], 15, 2 ) ) + "</ValorDeducoes>"
	cString += "<ValorPis>"    + allTrim( convType( aPisXml[1],    15, 2 ) ) + "</ValorPis>"
	cString += "<ValorCofins>"    + allTrim( convType( aCofinsXml[1], 15, 2 ) ) + "</ValorCofins>"
	cString += "<ValorInss>"   + allTrim( convType( aInssXml[1],   15, 2 ) ) + "</ValorInss>"
	cString += "<ValorIr>"     + allTrim( convType( aIRRFXml[1],   15, 2 ) ) + "</ValorIr>"
	cString += "<ValorCsll>"   + allTrim( convType( aCSLLXml[1],   15, 2 ) ) + "</ValorCsll>"
	cString += "<OutrasRetencoes>" + allTrim( convType( nOutRet,       15, 2 ) ) + "</OutrasRetencoes>"
	cString += "<BaseCalculo>"+ allTrim( convType( nBase,         15, 2 ) ) + "</BaseCalculo>"	
	cString += "<Aliquota>" + convType(DivCem(aISSQN[1][2]),7,4) + "</Aliquota>"
	cString += "<ValorLiquidoNfse>"+allTrim( convType( aProd[nX][27], 15, 2 ) )+"</ValorLiquidoNfse>"
	cString += "<IssRetido>" + iif( !Empty( aISSRet[2] ), "1", "2" )       + "</IssRetido>"
	cString += "<DescontoCondicionado>0</DescontoCondicionado>"
	cString += "<DescontoIncondicionado>0</DescontoIncondicionado>"


	cString += "</Valores>"
	
	cQry := "select *  From "+RetSQLName("SF2")+" F2 
	cQry += " where F2_XTIPONF = '2' and F2.D_E_L_E_T_ <>'*' and F2_FILIAL =  '"+xFilial("SF2")+"' and F2_DOC = '"+cNota+"' and F2_SERIE = '"+cSerie+"' "
	
	TcQuery cQry new alias "QBETHA"
	
	If QBETHA->(!EOF())
		cNFOrig := QBETHA->F2_XIDVNFK
	EndIf
	QBETHA->(DbCloseArea())		

	if !Empty(alltrim(cNFOrig))
		cQry := "select *  From "+RetSQLName("SF2")+" F2 
		cQry += " where F2_XTIPONF = '1' and F2_XIDVNFK = '"+cNFOrig+"' and F2.D_E_L_E_T_ <>'*' and F2_FILIAL =  '"+xFilial("SF2")+"' "
		
		TcQuery cQry new alias "QBETHA"
		
		cNFOrig := ""
		
		If QBETHA->(!EOF())
			cNFOrig := chr(13)+chr(10)+"REFERENTE A NOTA "+QBETHA->F2_DOC+"/"+Alltrim(QBETHA->F2_SERIE)
		EndIf
		QBETHA->(DbCloseArea())
		
	EndIF
	
	cString += "<ItemListaServico>" + allTrim( aProd[nX][24] ) + "</ItemListaServico>"  
	cString += "<CodigoCnae>"+alltrim( aProd[nX][28] )+"</CodigoCnae>"
	cString += "<CodigoTributacaoMunicipio>" + allTrim( aProd[nX][23] ) + "</CodigoTributacaoMunicipio>"


	If ( SC6->(FieldPos("C6_DESCRI")) > 0 .And. Len(aProd[nX]) > 40 .And. !Empty(aProd[nX][41]) ) .And. (!lNFeDesc .And. !GetNewPar("MV_NFESERV","1") == "1" .And. !Empty(GetMV("MV_CMPUSR")) )
		cString	+= "<Discriminacao>" + AllTrim(aProd[nX][41])+ cCargaTrb + cNFOrig+ "</Discriminacao>"
	ElseIf !lNFeDesc
		cString	+= "<Discriminacao>" + AllTrim(cNatOper)+ cCargaTrb + cNFOrig+ "</Discriminacao>"
	Else
		cString	+= "<Discriminacao>" + AllTrim(cDiscrNFSe)+ cCargaTrb + cNFOrig+ "</Discriminacao>"
	EndIf		

	cString	+= "<CodigoMunicipio>"+cCodMun+"</CodigoMunicipio>"
//	cString	+= "<ExigibilidadeISS>"+Iif(SF4->F4_ISS$"1/S","1",(Iif(SF4->F4_LFISS$"I/O" .And. SF4->F4_CSTISS$"06","3",(Iif(SF4->F4_LFISS$"I/O" .And. SF4->F4_CSTISS$"07","2",Iif(Substr(SF4->F4_CF,1,1)$"7","4","0"))))))+"</ExigibilidadeISS>"		
//	cString	+= "<MunicipioIncidencia>"+cMunPrest+"</MunicipioIncidencia>"				

	cString += "</Servico>"

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} valores
Fun��o para montar a tag de valores do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 23.01.2012

@param	aISSQN		Array contendo as informa��es sobre imposto.
@param	aRetido		Array contendo as informa��es sobre impostos retidos.
@param	aTotal		Array contendo os valores totais da nota.
@param	aDest		Array contendo as informa��es de destinat�rio.
@param	cCodMun		string contendo codigo do municipio prestador

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function valores( aISSQN, aRetido, aTotal, aDest, cCodMun , aDeducao )

	Local aCOFINSXML	:= { 0, 0, 0 }
	Local aCSLLXML		:= { 0, 0, 0 }
	Local aINSSXML		:= { 0, 0, 0 }
	Local aIRRFXML		:= { 0, 0, 0 }
	Local aISSRet		:= { 0, 0, 0 }
	Local aPISXML		:= { 0, 0, 0 }
	Local cString		:= ""
	Local nOutRet		:= 0
	Local nScan		:= 0
	Local nY			:= 0
	local nBase		:= 0
	local nValIss		:= 0
	local nValDeduz		:= 0

	If Len (aDeducao) > 0

		For nY := 1 to Len(aDeducao)
			nValDeduz += aDeducao[nY,1]
		Next nY

	EndIf 

	// Tratando o abatimento para quando houver mais de um item de servi�o
	If len(aISSQN) > 1
		For nY := 1  to len(aISSQN)
			If 	aISSQN[nY][2] > 0
				nBase 		+= aISSQN[nY][1]
				nValIss	+= aISSQN[nY][3]
			EndIf
		Next nY
	Else
		nBase 		:= aISSQN[1][1]
		nValIss	:= aISSQN[1][3]		
	EndIF

	nScan := aScan( aRetido, { | x | x[1] == "ISS" } )
	If nScan > 0
		aISSRet[1]	+= aRetido[nScan][3]
		aISSRet[2]	+= aRetido[nScan][5]
		aISSRet[3]	+= aRetido[nScan][4]
	EndIf

	nScan := aScan( aRetido, { | x | x[1] == "PIS" } )
	If nScan > 0
		aPISXML[1] := aRetido[nScan][3]
		aPISXML[2] += aRetido[nScan][4]
		aPISXML[3] += aRetido[nScan][2]
	EndIf

	nScan := aScan( aRetido, { | x | x[1] == "COFINS" } )
	If nScan > 0
		aCOFINSXML[1] := aRetido[nScan][3]
		aCOFINSXML[2] += aRetido[nScan][4]
		aCOFINSXML[3] += aRetido[nScan][2]
	EndIf

	nScan := aScan( aRetido, { | x | x[1] == "INSS" } )
	If nScan > 0
		aINSSXML[1] := aRetido[nScan][3]
		aINSSXML[2] += aRetido[nScan][4]
		aINSSXML[3] += aRetido[nScan][2]
	EndIf

	nScan := aScan( aRetido, { | x | x[1] == "IRRF" } )
	If nScan > 0
		aIRRFXML[1] := aRetido[nScan][3]
		aIRRFXML[2] += aRetido[nScan][4]
		aIRRFXML[3] += aRetido[nScan][2]
	EndIf

	nScan := aScan( aRetido, { | x | x[1] == "CSLL" } )
	If nScan > 0
		aCSLLXML[1] := aRetido[nScan][3]
		aCSLLXML[2] += aRetido[nScan][4]
		aCSLLXML[3] += aRetido[nScan][2]
	EndIf

	If Len( aRetido ) > 0
		nOutRet	:= 0
	EndIf

	cString	+= "<valores>"
	cString += "<iss>"        + allTrim( convType( nValIss,       15, 2 ) ) + "</iss>"
	cString += "<issret>"     + allTrim( convType( aISSRet[1],    15, 2 ) ) + "</issret>"
	cString += "<outrret>"    + allTrim( convType( nOutRet,       15, 2 ) ) + "</outrret>"
	cString += "<pis>"        + allTrim( convType( aPISXML[1],    15, 2 ) ) + "</pis>"
	cString += "<cofins>"     + allTrim( convType( aCOFINSXml[1], 15, 2 ) ) + "</cofins>"
	cString += "<inss>"       + allTrim( convType( aINSSXML[1],   15, 2 ) ) + "</inss>"
	cString += "<ir>"         + allTrim( convType( aIRRFXML[1],   15, 2 ) ) + "</ir>"
	cString += "<csll>"       + allTrim( convType( aCSLLXML[1],   15, 2 ) ) + "</csll>"
	cString += "<aliqiss>"    + allTrim( convType( (DivCem(Iif( !empty( aISSQN[1][02] ), aISSQN[1][02], aISSRet[3] ))), 15, 4 ) ) + "</aliqiss>"
	cString += "<aliqpis>"    + allTrim( convType( DivCem(aPISXML[2])	  	, 15, 4 ) ) + "</aliqpis>"
	cString += "<aliqcof>"    + allTrim( convType( DivCem(aCOFINSXML[2])	, 15, 4 ) ) + "</aliqcof>"
	cString += "<aliqinss>"   + allTrim( convType( DivCem(aINSSXML[2])		, 15, 4 ) ) + "</aliqinss>"
	cString += "<aliqir>"     + allTrim( convType( DivCem(aIRRFXML[2])		, 15, 4 ) ) + "</aliqir>"
	cString += "<aliqcsll>"   + allTrim( convType( DivCem(aCSLLXML[2])		, 15, 4 ) ) + "</aliqcsll>"
	cString += "<valtotdoc>"  + allTrim( convType( aTotal[4],     15, 2 ) ) + "</valtotdoc>"
	cString += "<basecalculo>"+ allTrim( convType( nBase,         15, 2 ) ) + "</basecalculo>"
	cString += "<vliquinfse>" + allTrim( convType( aTotal[2],     15, 2 ) ) + "</vliquinfse>"
	//-- Justificativa para dedu��o
	cString += "<dJustificaDeducao></dJustificaDeducao>"    
	cString += "<basecalculopis>"   + allTrim( convType( aPISXML[3],   15, 2 ) ) + "</basecalculopis>"
	cString += "<basecalculocofins>"+ allTrim( convType( aCOFINSXML[3],15, 2 ) ) + "</basecalculocofins>"
	cString += "<basecalculocsll>"  + allTrim( convType( aCSLLXML[3],  15, 2 ) ) + "</basecalculocsll>"
	cString += "<basecalculoirrf>"  + allTrim( convType( aIRRFXML[3],  15, 2 ) ) + "</basecalculoirrf>"
	cString += "<basecalculoinss>"  + allTrim( convType( aINSSXML[3],  15, 2 ) ) + "</basecalculoinss>"
	//-- Al�quota de outro munic�pio envolvido na presta��o do servi�o.
	cString += "<aloutromunicipio></aloutromunicipio> 
	//-- Al�quota do simples Nacional ou do Contribuinte que tem Isen��o Parcial.
	cString += "<alsnip></alsnip>
	//-- Valor de dedu��o do valor na base de c�lculo do INSS.
	cString += "<vldeducaobaseinss></vldeducaobaseinss> 
	cString += "</valores>"

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} faturas
Fun��o para montar a tag de faturas do XML de envio de NFS-e ao TSS.

@author Flavio Luiz Vicco
@since 08.08.2014

@param	aDupl		Array contendo informa��es sobre as faturas.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function faturas( aDupl )
	Local cString	:= ""
	Local nX		:= 0

	If Len( aDupl ) > 0
		cString	+= "<faturas>"
		For nX := 1 To Len( aDupl )
			cString += "<fatura>"
			cString += "<numero>" + allTrim( aDupl[nX][1] ) + "</numero>"
			cString += "<valor>"  + allTrim( convType( aDupl[nX][3], 15, 2 ) ) + "</valor>"
			//-- Condi��o/Forma de Pagamento
			cString += "<condPagamento></condPagamento>"
			//-- Descrica��o o tipo de vencimento da fatura.
			cString += "<descFatura></descFatura>"
			//-- URL para impress�o da fatura/ boleto
			cString += "<urlFatura></urlFatura>"
			//-- "Indicador de gera��o do boleto na prefeitura | 1 - Sim 2 - N�o"
			cString += "<gerarFatura></gerarFatura>"		
			cString += "</fatura>"
		Next nX
		cString += "</faturas>"
	EndIf

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} pagtos
Fun��o para montar a tag de valores do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 06.02.2012

@param	aDupl		Array contendo informa��es sobre os pagamentos.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function pagtos( aDupl )
	Local cString	:= ""
	Local cTemp		:= ""
	Local nX		:= 0
	



	If Len( aDupl ) > 0
	cString += "<CondicaoPagamento>"
	cString += "<Condicao>"+iif(len(aDupl)==1 .and. aDupl[1][2] >= ddatabase,"A_VISTA","A_PRAZO")+"</Condicao>"
	cString += "<QtdParcela>"+ alltrim(str(len(aDupl)))+"</QtdParcela>"
		

		For nX := 1 To Len( aDupl )
			cString	+= "<Parcelas>"		
			cTemp := dToS( aDupl[nX][2] )
			cString += "<Parcela>"+alltrim(str(nX))+"</Parcela>"
			cString += "<DataVencimento>"  + subStr( allTrim( cTemp ), 7, 2 ) + "-" + subStr( allTrim( cTemp ), 5, 2 ) + "-" + subStr( allTrim( cTemp ), 1, 4 ) + "</DataVencimento>"
			cString += "<Valor>"   + allTrim( convType( aDupl[nX][3], 15, 2 ) ) + "</Valor>"
			cString += "</Parcelas>"			
		Next nX

		cString += "</CondicaoPagamento>"
	EndIf
	
	

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} deducoes
Fun��o para montar a tag de dedu��es do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 23.01.2012

@param	aProd	Array contendo as informa��es sobre os servi�os.
@param	aDeduz	Array contendo as informa��es sobre as dedu��es.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function deducoes( aISSQN, aDeduz, aDeducao, aConstr )

	Local cCPFCNPJ	:= ""
	Local cString	:= ""
	Local nX		:= 0
	Local nDesInc := 0

	If Len( aDeduz ) <= 0 .And. Len( aDeducao ) <= 0
		Return cString
	EndIf

	cString+= "<deducoes>"
	cString += "<desccond>0</desccond>"
	If  Len( aISSQN ) > 0		
		For nX := 1 To Len( aISSQN )
			nDesInc += aISSQN[nX][6]
		Next nX
		cString += "<descincond>" + allTrim( convType( nDesInc, 15, 2 ) ) + "</descincond>"	
	EndIf
	If  Len( aDeduz ) > 0
		For nX := 1 To Len( aDeduz )
			cCPFCNPJ := allTrim( posicione( "SA2", 1, xFilial( "SA2" ) + aDeduz[nX][3] + aDeduz[nX][4], "A2_CGC" ) )
			cString += "<deducao>"
			cString += "<tipo>"       + iif( empty( allTrim( aDeduz[nX][1] ) ), "1", iif( allTrim( aDeduz[nX][1] ) == "1", "1", "2") ) + "</tipo>"
			cString += "<modal>"      + iif( empty( allTrim( aDeduz[nX][2] ) ), "1", iif( allTrim( aDeduz[nX][2] ) == "1", "1", "2" ) ) + "</modal>"
			If !Empty( aConstr )
				cString += '<codobra>'+ AllTrim(aConstr[01]) + '</codobra>'
				cString += '<codart>' + AllTrim(aConstr[02]) +'</codart>'
			Else
				cString += "<codobra></codobra>"
				cString += "<codart></codart>"
			EndIf
			cString += "<cpfcnpj>"    + iif( empty( cCPFCNPJ ), "00000000000191", cCPFCNPJ ) + "</cpfcnpj>"
			cString += "<numeronf>"   + iif( empty( allTrim( aDeduz[nX][6] ) ), "1", allTrim( aDeduz[nX][6] ) ) + "</numeronf>"
			cString += "<totalnf>"    + allTrim( convType( aDeduz[nX][7], 15, 2 ) ) + "</totalnf>"
			cString += "<percentual>" + iif( aDeduz[nX][1] == "1", allTrim( convType( aDeduz[nX][8], 15, 2 ) ), "0.00" ) + "</percentual>"
			cString += "<valor>"      + iif( aDeduz[nX][1] == "2", allTrim( convType( aDeduz[nX][9], 15, 2 ) ), "0.00" ) + "</valor>"
			//-- Descri��o do Material
			cString += "<descricaomaterial></descricaomaterial>"
			//-- Valor Unit�rio do Material
			cString += "<valorunitariomaterial></valorunitariomaterial>"	
			//-- Quantidade do Material
			cString += "<quantidadematerial></quantidadematerial>	
			cString += "</deducao>"
		Next nX
	Else
		For nX := 1 To Len( aDeducao )
			cString += "<deducao>"
			cString += "<tipo>1</tipo>"
			cString += "<modal>1</modal>"
			If !Empty( aConstr )
				cString += '<codobra>'+ AllTrim(aConstr[01]) + '</codobra>'
				cString += '<codart>' + AllTrim(aConstr[02]) +'</codart>'
			EndIf
			cString += "<cpfcnpj>" + iif( empty( cCPFCNPJ ), "00000000000191", cCPFCNPJ ) + "</cpfcnpj>"
			cString += "<numeronf>1</numeronf>"
			cString += "<totalnf>0.00</totalnf>"
			cString += "<percentual>0.00</percentual>"
			cString += "<valor>" + allTrim( convType( aDeducao[nX][1], 15, 2 ) ) + "</valor>"
			cString += "</deducao>"
		Next nX
	EndIf
	cString	+= "</deducoes>"

Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} infCompl
Fun��o para montar a tag de informa��es complementares do XML de envio
de NFS-e ao TSS.

@author Marcos Taranta
@since 23.01.2012

@param	cMensCli	Mensagem complementar ao cliente.
@param	cMensFis	Mensagem complementar ao fisco.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function infCompl( cMensCli, cMensFis, lNFeDesc, cDescrNFSe, aConstr )
	Local cString := ""

	If Empty(cMensCli + cMensFis)
		cMensCli := "-"
	EndIf
	If Empty(cDescrNFSe)
		cDescrNFSe := "-"
	EndIf
	cString += "<infcompl>"
	//-- Descricao - Tam 2000 - Obrigat.
	If !lNFeDesc
		cString += "<descricao>" + convType(cMensCli) + space( 1 ) + convType(cMensFis) + "</descricao>"
	Else
		cString += "<descricao>" + Alltrim(convType(cDescrNFSe)) + "</descricao>"
	EndIf
	//-- Observacao - Tam 255 - Nao Obrigat.
	cString += "<observacao>" + convType(cMensCli) + space( 1 ) + convType(cMensFis) + "</observacao>"

	if ( !Empty(aConstr[01]) .Or. !Empty(aConstr[02]) )
		cString += "<constrciv>"

		//-- Nome da obra da constru��o civil.
		cString += "<nomeobra></nomeobra>"	
		//-- Endere�o da constru��o civil.
		cString += If(Len(aConstr) >= 04 .And. !Empty(aConstr[04]), '<endereco>'+aConstr[04]+'</endereco>' , "" )
		//-- N�mero do endere�o da constru��o civil.
		cString += If(Len(aConstr) >= 06 .And. !Empty(aConstr[06]), '<numero>'+aConstr[06]+'</numero>' , "" )	
		//-- Complemento do endere�o da constru��o civil.		
		cString += If(Len(aConstr) >= 05 .And. !Empty(aConstr[05]), '<compl>'+aConstr[05]+'</compl>' ,"" )	
		//-- Bairro do endere�o da constru��o civil.			
		cString += If(Len(aConstr) >= 07 .And. !Empty(aConstr[07]), '<bairro>'+aConstr[07]+'</bairro>' , "" )	
		//-- C�digo do munic�pio da constru��o civil.	
		cString += If(Len(aConstr) >= 09 .And. !Empty(aConstr[09]), '<codmunibge>'+ IIF(Len(aConstr[09])==7,aConstr[09],UfIBGEUni(aConstr[11]+ aConstr[09]))+'</codmunibge>' , "" )
		//-- Unidade federativa do endere�o da constru��o civil	
		cString += If(Len(aConstr) >= 11 .And. !Empty(aConstr[11]), '<uf>'+aConstr[11]+'</uf>' , "" )	
		//-- CEP do endere�o da constru��o civil.
		cString += If(Len(aConstr) >= 08 .And. !Empty(aConstr[08]), '<cep>'+aConstr[08]+'</cep>' , "")
		//-- Descri��o do munic�pio da Obra.
		cString += If(Len(aConstr) >= 10 .And. !Empty(aConstr[10]), '<dMunObra>'+aConstr[10]+'</dMunObra>' , "" )	
		//-- C�digo do pa�s da Obra.
		cString += If(Len(aConstr) >= 12 .And. !Empty(aConstr[12]), '<cPais>'+aConstr[12]+'</cPais>' , "" )	
		//-- Descri��o pa�s da Obra.			
		cString += If(Len(aConstr) >= 13 .And. !Empty(aConstr[13]), '<dPais>'+aConstr[13]+'</dPais>' , "" )	
		//-- N�mero do projeto.
		cString += If(Len(aConstr) >= 16 .And. !Empty(aConstr[16]), '<nProjObra>'+aConstr[16]+'</nProjObra>' ,"" )	
		//-- N�mero da matr�cula da Obra.
		cString += If(Len(aConstr) >= 17 .And. !Empty(aConstr[17]), '<nMatriObra>'+aConstr[17]+'</nMatriObra>' , "" )
		//-- Redu��o Base C�lculo Constru��o Civil.
		cString += "<vlRedBCConstrucaoCivil></vlRedBCConstrucaoCivil>"	
		//-- Valor das dedu��es de materiais da constru��o civil.		
		cString += "<dedmat></dedmat>"	
		//-- Valor das dedu��es de materiais da constru��o civil.
		cString += "<dedsubemp></dedsubemp>"
		//--  "Servi�o prestado em vias p�blicas.Identifica��o de Sim/N�o: 1 = Sim 2 = N�o"
		cString += If(Len(aConstr) >= 03 .And. !Empty(aConstr[03]), '<servprestviapublica>'+aConstr[03]+'</servprestviapublica>' , "<servprestviapublica>2</servprestviapublica>" )
		//-- "Tipo de empreitada Consulte os valores na tabela 9"	
		cString += If(Len(aConstr) >= 18 .And. !Empty(aConstr[18]), '<tpempreitada>'+aConstr[18]+'</tpempreitada>' , "<tpempreitada>1</tpempreitada>" )						

		cString += "</constrciv>"	
	endif	
	cString += "</infcompl>"

Return cString
//-----------------------------------------------------------------------
/*/{Protheus.doc} construcao
Fun��o para montar a tag de constru��o civil do XML de envio de NFS-e ao TSS.

@author Rafael dos Santos Iaquinto
@since 23.12.2015

@param	aConstr		Array contendo dados da constru��o civil.

@return cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function construcao( aConstr )

	local cString	:= ""


	If Len( aConstr ) >= 2 .And. ( !Empty(aConstr[01]) .Or. !Empty(aConstr[02]) )   
		cString += "<ConstrucaoCivil>"

		cString += '<CodigoObra>'+AllTrim(aConstr[01])+'</CodigoObra>'
		cString += '<Art>'+AllTrim(aConstr[02])+'</Art>'

		cString += "</ConstrucaoCivil>"
	EndIf 

return cString


//-----------------------------------------------------------------------
/*/{Protheus.doc} convType
Fun��o para converter qualquer tipo de informa��o para string.

@author Marcos Taranta
@since 19.01.2012

@param	xValor	Informa��o a ser convertida.
@param	nTam	Tamanho final da string a ser retornada.
@param	nDec	N�mero de casa decimais para informa��es num�ricas.

@return	cNovo	Informa��o em forma de string a ser retornada.
/*/
//-----------------------------------------------------------------------
static function convType( xValor, nTam, nDec )

	local	cNovo	:= ""

	default	nDec	:= 0

	do case
		case valType( xValor ) == "N"
		if xValor <> 0
			cNovo	:= allTrim( str( xValor, nTam, nDec ) )
			cNovo	:= strTran( cNovo, ",", "." )
		else
			cNovo	:= "0"
		endif
		case valType( xValor ) == "D"
		cNovo	:= fsDateConv( xValor, "YYYYMMDD" )
		cNovo	:= subStr( cNovo, 1, 4 ) + "-" + subStr( cNovo, 5, 2 ) + "-" + subStr( cNovo, 7 )
		case valType( xValor ) == "C"
		if nTam == nil
			xValor	:= allTrim( xValor )
		endif
		default	nTam	:= 60
		cNovo := allTrim( encodeUTF8( NoAcento( subStr( xValor, 1, nTam ) ) ) )
	endcase

return cNovo

//-----------------------------------------------------------------------
/*/{Protheus.doc} myGetEnd
Fun��o para pegar partes do endere�o de uma �nica string.

@author Marcos Taranta
@since 24.01.2012

@param	cEndereco	String do endere�o �nico.
@param	cAlias		Alias da base.

@return	aRet		Partes separadas do endere�o em um array.
/*/
//-----------------------------------------------------------------------
static function myGetEnd( cEndereco, cAlias )

	local aRet		:= { "", 0, "", "" }

	local cCmpEndN	:= subStr( cAlias, 2, 2 ) + "_ENDNOT"
	local cCmpEst	:= subStr( cAlias, 2, 2 ) + "_EST"

	// Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
	// Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
	if ( &( cAlias + "->" + cCmpEst ) == "DF" ) .Or. ( ( cAlias )->( FieldPos( cCmpEndN ) ) > 0 .And. &( cAlias + "->" + cCmpEndN ) == "1" )
		aRet[1] := cEndereco
		aRet[3] := "SN"
	else
		aRet := fisGetEnd( cEndereco )
	endIf

return aRet 

//-----------------------------------------------------------------------
/*/{Protheus.doc} vldIE
Valida IE.

@author Marcos Taranta
@since 24.01.2012

@param	cInsc	IE.
@param	lContr	Caso .F., retorna "ISENTO".

@return	aRet	Retorna a IE.
/*/
//-----------------------------------------------------------------------
Static Function vldIE( cInsc, lContr )

	local cRet		:= ""

	local nI		:= 1

	default lContr	:= .T.

	for nI := 1 to len( cInsc )
		if isDigit( subs( cInsc, nI, 1 ) ) .Or. isAlpha( subs( cInsc, nI, 1 ) )
			cRet += subs( cInsc, nI, 1)
		endif
	next

	cRet := allTrim( cRet )
	if "ISENT" $ upper( cRet )
		cRet := ""
	endif

	if !( lContr ) .And. !empty( cRet )
		cRet := "ISENTO"
	endif

return cRet 


//-----------------------------------------------------------------------
/*/{Protheus.doc} UfIBGEUni
Funcao que retorna o codigo da UF do participante, de acordo com a tabela 
disponibilizada pelo IBGE.

@author Simone Oliveira
@since 02.08.2012

@param	cUf 	Sigla da UF do cliente/fornecedor

@return	cCod	Codigo da UF
/*/
//-----------------------------------------------------------------------

Static Function UfIBGEUni (cUf,lForceUF)
	Local nX         := 0
	Local cRetorno   := ""
	Local aUF        := {}

	DEFAULT lForceUF := .T.

	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"EX","99"})

	If !Empty(cUF)
		nX := aScan(aUF,{|x| x[1] == cUF})
		If nX == 0
			nX := aScan(aUF,{|x| x[2] == cUF})
			If nX <> 0
				cRetorno := aUF[nX][1]
			EndIf
		Else
			cRetorno := aUF[nX][2]
		EndIf
	Else
		cRetorno := IIF(lForceUF,"",aUF)
	EndIf

Return(cRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} Cancela
Fun��o para montar a tag de cancelamento do XML de envio de NFS-e

@author Flavio Luiz Vicco
@since 15.08.2014

@param	cMotCancela	Motivo do cancelamento do documento.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------

User Function nfseXMLCan( cNota,cSerie, cMotCancela, nLote )

	Local cString := ""
	
	cQuery := " select top 1 * from "+RetSQLName("ZP6")+ " where D_E_L_E_T_ <> '*' and ZP6_FILIAL = '"+xFilial("ZP6")+"' and ZP6_ID = '"+cSerie+cNota+"' and ZP6_NOTA <> '' and ZP6_ERRO = '' order by R_E_C_N_O_ desc "
	
	TcQuery cQuery new alias "QZP6"
	
	If QZP6->(!EOF())
	cNota := Alltrim(QZP6->ZP6_NOTA)
	EndIf
	QZP6->(DbCloseArea())	
	cString	+= '<Pedido xmlns="">'
	cString	+= '<InfPedidoCancelamento Id="Cancelamento_'+allTrim( Str( nLote ) )+'">'
	cString	+= "<IdentificacaoNfse>"                                 
	cString += "<Numero>" + allTrim( str( val( cNota ) ) ) + "</Numero>"
	cString += "<Cnpj>"    + allTrim( SM0->M0_CGC ) + "</Cnpj>"
	cString += "<InscricaoMunicipal>" + iif( Empty( allTrim( SM0->M0_INSCM )),"ISENTO",allTrim( SM0->M0_INSCM )) + "</InscricaoMunicipal>"

	cString += "<CodigoMunicipio>" + allTrim( SM0->M0_CODMUN ) + "</CodigoMunicipio>"
	//cString += "<CodigoMunicipio>0</CodigoMunicipio>"
	cString	+= "</IdentificacaoNfse>"
	//-- Existem municipios que fazem varias inscricoes municipais para mesmo CNPJ para controlar cada ramo de atividade.
	cString += "<CodigoCancelamento>"+ convType(cMotCancela)  + "</CodigoCancelamento>"

	cString	+= "</InfPedidoCancelamento>"
	cString	+= "</Pedido>"
	cString := encodeUTF8( cString )
	

Return cString
//-----------------------------------------------------------------------
/*/{Protheus.doc} DivCem
Fun��o para montar a tag de Aliquota do XML de envio de NFS-e

@author Cleiton Genuino
@since 14.06.2015

@return nValor		    Valor de retorno  da Tag "aliquota"
/*/
//-----------------------------------------------------------------------

Static Function DivCem ( nVP )

	Default nVP := 0
	//VP	Valor Percentual	Valor percentual da al�quotano formato: 0.0000
	//Ex: 1% = 0.01 ; 25,5% = 0.255 ; 100% = 1.0000 ou 1

	If nVP > 0
		nVP := NOROUND((nVP /100), 4)
	Endif


Return nVP

//-----------------------------------------------------------------------
/*/{Protheus.doc} NatPCC
Fun��o que verifica os pontos de inclus�o da natureza de opera��o

@author Cleiton Genuino
@since 31.12.2015

@return aNatPCC	array com ponteiro e Valor da Natureza para compor calculo PCC
/*/
//-----------------------------------------------------------------------

Static Function  NatPCC ( aDest , cNatPCC  )

	Local aArea	 := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local cNatBusc := ""

	Default aDest   := {}
	Default cNatPCC := "SA1->A1_NATUREZ"

	//������������������������������������������������������������������������Ŀ
	//�Posiciona Natureza do pedido                                            �
	//��������������������������������������������������������������������������				
	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )

	dbSelectArea("SD2")	
	SD2->( dbSetOrder(3) )

	If SD2->( MsSeek( xFilial("SD2") + aDest[23] + aDest[24])) 	 //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM,

		If SC5->( MsSeek( xFilial("SC5") + SD2->D2_PEDIDO) )

			If SC5->(FieldPos("C5_NATUREZ") > 0 ) .And. !Empty(SC5->C5_NATUREZ)	
				cNatBusc := SC5->C5_NATUREZ

			Elseif (len (aDest) > 0 .And. !Empty(aDest[19]) )	
				cNatBusc := SA1->A1_NATUREZ

			Elseif !Empty(cNatPCC) .And. cNatPCC $ 'C5_NATUREZ' 
				If SC5->(FieldPos("C5_NATUREZ") > 0 ) .And. !Empty(SC5->C5_NATUREZ)	
					cNatBusc := SC5->C5_NATUREZ
				Endif

			Elseif !Empty(cNatPCC) .And. cNatPCC $ 'A1_NATUREZ'
				cNatBusc:= SA1->A1_NATUREZ

			Endif
		endif
	endif

	RestArea(aAreaSC5)
	RestArea(aAreaSD2)
	RestArea(aArea)

return cNatBusc


//-------------------------------------------------------------------
/*/{Protheus.doc} NoAcento
Retira acentos das strings

@author		Cleiton Genuino da Silva
@since		16.12.2016
/*/
//-------------------------------------------------------------------
Static Function NoAcento(cString)
	Local cChar  := ""
	Local nX     := 0 
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "�����"+"�����"
	Local cCircu := "�����"+"�����"
	Local cTrema := "�����"+"�����"
	Local cCrase := "�����"+"�����" 
	Local cTio   := "��"
	Local cTioMai:= "��"
	Local cCecid := "��"
	Local aCTag := {"&lt;","&gt;",">","<"}

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cTioMai
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("ao",nY,1))
			EndIf		
			nY:= At(cChar,cTioMai)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("AO",nY,1))
			EndIf

			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next

	For nX:= 1 To Len (aCTag)
		cString:= strTran( cString, aCTag[nX], "" ) 
	Next      

	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
	cString := _NoTags(cString)
Return cString


static Function cabecSoap(cServico,cXML)

	local cString := ""
	
	if "Cancelar" $ cServico
	cString += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cString += '<soap:Body>'
	cString += '<'+cServico+' xmlns="http://www.betha.com.br/e-nota-contribuinte-ws">'	
	cString += cXML
	cString += '</CancelarNfseEnvio>'
	cString += '</soap:Body>'
	cString += '</soap:Envelope>'
	
	else
	

	cString += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:e="http://www.betha.com.br/e-nota-contribuinte-ws" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">'
	cString += '<soapenv:Header/>'
	cString += '<soapenv:Body>'
	cString += '<e:'+cServico+'>'
	cString += cXML
	cString += '</e:'+cServico+'>'
	cString += '</soapenv:Body>'
	cString += '</soapenv:Envelope>'
EndIf
return cString









/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |GetCertificate     �Roberto Souza         � Data �11.11.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna os dados do certificado.                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TSS - Totvs Multimarcas                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GetCertificate(cFile,lHSM,cIdEnt)
	Local cCertificado := cFile
	Local nAT          := 0
	Local nRAT         := 0
	Local nHandle      := 0
	Local nBuffer      := 0

	If file(cfile)
		lDirCert  := .T.
		nHandle      := FOpen( cFile, 0 )
		nBuffer      := FSEEK(nHandle,0,FS_END)


		FSeek( nHandle, 0 )
		FRead( nHandle , cCertificado , nBuffer ) 
		FClose( nHandle ) 

		nAt := AT("BEGIN CERTIFICATE", cCertificado)
		If (nAt > 0)
			nAt := nAt + 22
			cCertificado := substr(cCertificado, nAt)
		EndIf
		nRat := AT("END CERTIFICATE", cCertificado)
		If (nRAt > 0)
			nRat := nRat - 6
			cCertificado := substr(cCertificado, 1, nRat)
		EndIf
		cCertificado := StrTran(cCertificado, Chr(13),"")
		cCertificado := StrTran(cCertificado, Chr(10),"")
		cCertificado := StrTran(cCertificado, Chr(13)+Chr(10),"")
	Else
		lDirCert  := .F.
		Conout("")
		Conout(cfile)
		Conout("Certificado nao encontrado no diretorio Certs - Realizar a configuracao do certificado para entidade "+cIdEnt+" !")
		Conout("")
	EndIf

Return(cCertificado)


Static Function GetIdEnt()
	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs
	//������������������������������������������������������������������������Ŀ
	//�Obtem o codigo da entidade                                              �
	//��������������������������������������������������������������������������
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf

	RestArea(aArea)
Return(cIdEnt)



Static Function SPEDNfeId(cXML,cAttId)
	Local nAt  := 0
	Local cURI := ""
	Local nSoma:= Len(cAttId)+2

	nAt := At(cAttId+'=',cXml)
	cURI:= SubStr(cXml,nAt+nSoma)
	nAt := At('"',cURI)
	If nAt == 0
		nAt := At("'",cURI)
	EndIf
	cURI:= SubStr(cURI,1,nAt-1)
Return(cUri)  



user Function BETACALL (cUrl,cAction ,cSoap)
Local cSoapSend := ""
local aHeadOut := {}
local __XMLHeadRet := ""
local __XMLPostRet := ""

aadd(aHeadOut,'SOAPAction: '+"")
aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8' )

// Acrescenta o UserAgent na requisi��o ...
aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+'; '+'ADVPL WSDL Client 1.090116'+')')

cSoapSend := ""
cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'
cSoapSend += cSoap


__XMLPostRet := Httppost(cUrl,"",cSoapSend,120,aHeadOut,@__XMLHeadRet)

return`




Static Function SignNFSeA1(cCodMun,cXML,cTag,cAttID,cIdEnt, cUso, cModelo,cPassword,cURI)

Local cXmlToSign  := ""
Local cDir        := IIf(IsSrvUnix(),"certs/", "certificados\NFE"+cEmpAnt+cFilAnt+"\certs\") //IIf(IsSrvUnix(),"certs/", "certs\")
Local cRootPath   := StrTran(GetSrvProfString("RootPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local cStartPath  := StrTran(cRootPath+IIf(!IsSrvUnix(),"\","/")+GetSrvProfString("StartPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local cArqXML     := Lower(CriaTrab(,.F.))
Local cMacro      := ""
Local cError      := ""
Local cWarning    := ""
Local cDigest     := ""
Local cSignature  := ""
Local cSignInfo   := ""
Local cIniXml     := ""
Local cFimXml     := ""
Local cNameSpace  := ""
Local cNewTag     := ""
Local nAt         := 0     
Local cTipoSig    := "1"
Local lForceName  := .F.

Default cURI      := ""

cPassCert   := Iif( !Empty(cPassword), Decode64(AllTrim(cPassword)),Decode64(AllTrim(SPED001->PASSCERT2)))

//cPassCert   := "1234"

cModelo   := Iif(Empty(cModelo),"001",cModelo)

cRootPath  := StrTran(cRootPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
cStartPath := StrTran(cStartPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
cStartPath := StrTran(cStartPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))

//������������������������������������������������������������������������Ŀ
//�Assina a NFSe                                                            �
//��������������������������������������������������������������������������
	If FindFunction("EVPPrivSign")
		
		If cModelo $ "001"
			//������������������������������������������������������������������������Ŀ
			//�Canoniza o XML                                                          �
			//��������������������������������������������������������������������������
			cXmlToSign := XmlC14N(cXml, "", @cError, @cWarning) 		

			If Empty(cError) .And. Empty(cWarning)
				//������������������������������������������������������������������������Ŀ
				//�Retira a Tag anterior a tag de assinatura                               �
				//��������������������������������������������������������������������������
				nAt := At("<"+cTag,cXmlToSign)
				If "Cancelamento" $ cUri
				cIniXML    := '<Pedido xmlns="">'					
				else
				cIniXML    := SubStr(cXmlToSign,1,nAt-1)
				EndIf
				
				cXmlToSign := SubStr(cXmlToSign,nAt)
				nAt := At("</"+cTag+">",cXmltoSign)
				cFimXML    := SubStr(cXmltoSign,nAt+Len(cTag)+3)
				cXmlToSign := SubStr(cXmlToSign,1,nAt+Len(cTag)+2)
				//������������������������������������������������������������������������Ŀ
				//�Descobre o namespace complementar da tag de assinatura                  �
				//��������������������������������������������������������������������������
				cNewTag := AllTrim(cIniXml)
				cNewTag := SubStr(cIniXml,2,At(" ",cIniXml)-2)
				cNameSpace := StrTran(cIniXml,"<"+cNewTag,"")
				cNameSpace := AllTrim(StrTran(cNameSpace,">",""))

				cNameSpace := ' xmlns:ns1="http://localhost:8080/WsNFe2/lote"'
				cNameSpace += ' xmlns:tipos="http://localhost:8080/WsNFe2/tp" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
                                                                                       
	            If ( cCodMun == "3550308" .or. cCodMun == "2611606" )
	            	cNameSpace := " "
	            EndIf 
				cDigest := StrTran(cXmlToSign,"<"+cTag+" ","<"+cTag +cNameSpace)
				//������������������������������������������������������������������������Ŀ
				//�Calcula o DigestValue da assinatura                                     �
				//��������������������������������������������������������������������������
				cDigest := XmlC14N(cDigest, "", @cError, @cWarning) 
		        cMacro  := "EVPDigest"

		        cDigest := Encode64(&cMacro.( cDigest , 3 ))

				//������������������������������������������������������������������������Ŀ
				//�Calcula o SignedInfo  da assinatura                                     �
				//��������������������������������������������������������������������������    
				lForceName	:= .T.
				
				cSignInfo := GetSignInfo(cUri,cDigest, cTipoSig, cNameSpace, cCodMun,lForceName)
				//������������������������������������������������������������������������Ŀ
				//�Assina o XML                                                            �
				//��������������������������������������������������������������������������
				cMacro     := "EVPPrivSign"

				cSignature := &cMacro.(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_key.pem" , XmlC14N(cSignInfo, "", @cError, @cWarning) , 3 , cPassCert , @cError)
				cSignature := Encode64(cSignature)
				//������������������������������������������������������������������������Ŀ
				//�Envelopa a assinatura                                                   �
				//��������������������������������������������������������������������������
				If cTipoSig =="1"
					cXmlToSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
					If ( cCodMun == "3550308" .or. cCodMun == "2611606" )
						cXmltoSign += cSignInfo
					Else
						cXmltoSign += StrTran(cSignInfo,cNameSpace,"")
					EndIf					
					cXmlToSign += '<SignatureValue>'+cSignature+'</SignatureValue>'
					cXmlToSign += '<KeyInfo>'
					cXmlToSign += '<X509Data>'
					cXmlToSign += '<X509Certificate>'+GetCertificate(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_cert.pem",.F.,cIdEnt)+'</X509Certificate>'
					cXmlToSign += '</X509Data>'
					cXmlToSign += '</KeyInfo>'
					cXmlToSign += '</Signature>'
					                         
					cXmlToSign := cIniXML+cXmlToSign+cFimXML
					                                                  
//					cXmlToSign := StrTran(cXmlToSign,"</"+cTag+">","")
//					cXmlToSign := cXmlToSign + "</"+cTag+">"

                ElseIf cTipoSig =="2"
					cXmlToSign += '<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'
					cXmltoSign += cSignInfo
					cXmlToSign += '<ds:SignatureValue>'+cSignature+'</ds:SignatureValue>'
					cXmltoSign += '<ds:KeyInfo>'
					cXmltoSign += '<ds:X509Data>'
					cXmltoSign += '<ds:X509Certificate>'+GetCertificate(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_cert.pem",.F.,cIdEnt)+'</ds:X509Certificate>'
					cXmltoSign += '</ds:X509Data>'
					cXmltoSign += '</ds:KeyInfo>'
					cXmltoSign += '</ds:Signature>'
					                         
					cXmlToSign := cIniXML+cXmlToSign+cFimXML
					
//					cXmlToSign := StrTran(cXmlToSign,"</"+cTag+">","")
//					cXmlToSign := cXmlToSign + "</"+cTag+">"
				EndIf
				If ( cCodMun == "3550308" .or. cCodMun == "2611606" )
					cXmlToSign := StrTran(cXmlToSign,"</"+cTag+">","")
					cXmlToSign := cXmlToSign+"</"+cTag+">"  
				EndIf				
			Else
				cXmlToSign := cXml
				ConOut("Sign Error thread: "+cError+"/"+cWarning)
			EndIf

		ElseIf cModelo $ "002" .Or. cCodMun == "9999999".Or. cCodMun == "2408102"
		
			//������������������������������������������������������������������������Ŀ
			//�Obtenho a URI                                                           �
			//��������������������������������������������������������������������������
			cUri := SpedNfeId(cXML,cAttId)

			//������������������������������������������������������������������������Ŀ
			//�Canoniza o XML                                                          �
			//��������������������������������������������������������������������������
			cXmlToSign := XmlC14N(cXml, "", @cError, @cWarning) 		
			//�������������������������������������������������������������Ŀ
			//�Tratamento para troca de caracter referente ao xml da ANFAVEA�
			//���������������������������������������������������������������
			cXmlToSign := (StrTran(cXmlToSign,"&lt;/","</"))
			cXmlToSign = (StrTran(cXmlToSign,"/&gt;","/>"))  
			cXmlToSign = (StrTran(cXmlToSign,"&lt;","<"))  
			cXmlToSign = (StrTran(cXmlToSign,"&gt;",">"))  
			cXmlToSign = (StrTran(cXmlToSign,"<![CDATA[[ ","<![CDATA["))  

	
			If Empty(cError) .And. Empty(cWarning)
				//������������������������������������������������������������������������Ŀ
				//�Retira a Tag anterior a tag de assinatura                               �
				//��������������������������������������������������������������������������
				nAt := At("<"+cTag,cXmlToSign)
				cIniXML    := SubStr(cXmlToSign,1,nAt-1)
				cXmlToSign := SubStr(cXmlToSign,nAt)
				nAt := At("</"+cTag+">",cXmltoSign)
				cFimXML    := SubStr(cXmltoSign,nAt+Len(cTag)+3)
				cXmlToSign := SubStr(cXmlToSign,1,nAt+Len(cTag)+2)
				//������������������������������������������������������������������������Ŀ
				//�Descobre o namespace complementar da tag de assinatura                  �
				//��������������������������������������������������������������������������
				cNewTag := AllTrim(cIniXml)
				cNewTag := SubStr(cIniXml,2,At(" ",cIniXml)-2)
				cNameSpace := StrTran(cIniXml,"<"+cNewTag,"")
				cNameSpace := AllTrim(StrTran(cNameSpace,">",""))
				nAtver := At("versao",cNameSpace) // Pode ter um atributo versao Ex. ( xmlns="http://" versao="1.01")
				If nAtver > 0
					cNameSpace := SubStr(cNameSpace, 1, nAtver-1) // -2 por causa do espaco
					cNameSpace := RTrim(cNameSpace)
				Endif
				//������������������������������������������������������������������������Ŀ
				//�Calcula o DigestValue da assinatura                                     �
				//��������������������������������������������������������������������������
				If cCodMun $ "3547809-3115300-2704302-2507507-2304400-3543402-3513009-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-3548708-3513801-3525904-4100400"	// Ginfes
					cDigest := StrTran(cXmlToSign,"<"+cTag+" ","<"+cTag +" ")
				Else
					cDigest := StrTran(cXmlToSign,"<"+cTag+" ","<"+cTag +" "+cNameSpace+" ")		        
		        EndIF				
		         cDigest := XmlC14N(cDigest, "", @cError, @cWarning) 
		         cMacro  := "EVPDigest"
		         cDigest := Encode64(&cMacro.( cDigest , 3 ))
				//������������������������������������������������������������������������Ŀ
				//�Calcula o SignedInfo  da assinatura                                     �
				//��������������������������������������������������������������������������
				If cCodMun $ "3547809-3115300-2704302-2507507-2304400-3543402-3513009-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-3548708-3513801-3525904" //Ginfes
					Do Case
						Case  '</EnviarLoteRpsEnvio>' $ cXmlToSign
							If cCodMun $ "2704302-2507507-2304400-3513009" 	//Maceio,Joao Pessoa, Fortaleza
								cNameSpace:=' xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd"'
							Else
								cNameSpace:=' xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd"'
							Endif
						Case '</ConsultarLoteRpsEnvio>' $ cXmlToSign  .Or. '</ConsultarNfseRpsEnvio>' $ cXmlToSign .Or. '</ConsultarNfseEnvio>' $ cXmlToSign
							cNameSpace:=' xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:n2="http://www.altova.com/samplexml/other-namespace" xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
						Case '</tns:CancelarNfseEnvio>' $ cXmlToSign 
							cNameSpace:=' xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:n1="http://www.altova.com/samplexml/other-namespace" xmlns:tipos="http://www.ginfes.com.br/tipos" xmlns:tns="http://www.ginfes.com.br/servico_cancelar_nfse_envio" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
					EndCase
				ElseIF cCodMun $ "3534401" // SP-OSASCO
					cNameSpace:=' xmlns="http://www.w3.org/2000/09/xmldsig#"' 		
				EndIf
				cSignInfo := NfseSigInf(cUri,cDigest,cTipoSig,cNameSpace,cCodMun)
				cSignInfo := XmlC14N(cSignInfo, "", @cError, @cWarning) 
				//������������������������������������������������������������������������Ŀ
				//�Assina o XML                                                            �
				//��������������������������������������������������������������������������
				If SpedGetMv("MV_HSM",cIdEnt)=="0"
					cMacro   := "EVPPrivSign"
					cSignature := &cMacro.(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_key.pem" , cSignInfo , 3 , cPassCert , @cError)
				Else
					If GetBuild() >= '7.00.081215P-20090626'
						cMacro   := "HSMPrivSign"
						cSignature := &cMacro.("slot_"+SpedGetMv("MV_HSMSLOT",cIdEnt)+"-label_"+SpedGetMv("MV_KEYLABE",cIdEnt), cSignInfo , 3 , @cError, cPassCert)
					Else
						cMacro   := "HSMPrivSign"
						cSignature := &cMacro.("slot_"+SpedGetMv("MV_HSMSLOT",cIdEnt)+"-label_"+SpedGetMv("MV_KEYLABE",cIdEnt), cSignInfo , 3 , @cError)				
					EndIf
				EndIf
				If cCodMun $ "3547809-3115300-3543402-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-3548708-3513801-3525904"
					If '</tns:CancelarNfseEnvio>' $ cXmlToSign
						cDsig := "ds:"
					Else
						cDsig := "dsig:"
					EndIF
				Else
					cDsig := ""
				EndIf			
				cSignature := Encode64(cSignature)
				//������������������������������������������������������������������������Ŀ
				//�Envelopa a assinatura                                                   �
				//��������������������������������������������������������������������������
				cNewFunc := "PemInfo"
				aInfo := &cNewFunc.(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_cert.pem",cPassCert)

				cXmlToSign += '<'+cDsig+'Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
				cXmltoSign += cSignInfo
				cXmlToSign += '<SignatureValue>'+cSignature+'</SignatureValue>'
				If !(cCodMun $ "3534401") // SP-OSASCO
					cXmltoSign += '<KeyInfo>'
					cXmltoSign += '<X509Data>'
					If !(cCodMun $ "3547809-3304557-3115300-3106200-3501608-2704302-2507507-2304400-3543402-3513009-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-3302403-3302007-3300407-3301702-5201108-3548708-3513801-3525904-4104808-2408102-4100400-3118601") //Ginfes
						cXmltoSign += '<X509SubjectName>'+aInfo[1][2]+'</X509SubjectName>' 
	    			EndIf
					cXmltoSign += '<X509Certificate>'+GetCertificate(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_cert.pem",SpedGetMv("MV_HSM",cIdEnt)=="1",cIdEnt)+'</X509Certificate>'
					cXmltoSign += '</X509Data>'  
	                                               
					/*SP-Americana, MG-Belo Horizonte, RJ-Rio de Janeiro, RJ-Macae, RJ-Itaguai, RJ-Barra Mansa, RJ-Duque de Caxias, RN-Natal*/
					If !(cCodMun $ "3304557-3106200-3501608-3302403-3302007-3300407-3301702-2408102")
						cNewFunc  := "RSAModulus"
						cModulus  := &cNewFunc.(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_key.pem",.F.,cPassCert)
		
				   		cNewFunc  := "RSAExponent"
						cExponent := &cNewFunc.(IIf(IsSrvUnix(),"/", "\")+cDir+cUso+cIdEnt+"_key.pem",.F.,cPassCert)
	
						If !cCodMun $ "3547809-3115300-2704302-2507507-2304400-3543402-3513009-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-5201108-3548708-3513801-3525904-4104808-4100400" //Ginfes
						cXmltoSign += '<KeyValue>'
						cXmltoSign += '<RSAKeyValue>'
						cXmltoSign += '<Modulus>'+Encode64(cModulus)+'</Modulus>' 
						cXmltoSign += '<Exponent>'+Encode64(cExponent)+'</Exponent>' 
						cXmltoSign += '</RSAKeyValue>'
						cXmltoSign += '</KeyValue>'
						EndIf
					Endif				
					cXmltoSign += '</KeyInfo>'
				EndIf
				cXmltoSign += '</'+cDsig+'Signature>'				
				
				If cCodMun $ "3547809-3115300-2704302-2507507-2304400-3543402-3513009-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-3548708-3513801-3525904" //Ginfes - Acerto XML no Final para bater o Digest
					Do Case
						Case '</EnviarLoteRpsEnvio>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</EnviarLoteRpsEnvio>","")
							cFimXml:= "</EnviarLoteRpsEnvio>"
						Case '</ConsultarLoteRpsEnvio>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</ConsultarLoteRpsEnvio>","")
							cFimXml:= "</ConsultarLoteRpsEnvio>"
						Case '</ConsultarNfseRpsEnvio>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</ConsultarNfseRpsEnvio>","")
							cFimXml:= "</ConsultarNfseRpsEnvio>"	
						Case '</ConsultarNfseEnvio>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</ConsultarNfseEnvio>","")
							cFimXml:= "</ConsultarNfseEnvio>"		
						Case '</tns:CancelarNfseEnvio>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</tns:CancelarNfseEnvio>","")
							cFimXml:= "</tns:CancelarNfseEnvio>"								
				    EndCase		
				ElseIf cCodMun $ "3534401" // SP-OSASCO 
					Do Case
						Case '</credenciaisDeAcesso>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</credenciaisDeAcesso>","")
							cFimXml:= "</credenciaisDeAcesso>"
						Case '</notaFiscal>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</notaFiscal>","")
							cFimXml:= "</notaFiscal>"						
						Case '</notaFiscalCancelamento>' $ cXmltoSign
							cXmltoSign:= StrTran(cXmltoSign,"</notaFiscalCancelamento>","")
							cFimXml:= "</notaFiscalCancelamento>"						
				    EndCase   
				EndIf
				
				cXmlToSign := cIniXML+cXmlToSign+cFimXML
			Else
				cXmlToSign := cXml
				ConOut("Sign Error thread: "+cError+"/"+cWarning)
		    EndIf
		Else
			ConOut("Falha ao tentar assinar NFSE.","Modelo n�o homologado.")
		EndIf
				
	Else
		cXmlToSign := "Falha"	
		ConOut("Falha ao tentar assinar NFSE.","Necessario Build " + GetBuild() + " ou superior.")	
	EndIf

Return(cXmlToSign)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |GetSignInfo| Autor �Roberto Souza         � Data �11.11.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera o envelopamento da tag SignedInfo para a assinatura.   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TSS - Totvs Multimarcas                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GetSignInfo(cUri,cDigest, cTipoSig,cNameSpace,cCodMun,lForceGet)
Local cSignedInfo	:= ""  
Local nOperation	:= setOperation() 

DEFAULT cTipoSig 	:= "2" 
DEFAULT cNameSpace 	:= ""      
DEFAULT lForceGet	:= .T.

If ( Empty(cNameSpace) .or. lForceGet )
	cNameSpace	:= getSignNameSpc( cCodMun, cNameSpace )
EndIf

If cTipoSig =="1"
	if  !( "Cancelamento" $ cUri )
	cSignedInfo += '<SignedInfo '+cNameSpace+'>'
	else
	cSignedInfo += '<SignedInfo>'
	EndIf	  
	cSignedInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
	cSignedInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
	If Empty(cUri)
		cSignedInfo += '<Reference URI="'+ cUri +'">'
	Elseif !Empty(cUri) .and. !( "Cancelamento" $ cUri) 
		cSignedInfo += '<Reference URI="#lote:'+ cUri +'">'
	else
		cSignedInfo += '<Reference URI="#'+ cUri +'">'
	EndIf
	cSignedInfo += '<Transforms>'
	cSignedInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
	//If ( !(cCodMun $ "3550308|2611606") .or. ( cCodMun $ "3550308|2611606" .And. nOperation == CANCELAR ) )
	//	cSignedInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />'
	//EndIf
	cSignedInfo += '</Transforms>'
	cSignedInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
	cSignedInfo += '<DigestValue>' + cDigest + '</DigestValue>'
	cSignedInfo += '</Reference>'
	cSignedInfo += '</SignedInfo>'


ElseIf cTipoSig=="2"                                

	cSignedInfo += '<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'
	cSignedInfo += '<ds:CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></ds:CanonicalizationMethod>'
	cSignedInfo += '<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>'
	If Empty(cUri)
		cSignedInfo += '<ds:Reference URI="'+ cUri +'">'
	Else
		cSignedInfo += '<ds:Reference URI="#lote:'+ cUri +'">'
	EndIf
	cSignedInfo += '<ds:Transforms>'
	cSignedInfo += '<ds:Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116">'
	cSignedInfo += '<ds:XPath>not(ancestor-or-self::ds:Signature)</ds:XPath>'
	cSignedInfo += '</ds:Transform>'
	cSignedInfo += '<ds:Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments"></ds:Transform>'
	cSignedInfo += '</ds:Transforms>'
	cSignedInfo += '<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>'
	cSignedInfo += '<ds:DigestValue>' + cDigest + '</ds:DigestValue>'
	cSignedInfo += '</ds:Reference>' 
	cSignedInfo += '</ds:SignedInfo>'
EndIf
	
Return(cSignedInfo)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |NfseSigInf| Autor  �Roberto Souza         � Data �11.11.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera o envelopamento da tag SignedInfo para a assinatura.   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TSS - Totvs Multimarcas                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function NfseSigInf(cUri,cDigest,cTipoSig,cNameSpace,cCodMun)
Local cSignedInfo := ""
Do Case  

	Case cCodMun $ "3547809-3115300-2704302-2507507-2304400-3543402-3513009-2604106-3518800-3548500-3524709-3549805-3503208-3516200-3154606-4125506-3534401-3548708-3513801-3525904" // Ginfes e Osasco
		cSignedInfo += '<SignedInfo'+cNameSpace+'>'
		cSignedInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>' 
		cSignedInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>' 
		cSignedInfo += '<Reference URI="">'
		cSignedInfo += '<Transforms>'
		cSignedInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>' 
		cSignedInfo += '</Transforms>'
		cSignedInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
		cSignedInfo += '<DigestValue>' + cDigest + '</DigestValue>'
		cSignedInfo += '</Reference>'
		cSignedInfo += '</SignedInfo>'
		
	OtherWise
	
		cSignedInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
		cSignedInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>'
		cSignedInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>'
		cSignedInfo += '<Reference URI="#'+ cUri +'">'
		cSignedInfo += '<Transforms>'
		cSignedInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>'
		cSignedInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform>'
		cSignedInfo += '</Transforms>'
		cSignedInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>'
		cSignedInfo += '<DigestValue>' + cDigest + '</DigestValue></Reference></SignedInfo>' 
			
EndCase
Return(cSignedInfo)


//-------------------------------------------------------------------
/*/{Protheus.doc} setOperation
Fun��o para atribuir a opera��o que esta sendo executada pelo JOB.

@author Henrique de Souza Brugugnoli
@since 24/06/2010
@version 1.0 

@param	nOperation	Opera��o que esta sendo executada de acordo com
					o conte�do:
					CONSULTAR -> 1
					CANCELAR  -> 2
					ENVIAR 	  -> 3

@return	__nOperation	Opera��o que foi atribu�da
/*/
//-------------------------------------------------------------------

Static Function setOperation( nOperation )

DEFAULT nOperation	:= 0   
 
/*Verifica se a mesma opera��o ja foi atribuida e se � v�lida*/
If ( nOperation <> __nOperation .And. nOperation <> 0 )
	__nOperation	:= nOperation
EndIf

Return __nOperation


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSignNameSpc
Retorna o namespace para o SignInfo de acordo com a opera��o que esta 
esta sendo executada (Consulta, Cancelamento ou Envio) e o munic�pio.

@author Henrique de Souza Brugugnoli
@since 24/06/2010
@version 1.0 

@param	cCodMun		C�digo do munic�pio 
		cNameSpace  Namespace ja existente

@return	cReturn	Namespace espec�fico por opera��o e munic�pio
/*/
//-------------------------------------------------------------------

Static Function getSignNameSpc( cCodMun, cNSpace )
       
Local cNameSpace	:= "" 

Local nOperation	:= setOperation()   

If ( nOperation == CONSULTAR )
	/*S�o Paulo*/
	If ( cCodMun == "3550308" ) 
		cNameSpace := 'xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:p1="http://www.prefeitura.sp.gov.br/nfe" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	
	/*Recife*/
	ElseIf ( cCodMun == "2611606" )  
		cNameSpace := 'xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:p1="http://www.recife.pe.gov.br/nfe" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	EndIf   
	
ElseIf ( nOperation == CANCELAR )
	/*S�o Paulo, Recife*/
	If ( cCodMun == "3550308" .or. cCodMun == "2611606" ) 
		cNameSpace := 'xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	EndIf
ElseIf ( nOperation == ENVIAR ) 
	/*S�o Paulo, Recife*/
	If ( cCodMun == "3550308" .or. cCodMun == "2611606" ) 
		cNameSpace := 'xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'	
	EndIf
EndIf 

If ( Empty(cNameSpace) )
	cNameSpace := 'xmlns="http://www.w3.org/2000/09/xmldsig#"'	
EndIf

cReturn := cNameSpace + cNSpace

Return cReturn  

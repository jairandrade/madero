#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "totvs.ch"

//-------------------------------------------------
/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada para customizacoes no xml da nota fiscal eletronica.

@type function
@version 9.0
@author Rodrigo Slisisnski

@since 13/02/15

@history 20/10/2018, Andre/rsac, Vers�o 2.0 > Fonte adequado
@history 04/12/2018, Andre/rsac, Vers�o 3.0 > Fonte adequado
@history 14/12/2020, Lucas@AlmaSge, Vers�o 4.0 > Adequa��o do fonte atual com o D:\TOTVS\PROJETO\CONSULTORES\CMAXTI_MARCOS\Projeto\05-FATURAMENTO\NFE\PE01NFESEFAZ.prw
@history 16/12/2020, Lucas@AlmaSge, Vers�o 5.0 > Ajustado processamento de convers�o de unidades de medida na gera��o do XML.
@history 06/01/2020, Lucas@AlmaSge, Vers�o 6.0 > Realizando a convers�o dentro da rotina.
@history 07/01/2020, Lucas@AlmaSge, Vers�o 7.0 > Ajustado o c�lculo levando em considera��o o reposisionamento da SB1 na convers�o da unidade de medida
@history 07/01/2020, Lucas@AlmaSge, Vers�o 8.0 > Ajuste na troca de unidade de medida, onde a quantidade para determinadas segundas unidades n�o deve ser com valores decimais. Exemplo: Caixa e Pe�as.
@history 07/01/2020, Lucas@AlmaSge, Vers�o 9.0 > Ajuste para contemplar duas regras de processamento na convers�o, uma para quando for M2 e outra para quando n�o � M2.
/*/
//-------------------------------------------------
User Function PE01NFESEFAZ()

	Local aDupl		 := PARAMIXB[7]  
	Local nDupli     := Len(aDupl)
	Local aInfItem   := PARAMIXB[6]
	Local cCRLF		 := CRLF
	local cCodbarSA7 := ""  
	local XI
	local _nI

	Private aRet 	 := paramixb
	Private cmenscli :=" "

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))

	dbSelectArea('SC6')
	SC6->(DBSetOrder(1))

	dbselectArea('SA7')
	SA7->(DBSetOrder(1))

	dbselectArea('SB1')
	SB1->(DBSetOrder(1))

	aPrd := paramixb[1]
	aD2  := paramixb[6]
	cmenscli := paramixb[2]

	If (Alltrim((paramixb[5][4])) == '1')
		
		SC5->(DbGoTop())
		If SC5->(DbSeek(xFilial("SC5")+aInfItem[1,1]))

			If (Alltrim(SC5->C5_K_OPER) == '31' .And. Alltrim(SC5->C5_CLIENTE) == '039138' .And. Alltrim(SC5->C5_LOJACLI) == '01') //Madeira madeira - NF simbolica
				If cEmpAnt	== "04"
					aRet[2] := ""
					aRet[2]	+= RetCHVCl("04")
					Conout("NF Madeira Madeira empresa 04")

				ElseIf cEmpAnt	== "01"
					aRet[2] := ""
					aRet[2]	+= RetCHVCl("01")
					Conout("NF Madeira Madeira empresa 01")

				Else	
					Conout("NF Madeira Madeira empresa nao localizada")
					aRet[2] := ""
				EndIf
			EndIf	

		EndIf

		For XI := 1 TO Len(aPrd)

			SC5->(DbGoTop())
			if SC5->(DbSeek(xFilial('SC5')+aD2[xi][1]))

				nmoeda := SC5->C5_MOEDA

				cMenAux:=" PV:"+SC5->C5_NUM
				if !(Alltrim(cMenAux) $ aRet[2])
					aRet[2] := cMenAux + ' ' + aRet[2]
				EndIF

				cmen := SC5->C5_MSGNOTA
				nTam := MlCount(cmen,80)
				cmenscli += " "
				cMensAux := ''

				for _nI := 1 to nTam
					cMensAux+=MemoLine(cmen, 81, _nI, 3)   //antes 117
				next _nI

				if !(Alltrim(cMensAux) $ aRet[2])
					//	cmenscli+=cMensAux
					aRet[2] += alltrim(cMensAux)
				EndIF

				SC6->(DbGoTop())
				if SC6->(DbSeek(xFilial('SC6') + aD2[xi, 1] + aD2[xi, 2] + aPrd[xi, 2]))
					SB1->(dbGoTop())
					if SB1->(dbSeek( FwXFilial('SB1') + SC6->C6_PRODUTO ))

						/*ALTERADO POR RODRIGO PARA BUSCAR CODIGO E DESCRICAO DO PRODUTO X CLIENTE*/
						//A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO				
						cCodbarSA7 := ""
						SA7->(dbGoTop())
						if SA7->(DBSeek(xFilial('SA7')+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO))
							IF !Empty(SA7->A7_CODCLI)
								cProdCli    := SA7->A7_CODCLI
								aPrd[XI, 2] := cProdCli
							EndIF

							IF !Empty(SA7->A7_DESCCLI)
								cDesCli     := SA7->A7_DESCCLI
								aPrd[XI, 4] := cDesCli
							EndIF

							// 19.10.2018 
							cCodbarSA7 := SA7->A7_CODBAR
						EndIF

						//19.10.2018 
						if !empty(cCodbarSA7)
							aPrd[XI, 03] := cCodbarSA7
							aPrd[XI, 46] := cCodbarSA7
						endif

						if  empty(cCodbarSA7) .and. !empty(SB1->B1_CODBAR)
							aPrd[XI, 03] := SB1->B1_CODBAR
						endif

						if (SC6->C6_K_TPFAT == "2") // trata para a segunda unidade de medida
							
							if ( !Empty( SC6->C6_SEGUM ) )
								if ( alltrim(SC6->C6_UM) == 'M2' )
									nQtd     := SC6->C6_XQTDPC // quantidade da nota
									nValUnit := aPrd[XI, 10]
									nValTot  := ROUND((aPrd[XI, 10] * SC6->C6_XQTDPC) / SC6->C6_XQTDPC, 4)
								else
									// se n�o for metro quadrado, o sistema deve realizar a convers�o
									nQtd := ConvUm( SB1->B1_COD, aPrd[XI, 09], 0, 2 )

									if ((nqtd - int(nqtd)) > 0)
										nQtd := int(nQtd) + 1
									endif

									nValUnit := round(aPrd[XI, 10] / nQtd, 4)
									nValTot  := aPrd[XI, 10]
								endif								

								aPrd[XI, 08] := SC6->C6_SEGUM  
								aPrd[XI, 09] := nQtd
								aPrd[XI, 10] := nValTot
								aPrd[XI, 11] := SC6->C6_SEGUM 
								aPrd[XI, 12] := nQtd 
								aPrd[XI, 16] := nValUnit
							endif
						endif
					endif
				endif
			endif
		Next

		aRet[1] := aPrd
		aRet[2] += " Os itens desta nota deverao ser conferidos no recebimento e qualquer divergencia fazer a ressalva no"
		aRet[2] += " conhecimento da transportadora e comunicar imediatamente o sac 41 2106 0907."

		If (cEmpAnt == '04')
			If  Alltrim(SF2->F2_XPVSPP) == 'S'
				aRet[2] += " "+cCRLF
				If (nDupli > 1)
					aRet[2] += " Compra efetuada atrav�s do KapaziCRED em "+cValTochar(nDupli)+" parcelas. Central de Atendimento KapaziCRED 0300 601 4059. "
				Else
					aRet[2] += " Compra efetuada atrav�s do KapaziCRED em "+cValTochar(nDupli)+" parcela. Central de Atendimento KapaziCRED 0300 601 4059. "
				EndIf
			Else
				aRet[2] += " Os vencimentos dos boletos deverao ser acompanhados atraves da nota fiscal, no caso do nao recebimento dos boletos, favor direcionar-se"
				aRet[2] += " ao nosso site WWW.KAPAZI.COM.BR 2 VIA DE BOLETO ou pelos Tel 41 2106 0948 /0996 /0933 /0964."
			EndIf
		Else
			aRet[2] += " Os vencimentos dos boletos deverao ser acompanhados atraves da nota fiscal, no caso do nao recebimento dos boletos, favor direcionar-se"
			aRet[2] += " ao nosso site WWW.KAPAZI.COM.BR 2 VIA DE BOLETO ou pelos Tel 41 2106 0948 /0996 /0933 /0964."
		EndIf
		aRet[2]	:= FwNoAccent(aRet[2])

	EndIf //Fim do If se � NF de sa�da

	aRet[2]	:= cRetKAP(aRet[2])

	// ---------------------------------------------------
	// INTREGRACAOO MADEIRAMADEIRA -- golive
	// ---------------------------------------------------
	If ExistBlock("M050202")
		cAutXml := U_M050202(SF2->F2_DOC,SF2->F2_SERIE)
	Endif

Return aRet

//-------------------------------------------------
/*/{Protheus.doc} RetCHVCl
Retorna as informa��es da chave do cliente - NF de Remessa
Devendo essa chave ser vinculada a chave simbolica da madeira madeira

@author Desconhecido
@type function
@version 1.0

@param cEmpAtK, character, Empresa

@return Character, chave do cliente

@since 
/*/
//-------------------------------------------------
Static Function RetCHVCl(cEmpAtK)
	
	Local cRet		:= ""
	Local cQry		:= ""
	Local cAliasZM  := ''
	Local nRegs 	:= 0

	If Select("cAliasZM") <> 0
		DBSelectArea("cAliasZM")
		cAliasZM->(DBCloseArea())
	Endif

	cAliasZM := GetNextAlias()

	cQry += " SELECT Z00_NUMPV AS PVMADEIR,Z00_NUMPV2 AS PVCLIENT,SC5.C5_NUM,SC5.C5_NOTA,SC5.C5_SERIE,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CHVNFE "

	If (cEmpAtK == "04")
		cQry	+= " FROM Z00040 Z00 "
		cQry	+= " INNER JOIN SC5040 AS SC5 ON Z00.Z00_FILIAL  = SC5.C5_FILIAL AND Z00.Z00_NUMPV2 = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
		cQry	+= " INNER JOIN SF2040 AS SF2 ON Z00.Z00_FILIAL  = SF2.F2_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_='' "

	ElseIf (cEmpAtK == "01")
		cQry	+= " FROM Z00010 Z00 "
		cQry	+= " INNER JOIN SC5010 AS SC5 ON Z00.Z00_FILIAL  = SC5.C5_FILIAL AND Z00.Z00_NUMPV2 = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
		cQry	+= " INNER JOIN SF2010 AS SF2 ON Z00.Z00_FILIAL  = SF2.F2_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_='' "
	EndIf
	cQry	+= " WHERE	Z00.D_E_L_E_T_='' "
	cQry	+= "		AND Z00.Z00_NUMPV = '"+SC5->C5_NUM+"' "


	TcQuery cQry new Alias "cAliasZM"
	Count to nRegs
	cAliasZM->(DbGoTop())

	If (nRegs > 0)
		cRet += "NF Remessa: "+cAliasZM->F2_CHVNFE + " - "
	EndIf

	cAliasZM->(DbCloseArea())

Return(cRet)

//-------------------------------------------------
/*/{Protheus.doc} cRetKAP
Trata caracter especial

@author Desconhecido
@type function
@version 1.0

@param cObjecto, character, Texto para tratamento

@return Character, texto com tratamento

@since 
/*/
//-------------------------------------------------
Static Function cRetKAP(cObjecto)

	Local cStrKAPA	:= cObjecto

	cStrKAPA := StrTran(cStrKAPA, 'n�', 'n')
	cStrKAPA := StrTran(cStrKAPA, '�', '')
	cStrKAPA := StrTran(cStrKAPA, '�', '')
	cStrKAPA := StrTran(cStrKAPA, '�', ' ')//-
	//cStrProa := StrTran(cStrProa, '-', '')

Return(cStrKAPA)

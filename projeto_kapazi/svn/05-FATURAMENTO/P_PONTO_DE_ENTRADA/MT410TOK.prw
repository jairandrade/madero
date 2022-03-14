#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#INCLUDE "rwmake.ch"
/**********************************************************************************************************************************/
/** FATURAMENTO                                                                                                                  **/
/** Cadastro - Grupo de Vendas	                                                                                                 **/
/** RSAC Solu��es Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      **/
/**********************************************************************************************************************************/
/** 13/08/2015 | Marcos Sulivan          | Cria��o da rotina/procedimento.                                                       **/
/**********************************************************************************************************************************/
User Function MT410TOK()
Local aArea 		:= GetArea()
Local aAreaC5		:= SC5->(GetArea())
Local aAreaC6		:= SC6->(GetArea())
Local aAreaC9		:= SC9->(GetArea())

Local lRet			:= .T.
Local cCodUser		:= RetCodUsr() //Retorno do cod do usuario
Local cAlias1		:= GetNextAlias()
Local cAlias2		:= GetNextAlias()
Local cAlias3		:= GetNextAlias()
Local cQryVC		:= " "
Local cQryUV		:= " "
Local cQryIT		:= " "
Local cRet			:= " "
Local cVnd1A		:= " "
Local cVnd1B		:= " "
Local cVnd1C		:= " "
Local cVndCli		:= " "
Local cVndCGC		:= " "
Local nOpc			:= PARAMIXB[1]	// Opcao de manutencao -> N�mero referente a op��o de manuten��o que est� sendo utilizada. Ex: 2-Visualiza��o, 3-Inclus�o, 4-Altera��o
Local lJustif		:= StaticCall(M521CART,TGetMv,"  ","KA_PEDJUST","L",.T.,"MT410TOK - Obriga o usuario a informar justificativa na altera��o do pedido de venda?" )
Local lNewOper		:= StaticCall(M521CART,TGetMv,"  ","KA_PEDOPER","L",.T.,"MT410TOK - Ativa a nova forma de atualizar a operacao/tes/cfop no item do pedido?" )
Local lTpFat		:= StaticCall(M521CART,TGetMv,"  ","KA_PEDTPFA","L",.T.,"MT410TOK - Ativa a rotina que altera o campo C6_K_TPFAT de acordo com a unidade de medida do produto" )
Local lReservar		:= GetMv("KA_RESATV",,.F.)
Local cFilSA1		:= ""
Local cUsrLBa		:= SuperGetMv("KP_CDUSALT",.F.,"000494") 
Local _nAz 			:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})
Local _nPr 			:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local _cPrdAmzE		:= ""

If Type("l410Auto") == "U"
	l410Auto := .F.
endif

If Alltrim(M->C5_XTIPONF) == '2' //tipo de nf que sera gerada -> servico
	RestArea(aArea)
	Return	.T.
EndIf

If cEmpAnt == "04" .And. cFilAnt == "08" .And. Alltrim(M->C5_CLIENTE) == "007484" .And. Alltrim(M->C5_LOJACLI) == "20" //Cliente 0401
	RestArea(aArea)
	Return	.T.
EndIf 

If cEmpAnt == "04" .And. cFilAnt == "01" .And. Alltrim(M->C5_CLIENTE) == "092693" .And. Alltrim(M->C5_LOJACLI) == "01" //Cliente 0408
	RestArea(aArea)
	Return	.T.
EndIf

If cEmpAnt == "04" .And. (nOpc == 3 .or. nOpc == 4) .And. Alltrim(M->C5_TIPO) == "N" .And. !(__cUserId $ cUsrLBa) //.And. !l410Auto

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek( xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI))

		cFilSA1	:= Alltrim(SA1->A1_XFILFAT)

		If Alltrim(SA1->A1_PESSOA) == "F" .And. cFilAnt == "08"
			MsgAlert("Nao � permitido lancar PV de pessoa fisica no CD","Kapazi")
			Return .F.
		EndIf 

		If Alltrim(SA1->A1_PESSOA) == "J"
			If Alltrim(cFilSA1) == "08" .And. cFilAnt == "01"
				MsgAlert("Este cliente PJ TEM sua parametrizacao para faturar pelo CD (verifique o campo Filial Fatur(aba outros) no cadastro de clientes )","Kapazi")
				Return .F.
			EndIf

			If Alltrim(cFilSA1) == "01" .And. cFilAnt == "08"
				MsgAlert("Este cliente PJ NAO TEM sua parametrizacao para faturar pelo CD (verifique o campo Filial Fatur(aba outros) no cadastro de clientes )","Kapazi")
				Return .F.
			EndIf

		EndIf 

	EndIf

	If Alltrim(M->C5_XGERASV) == "S" .And.  cFilAnt == "08"
		MsgAlert("Nao � permitida NFMISTA no CD","Kapazi")
		Return .F.
	EndIf

EndIf

If (Alltrim(M->C5_PVINTAN) == 'S' .And. Alltrim(M->C5_XGERASV) == 'S') .And. !l410Auto .And. nOpc == 3  //( nOpc == 3 .or. nOpc == 4 )
	MsgStop("O pedido de venda n�o pode ser intangivel e NF Mista. Por favor, verifique o campo (Pv.Intang?) e (Gera Sv?)")
	Return .F.
EndIf
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Data: 02/04/2017                                                                                                                       |
| Descricao: Bloquear a confirma��o de Pedidos de Venda quando o usuario que est� digitando n�o estiver vinculado ao Cliente e Vendedor  |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
If ( nOpc == 3 .or. nOpc == 4 )

	// If cCodUser $ GetMV("KP_VENINTE") .OR. cCodUser $ GetMV("KP_VENINT2")
	If StaticCall(M415FSQL,PodeVerTodosPedidos)

		cVndCli := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_VEND")
		cVndCGC	:= POSICIONE("SA3",1,XFILIAL("SA3") + cVndCli,"A3_CGC")

		If !Empty(cVndCGC)

			cQryIT += " SELECT DISTINCT A3_COD "
			cQryIT += "   FROM "+RetSqlName("SA3")+" SA3 "
			cQryIT += " WHERE SA3.A3_CGC = '"+ cVndCGC +"' "
			cQryIT += "    AND SA3.A3_FILIAL = '" + xFilial("SA3") +"' "
			cQryIT += "    AND SA3.D_E_L_E_T_ <> '*' "

			cQryIT := ChangeQuery( cQryIT )

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryIT),cAlias3,.T.,.T.)
			dbSelectArea(cAlias3)

			nTotReg := Contar(CALIAS3,"!Eof()")
			(CALIAS3)->(DbGoTop())

			While !(CALIAS3)->(eof())
				If Empty(cVnd1C)
					cVnd1C	:= "'" + (cAlias3)->A3_COD + "'"
				Else
					cVnd1C	+= ",'" + (cAlias3)->A3_COD + "'"
				EndIf
				(CALIAS3)->(DbSkip())
			EndDo

			//--> 11/01/2018 : Welinton Martins : S� valida caso n�o seja inclus�o via rotina autom�tica. Atrav�s da fun��o IsBlind()
			If !IsBlind()
				If !(M->C5_VEND1 $ cVnd1C)
					If !"TEST" $ GetEnvServer()
						lRet	:= .F.
					Endif
					MsgStop("N�o � possivel confirmar a inclus�o deste pedido, verifique o Cliente ou o Vendedor.","Cliente ou Vendedor inv�lido para o usu�rio!(1)")
				EndIf
			EndIf
			(cAlias3)->(DbCloseArea())
		EndIf

	Else

		// Selecionar os Vendedores vinculados ao Clientes conforme o usuario logado
		cQryVC += " SELECT DISTINCT A1_VEND "
		cQryVC += "   FROM "+RetSqlName("SA1")+" SA1 "
		cQryVC += " INNER JOIN "+RetSqlName("SA3")+" SA3 "
		cQryVC += "     ON SA1.A1_VEND = SA3.A3_COD "
		cQryVC += " WHERE SA3.A3_CODUSR = '"+ cCodUser +"' "
		cQryVC += "    AND SA1.A1_FILIAL = '" + xFilial("SA1") +"' "
		cQryVC += "    AND SA1.D_E_L_E_T_ <> '*' "
		cQryVC += "    AND SA3.D_E_L_E_T_ <> '*' "

		cQryVC := ChangeQuery( cQryVC )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryVC),cAlias1,.T.,.T.)
		dbSelectArea(cAlias1)

		nTotReg := Contar(CALIAS1,"!Eof()")
		(CALIAS1)->(DbGoTop())

		If !cCodUser $ GetMV("KP_CLIVEND") //verifica se o usuario est� cadatrado ao parametro para n�o se enquadrar no bloqueio de vendedor
			//If nTotReg > 0 //Caso o usu�rio n�o seja um vendedor, mostrar� todos os pedidos

			While !(CALIAS1)->(eof())
				If Empty(cVnd1A)
					cVnd1A	:= "'" + (cAlias1)->A1_VEND + "'"
				Else
					cVnd1A	+= ",'" + (cAlias1)->A1_VEND + "'"
				EndIf
				(CALIAS1)->(DbSkip())
			End

			//--> 11/01/2018 : Welinton Martins : S� valida caso n�o seja inclus�o via rotina autom�tica. Atrav�s da fun��o IsBlind()
			If !IsBlind()			
				If !(M->C5_VEND1 $ cVnd1A)
					If !"TEST" $ GetEnvServer()
						lRet	:= .F.
					Endif
					MsgStop("N�o � possivel confirmar a inclus�o deste pedido, verifique o Cliente ou o Vendedor.","Cliente ou Vendedor inv�lido para o usu�rio!(2)")
				EndIf
			EndIf

			//EndIf
		EndIf

		// Selecionar os Vendedores conforme o c�digo do usu�rio logado
		cQryUV += " SELECT DISTINCT A3_COD "
		cQryUV += "   FROM "+RetSqlName("SA3")+" SA3 "
		cQryUV += " WHERE SA3.A3_CODUSR = '"+ cCodUser +"' "
		cQryUV += "    AND SA3.A3_FILIAL = '" + xFilial("SA3") +"' "
		cQryUV += "    AND SA3.D_E_L_E_T_ <> '*' "

		cQryUV := ChangeQuery( cQryUV )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryUV),cAlias2,.T.,.T.)
		dbSelectArea(cAlias2)

		nTotReg := Contar(CALIAS2,"!Eof()")
		(CALIAS2)->(DbGoTop())

		If !cCodUser $ GetMV("KP_USRVEN") //verifica se o usuario est� cadatrado ao parametro para n�o se enquadrar no bloqueio de vendedor

			While !(CALIAS2)->(eof())
				If Empty(cVnd1B)
					cVnd1B	:= "'" + (cAlias2)->A3_COD + "'"
				Else
					cVnd1B	+= ",'" + (cAlias2)->A3_COD + "'"
				EndIf
				(CALIAS2)->(DbSkip())
			End

			//--> 11/01/2018 : Welinton Martins : S� valida caso n�o seja inclus�o via rotina autom�tica. Atrav�s da fun��o IsBlind()
			If !IsBlind()
				If !(SA1->A1_VEND $ cVnd1B)
					If !"TEST" $ GetEnvServer()
						lRet	:= .F.
					Endif
					MsgStop("N�o � possivel confirmar a inclus�o deste pedido, verifique o Cliente ou o Vendedor.","Cliente ou Vendedor inv�lido para o usu�rio!(3)")
				EndIf
			EndIf
		EndIf

		(cAlias1)->(DbCloseArea())
		(cAlias2)->(DbCloseArea())

	EndIf
EndIf
//Fim da altera��o - Willian Duda - 03.04.2017


If !(U_nwATUOPER()) //Se retornar falso da validacao de operacao, sai do PE
	Return	.F.

Else
	If lRet .And. nOpc != 1
		//GRAVA DATA ATUAL EM C6_ENTREG
		U_ADTENTR()

		//ROTINA PARA GRAVAR DATA E USUARIO
		U_GRVDTUS()

		//ROTINA PARA ENVIAR EMAIL DO PEDIDO DE VENDA POR EMAIL
		If UPPER((Alltrim(GetEnvServer()))) $ "KAPAZI\KAPAZI2\KAPAZI3\KAPAZI4" //Somente ambientes de producao
			//U_EMAPDV() //Nao descomentar....
		EndIf
		//ROTINA PARA GRAVAR DADOS DO PEDIDO NA SZ6, SEJA INCLUS�O OU A�TERACAO
		//U_GRVZ6(C5_NUM) - COMENTADO DIA 16/11/2017 

		//VALIDA OPERACAO INFORMADA NO CABE�ALHO
	EndIf
EndIf

// se retorno ok, pedido normal, alteracao, existe a funcao e a obrigatoriedade da justificativa esta ativada e nao eh execucao automatica
If lRet .and. M->C5_TIPO == "N" .and. nOpc == 4 .and. ExistBlock("KFATR16") .and. lJustif .and. !l410Auto
	// chama a tela para informar a justificativa
	lRet := U_KFATR16(M->C5_NUM)
Endif	

// se retorno ok e atualiza a operacao
If lRet
	If lNewOper
			If isBlind()
					If !(IsInCallStack("U_M410PVNF")) .And. !(IsInCallStack("U_SF2520E")) 
						lRet := U_nwATUOPER()
					EndIf
					
				Else
					If !(IsInCallStack("U_M410PVNF")) .And. !(IsInCallStack("U_SF2520E")) 
						Processa({|| lRet := U_nwATUOPER() },"Processando opera��o dos itens...","Aguarde...")
						//Processa({|| lRet := U_ATUOPER() },"Processando opera��o dos itens...","Aguarde...")
					EndIf	
			Endif 
		Else
			If !(IsInCallStack("U_M410PVNF")) .And. !(IsInCallStack("U_SF2520E")) 
				//lRet := U_ATUOPER()
			EndIf	
	Endif
	
	If !lRet
		Return
	Endif
	
EndIf

// se retorno ok e opcao diferente de visualizar 
If lRet .And. nOpc != 1
	//GRAVA DATA ATUAL EM C6_ENTREG
	U_ADTENTR()
EndIf

// se retornou ok, se ativo, se inclusao ou alteracao e execucao automatica (portal dw)
if lRet .and. lTpFat .and. (nOpc == 3 .or. nOpc == 4) .and. (l410Auto .or. M->C5_K_OPER = '06')
	// atualiza o campo  C6_K_TPFAT para todos os itens do pedido
	AtuTpFat()
Endif

If lReservar
	/*
	if lRet .and. ExistBlock("KFATR23T")

		U_KFATR15C("00","AGUARDANDO REVISAO DE RESERVAS","ZD")

		if IsInCallStack("A410DELETA")
			nOpc := 5
		Endif
		Processa({|| lRet := U_KFATR23(nOpc)},"Gerando reservas...","Aguarde...")
	Endif
	*/
Endif


If cEmpAnt == "04"
	If IsInCallStack("A410DELETA") .And. cFilAnt == "08" .And. !IsBlind() 
		If !Empty(SC5->C5_XHISTRF)
			MsgInfo("Este pedido possui saldo oriundo de transferencias da KI, por favor execute a rotina Estorno de Sld KI para retornar saldos")
			lRet := .f.
		EndIf 
	EndIf
EndIf

If cEmpAnt == "04" .And. (cFilAnt == "01" .or. cFilAnt == "08") .And. (nOpc == 3 .or. nOpc == 4) .and. (M->C5_K_OPER<>'03' .AND. M->C5_TIPO <>'D')
	For nX := 1 To Len(aCols)
		if Alltrim(aCols[nX,_nAz]) != "04" .And. !Empty(aCols[nX,_nAz]) .And. !( aCols[nX][Len(aHeader)+1] )
			lRet := .f.	
			_cPrdAmzE := Alltrim(aCols[nX,_nPr])  +"/"+ _cPrdAmzE
		endif
	Next 
EndIf 

If !lRet .And.  !Empty(_cPrdAmzE)
	MsgInfo("Este pedido possui os seguintes produtos (" + Substr( AllTrim(_cPrdAmzE),1, Len(Alltrim(_cPrdAmzE)) -1) + ") com o AMZ diferente de 04, ajuste os itens e solicite o ajuste do cadastro de produto para que possa ser utilizado o AMZ 04(expedicao)!")
EndIf

// restaura a area
RestArea(aArea)
RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)
Return lRet

/**********************************************************************************************************************************/
/** user function GRVDTUS()                                                                                                      **/
/**ponto de entrada para gravar a data de alteracao e o nome de quem alterou   ---- Rodrigo Slisinski   												 **/
/**********************************************************************************************************************************/
user function GRVDTUS()

if IsInCallStack("A410Altera")
	reclock("SC5",.F.)
		SC5->C5_USER	:= CUSERNAME
		SC5->C5_DTALTER	:= DDATABASE
		//INCLUIDO DIA 21/10
		SC5->C5_USER	:= USRFULLNAME(__CUSERID)
	MsUnlock()
EndIf

Return .T.

/**********************************************************************************************************************************/
/** user function EmaPdv()                                                                                                      **/
/**inclus�o e altera��o, ser� enviado por email a lista de itensdo pedido. //incluido dia 15/02/2015 - Marcos Sulivan            **/
/**********************************************************************************************************************************/
User Function EMAPDV()
	Local cServerIni 	:= GetAdv97()
	Local cTopAlias 	:= GetPvProfString("KAPAZI","DBALIAS",".",cServerIni)

	If Upper(cTopAlias) != 'P12_PROD' ////Somente producao
		//Return()
	EndIf

	/*
	//4-Altera��o
	if (paramixb[1]== 4 .AND. U_KPFATV01())

	//ENVIO DE EMAIL COM PDV
	cPed := CVALTOCHAR(M->C5_NUM)
	U_KPFATR11(cPed,paramixb[1]) //Descomentar quando virar em producao P12

	EndIf

	//3-Inclus�o
	if (paramixb[1]== 3 .AND. U_KPFATV01())

	//ENVIO DE EMAIL COM PDV
	cPed := CVALTOCHAR(M->C5_NUM)
	U_KPFATR11(cPed,paramixb[1]) //Descomentar quando virar em producao P12

	EndIf
	*/
	if (IsInCallStack("A410Altera") .AND. U_KPFATV01())

		//ENVIO DE EMAIL COM PDV
		cPed := CVALTOCHAR(M->C5_NUM)
		U_KPFATR11(cPed,4) //Descomentar quando virar em producao P12

	EndIf

	//3-Inclus�o
	if (IsInCallStack("A410Inclui") .AND. U_KPFATV01())

		//ENVIO DE EMAIL COM PDV
		cPed := CVALTOCHAR(M->C5_NUM)
		U_KPFATR11(cPed,3) //Descomentar quando virar em producao P12

	EndIf


return

/**********************************************************************************************************************************/
/** user function ADTENTR()                                                                                                      **/
/**altera data entrega**/
/**********************************************************************************************************************************/
User Function ADTENTR()
	Local aArea  	 := GetArea()
	Local nAz			 := 0
	Local nAy			 := 0

	//EXECUTA APENAS NA ALTERACAO.

	if paramixb[1]== 4

		//POSICAO DO CAMPO
		nAz :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})

		For nAy := 1 To Len(aCols)
			//ALTERA DATA DE ENTREGA COM DATA DE EMISSAO DO PEDIDO.
			aCols[nAy,nAz]:= M->C5_EMISSAO
		Next nAy

	EndIf
	
	//incluido dia 05/05/2016
	if paramixb[1]== 3

		//POSICAO DO CAMPO
		nAz :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})

		For nAy := 1 To Len(aCols)
			//ALTERA DATA DE ENTREGA COM DATA DE EMISSAO DO PEDIDO.
			aCols[nAy,nAz]:= M->C5_EMISSAO
		Next nAy

	EndIf
	//incluido dia 05/05/2016
	RestArea(aArea)

Return .T.                     

/**********************************************************************************************************************************/
/** user function nwATUOPER()                                                                                                      **/
/**********************************************************************************************************************************/
/** Funcionalidade para validar a operacao que ser� digitada no pedido, permitindo apenas um tipo.															 **/
/**********************************************************************************************************************************/
User Function nwATUOPER() 
Local aArea	:= GetArea()
Local lRet 	:= .T.
Local nXk	:= 0
Local cTes	:= ""
Local nPosCF:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF"		})
Local nAz 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_OPER"	})
Local nIt 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"	})
Local nCz 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"		}) 
Local nDz 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"	}) 
Local nEz 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CLASFIS"	})
Local nCdL 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CODLAN"	})
Local _cTes	:= "" 
Local lValid := .F.

// se nao � alteracao ou inclusao
If !(PARAMIXB[1] == 4 .or. PARAMIXB[1] == 3 )
	// sai da funcao
	Return .T.
Endif

// se devolucao
If ( IsInCallStack("A410Devol") .or. IsInCallStack("a410procdv") ) .AND. M->C5_TIPO = 'N' .AND. ALLTRIM(M->C5_K_OPER) == ""
	// operacao de devolucao
	M->C5_K_OPER := '07'
EndIf

// se devolucao
IF ( M->C5_TIPO = 'D' .AND. ALLTRIM(M->C5_K_OPER) == ""	)
	// operacao de devolucao
	M->C5_K_OPER := '07'
Endif

// se operacao em branco
If Empty(AllTrim(M->C5_K_OPER)) 
	if !isBlind()
		// exibe msg de erro
		MsgStop("Informe a operacao no cabecalho.")
	Endif
	// sai da funcao
	Return .F.
Endif	

// se tipo normal ou  devolucao
if M->C5_TIPO $ 'N/D'
	
	If !isBlind()
		ProcRegua(0)
		IncProc()
		IncProc()
		ProcRegua(Len(aCols))
	Endif
	
	// faz loop nos dados do acols
	For nXk := 1 to Len(aCols) 
		
		n := nXk
		
		If !isBlind()
			IncProc()
		Endif
		
		If aCols[nXk][Len(aHeader)+1] // se deletado
			Loop // proximo item
		Endif 
		
		If !Empty( AllTrim( aCols[nXk,nAz] ) ) .And. !lValid // se operacao preenchida 
			
			
			If  aCols[nXk,nAz] <> M->C5_K_OPER .and. !isBlind() // se a operacao do item � diferente do informado no cabecalho
				
				if IsInCallStack("A410Altera") .And. !(IsInCallStack("A410Inclui"))
					// pergunta se o usuario quer alterar 
					If !MsgYesNo( "A opera��o do item " + aCols[nXk,nIt] + " Esta diferente do Cabe�alho. Deseja Modificar o Item de Acordo com o campo OPERA��O do cabe�alho? ", "VERIFIQUE A OPERA��O" )
							// se nao quer alterar sai 
							Return	.F.	
						Else
							lRet 	:= .T. //atualiza o retorno
							lValid 	:= .T.
							lAtualO	:= .T.
					Endif
				EndIf
				
				If (IsInCallStack("A410Inclui"))
					MsgInfo("Tipo de operacao diferente na inclusao, favor verificar!","Kapazi")
					Return	.F.
				EndIf
				
			Endif
		Endif
		
		If IsInCallStack("A410Altera") .And. !(IsInCallStack("A410Inclui")) //.And. aCols[nXk,nAz] <> M->C5_K_OPER
			// atualiza a operacao no item do pedido
			aCols[nXk,nAz] 		:= M->C5_K_OPER
			// atualiza a tes do pedido
			_cTes	:= MaTesInt(2,M->C5_K_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[nXk,nDz],"C6_TES")
			
			// se retornou tes
			If !Empty(_cTes)
				// abre tabela de  tes
				SF4->( DbSetOrder(1) )
				// localiza a tes
				If SF4->( DbSeek( xFilial("SC6") + _cTes ) )
					//aCols[nXf,nCdL] 	:= SF4->F4_CODLAN                                                                                      
					// atualiza a cfop 
					//aCols[nXk][nPosCF] := SF4->F4_CF //Left( aCols[nXk][nPosCF], 1) + Substr(SF4->F4_CF,2,3)
				Endif
				
				// atualiza situacao tributaria
				aCols[nXk,nEz] := CodSitTri()
				
				If ExistTrigger("C6_OPER")
					M->C6_PRODUTO 	:= aCols[n][nDz]
					aCols[n,nAz] 	:= M->C5_K_OPER
					RunTrigger(2,nXk,nil,,"C6_OPER") //Qndo ocorrer uma virada de versao/release colocar //!(IsInCallStack("U_MT410TOK")) na condicao do gatilho na SEQ 001, po�s � desnessario.
					SYSREFRESH()
				EndIf
				aCols[nXk,nCz] 		:= _cTes //Atualiza a TES
			Endif
		EndIf
		
	Next nXk
	
	n := 1
Endif

// restaura a area
RestArea(aArea)
// sai da funcao
Return lRet  

User Function ATUOPER() 
Local lRet 	:=	.T.
Local lAuxA	:=	.F.	
Local cTes1 :=	""
Local cTes2	:=	"" 
Local nXf	:= 0
    
if (( paramixb[1]== 4  .OR. paramixb[1]== 3 ) .AND. M->C5_TIPO = 'N')
		//POSICAO DO CAMPO
		nOp 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_OPER"})
		nIt 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
		nTes 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"}) 
		nProd 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"}) 
		nClFis 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CLASFIS"})
		nCdLa 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CODLAN"})  
		nNfO 	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_NFORI"})
		
	
		For nXf := 1 To Len(aCols) 
			cTes1	:=	MaTesInt(2,M->C5_K_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[nXf,nProd],"C6_TES") //Comentado Luis 09/08/2019
		 
			//VALIDA SE ITEM ESTA DELETADO
			If  (aCols[nXf][Len(aHeader)+1])  
			
		
				Else
					// Comentado em 09/08/2019 Luis
					If !(ALLTRIM(aCols[nXf,nOp]) == "" ) //Tipo de operacao Vazia
								If !(aCols[nXf,nOp] == M->C5_K_OPER .AND. aCols[nXf,nTes] == cTes1 )
										If  lAuxA := MSGYESNO( "A opera��o do item " + aCols[nXf,nIt] + " Esta diferente do Cabe�alho. Deseja Modificar o Item de Acordo com o campo OPERA��O do cabe�alho? ", "VERIFIQUE A OPERA��O" )
												
												/*
												nTipo			Num�rico			Qual tipo de objeto ser� executado a trigger(1-Enchoice 2-GetDados 3-F3 ).										
												nLin			Num�rico			Quanto nTipo = 2, informar a linha posicionada na Getdados.										
												cMacro			Caracter			N�o utilizado.										
												oObj			Objeto				Objeto utilizado na tela, para utilizar a propriedade aGets e aTela quando for nTipo = 1.										
												cField			Array of Record		Nome do campo que dispara a trigger. Se n�o informado, considera o campo atualmente posicionado no SX3.
												*/
												
												aCols[nXf,nOp] 		:= M->C5_K_OPER
												
												/*
												If ExistTrigger("C6_OPER")
													RunTrigger(2,nXf,nil,,"C6_OPER")
													SYSREFRESH()
												EndIf
												*/
												aCols[nXf,nTes] 	:= MaTesInt(2,M->C5_K_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[nXf,nProd],"C6_TES")
												aCols[nXf,nClFis] 	:= CodSitTri()
												lRet := .T. 
						
											Else
												Return	.F.
										EndIF
								EndIf
								
						Else 
							aCols[nXf,nOp] := M->C5_K_OPER   
							/*  
							If ExistTrigger("C6_OPER")
								RunTrigger(2,nXf,nil,,"C6_OPER")
							EndIf
							*/  
							//aCols[nXf,nTes] := MaTesInt(2,M->C5_K_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[nXf,nProd],"C6_TES")
							//aCols[nXf,nClFis] := CodSitTri()
												
							lRet := .T.
									
					EndIf
			EndIf
		Next nXf
		
	ElseIF (M->C5_TIPO == 'D' .AND. ALLTRIM(M->C5_K_OPER) == ""	)
		M->C5_K_OPER := '07'
			
	ElseIf	(paramixb[1] == 8 .AND. M->C5_TIPO == 'N' .AND. ALLTRIM(M->C5_K_OPER) == "")    
		M->C5_K_OPER := '07'
	
EndIf

Return lRet 

Static Function AtuTpFat()
	Local aArea := GetArea()
	Local nX	:= 0
	Local nPTp	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_K_TPFAT"})
	Local nPPro	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	Local nPCli	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CLI"})
	Local cProd	:= ""
	
	If nPTp == 0
		Return		
	Endif
	
	SB1->( DbSetOrder(1) )
	
	For nX := 1 to Len(aCols)
		If !Atail(aCols[nX])
			cProd := aCols[nX][nPPro]
			
			If SB1->( MsSeek( xFilial("SB1")+cProd ) )
				If(M->C5_CLIENTE = '092693') //quando for venda pro CD sempre utilize 1 UM
					aCols[nX][nPTp] := "1"
				ElseIf(M->C5_K_OPER = '06') //quando for venda pro CD sempre utilize 1 UM
					aCols[nX][nPTp] := "1"
				ElseIf (!Empty(SB1->B1_SEGUM) .and. AllTrim(SB1->B1_UM) == "M2" ) .or. SB1->B1_XUSGUM == 'S'					
					aCols[nX][nPTp] := "2"
				Else
					aCols[nX][nPTp] := "1"
				Endif
			Endif
		EndIf		
	Next nX
	
	RestArea(aArea)
Return


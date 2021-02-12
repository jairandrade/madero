/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIET�RIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Compras         																																						 		**/
/** NOME 				: MT103FIM.RPW																																										**/
/** FINALIDADE	: P. E. Executado no final do documento de entrada                                                **/
/** SOLICITANTE	: Su�llen              					                                                           				**/
/** DATA 				: 15/02/2014																																							 				**/
/** RESPONS�VEL	: RSAC SOLU��ES																																										**/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARA��O DAS BIBLIOTECAS                                         	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
/**---------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINI��O DE PALAVRAS 	  			 								                  	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10) 
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUN��O: U_MT103FIM														                                                        **/
/** DESCRI��O	  	: Gerencia as demais rotinas 																																		**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIA��O /ALTERA��ES / MANUTEN��ES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicita��o         | Descri��o                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 15/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/	

/*
O ponto de entrada MT103FIM encontra-se no final da fun��o A103NFISCAL.
Ap�s o destravamento de todas as tabelas envolvidas na grava��o do documento de entrada, depois de fechar a opera��o realizada neste.
� utilizado para realizar alguma opera��o ap�s a grava��o da NFE.
*/

User Function MT103FIM()
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaCTT	:= CTT->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local lAtvDesb	:= SuperGetMv("KP_DESBDEV",.F.,.T.)

//Verifica se � do tipo normal
If (SF1->F1_TIPO == "N")
	//Verifica se � confirma��o de inclus�o
	If ((ParamIxb[1] == 3 .OR. ParamIxb[1] == 4) .AND. ParamIxb[2] == 1)
		//Graca a justificativa nos t�tulos
		GravaTit()
	EndIf
EndIf	

If (SF1->F1_TIPO == "D") .And. lAtvDesb .And. cEmpAnt == "04"
	
	/*
	//Volta o bloqueio Clientes 
	xDesbCli(__cUserId)
	
	//Volta os bloqueios dos produtos
	xDesbPro(__cUserId)
	
	//Volta os bloqueios dos centros de custos
	xDesbCTT(__cUserId)
	
	//Faz o desbloqueio geral: Centro de custo, cliente e produto
	//xDesGeral(__cUserId)
	*/
	
	//Faz o desbloqueio geral: Centro de custo, cliente e produto
	u_DesGeral(__cUserId,"MATA103")
	
	_aATItDV	:= {} //Zera variavel
EndIf

//EM 27/0/2019 - Atualiza TABELA C00
If !Empty(AllTrim(SF1->F1_CHVNFE))
	C00->(DbSetOrder(1))
	If C00->(DbSeek(xFilial("C00")+SF1->F1_CHVNFE))
		Reclock("C00",.F.)
			C00->C00_CLASSI := "S"
		MsUnLock("C00")
	EndIf
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaCTT)
RestArea(aAreaSA1)
RestArea(aArea)
Return Nil

/*
//Faz o desbloqueio geral das entidades 
Static Function xDesGeral(cIdUser,cRotina)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_ROTINA	= 'MATA103' "

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())
	
	//Valida e desbloqueia centro de custo
	If Alltrim(QZBL->ZBL_PROCES) == 'CTT'
		//localiza o cliente
		DbSelectArea("CTT")
		CTT->(DbSetOrder(1)) //CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
		CTT->(DbGoTop())
		If CTT->(DbSeek(xFilial("CTT") + QZBL->ZBL_CCUSTO))
	
			//bloqueia o centro de custo
			RecLock("CTT", .F.)
			CTT->CTT_BLOQ := "1"
			MsUnlock()
			
			DbSelectArea("ZBL")
			ZBL->(DbGoTo(QZBL->RECORECO))
			RecLock("ZBL",.F.)
			DbDelete()
			ZBL->(MsUnlock())
			
		EndIf
		
	EndIf
	
	//Valida e desbloqueia produto
	If Alltrim(QZBL->ZBL_PROCES) == 'SB1'
		// localiza o cliente
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If SB1->(DbSeek(XFilial("SB1") + QZBL->ZBL_COD))
	
			//bloqueia o cliente
			RecLock("SB1", .F.)
			SB1->B1_MSBLQL := "1"
			MsUnlock()
			
			DbSelectArea("ZBL")
			ZBL->(DbGoTo(QZBL->RECORECO))
			RecLock("ZBL",.F.)
			DbDelete()
			ZBL->(MsUnlock())
		EndIf
	EndIf
	
	////Valida e desbloqueia cliente
	If Alltrim(QZBL->ZBL_PROCES) == 'SA1'
		// localiza o cliente
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		If SA1->(DbSeek(XFilial("SA1") + QZBL->ZBL_CLIENT + QZBL->ZBL_LOJA))
	
			//bloqueia o cliente
			RecLock("SA1", .F.)
			SA1->A1_MSBLQL := "1"
			MsUnlock()
			
			DbSelectArea("ZBL")
			ZBL->(DbGoTo(QZBL->RECORECO))
			RecLock("ZBL",.F.)
			DbDelete()
			ZBL->(MsUnlock())
		EndIf
	EndIf
	
	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)

Return()


//Funcao responsavel por bloqueio novamente do cliente
Static Function xDesbCTT(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'CTT'

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	//localiza o cliente
	DbSelectArea("CTT")
	CTT->(DbSetOrder(1)) //CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
	CTT->(DbGoTop())
	If CTT->(DbSeek(xFilial("CTT") + QZBL->ZBL_CCUSTO))

		//bloqueia o centro de custo
		RecLock("CTT", .F.)
		CTT->CTT_BLOQ := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()


//Funcao responsavel por bloqueio novamente do cliente
Static Function xDesbCli(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'SA1'

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	// localiza o cliente
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(XFilial("SA1") + QZBL->ZBL_CLIENT + QZBL->ZBL_LOJA))

		//bloqueia o cliente
		RecLock("SA1", .F.)
		SA1->A1_MSBLQL := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()

//Funcao responsavel por bloqueio dos produtos
Static Function xDesbPro(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'SB1'

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	// localiza o cliente
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If SB1->(DbSeek(XFilial("SB1") + QZBL->ZBL_COD))

		//bloqueia o cliente
		RecLock("SB1", .F.)
		SB1->B1_MSBLQL := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()
*/

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUN��O: GravaTit()														                                                        **/
/** DESCRI��O	  	: Grava a justificativa nos t�tulos da nota fiscal  																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIA��O /ALTERA��ES / MANUTEN��ES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicita��o         | Descri��o                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 15/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/	

Static Function GravaTit() 
	Local cQr		:= "" //Query
	Local cJust	 	:= "" //Justificativa
	Local cJusRes 	:= "" //Justificativa resumida para grava��o
	
	//Recupera a justificativa
	cJust 	:= UPPER( U_KCOMA001(.T., "G") )
	
	//Grava a justificativa resumida para o relat�rio
	cJusRes := Alltrim(StrTran(cJust, CHR(13)+CHR(10), " "))
	
	//Limita o texto
	cJusRes := Substr(cJusRes, 1, TamSx3("E2_HIST")[1] )
	
	//Verifica se existe justificativa
	If (!Empty(cJust))
		//Monta a query
		cQr := " UPDATE "	+ RetSqlName("SE2") 
		cQr += " SET E2_HIST = '" + cJusRes + "'
		cQr += " ,E2_JUSTIF = '" + cJust +  "'
		cQr += " WHERE E2_FILIAL = '" + xFilial("SE2")+ "'
		cQr += " AND E2_PREFIXO = '" + cSerie +	"' 
		cQr += " AND E2_NUM = '" + cNFiscal +	"'        
		cQr += " AND E2_FORNECE = '" + cA100FOR	+	"'
		cQr += " AND E2_LOJA = '" + cLoja	+	"'        
		cQr += " AND D_E_L_E_T_  = ' ' 
		
		//Executa a query
		If TcSqlExec(cQr) < 0
			// exibe erro no console
			conout( DtoS( Date() ) + '-' + Time() + ' - MT103FIM - GravaTit - ERRO SQL' + TcSqlError() +ENTER+ cQr )
		Endif
	
	Endif

Return Nil

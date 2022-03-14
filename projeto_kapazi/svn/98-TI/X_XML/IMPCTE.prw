#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| FISCAL                                                                                                                                 |
| Grava��o de dados do arquivo XML Ct-e para as tabelas ZC1 e ZC2                                                                        |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 24.05.2018                                                                                                                       |
| Descricao:                                                                                                                             |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//11.07.2018
user function IMPCTE()

	local nFrete := 0
	LOCAL nFreteP := 0
	Local nOutros := 0
	local nPedagio := 0
	Local nTAS := 0
	Local nEmex := 0
	Local nGRIS := 0
	local nDESPACHO :=0 
	Local nREPASSADO :=0
	local nTRT := 0
	local cTpDados := ""
	Local cTpdado2 := ""
	Local lRet := .f.
	Local nValIcms := 0
	Local nz,nx,nt := 0
	Local cTPCTE := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TPCTE:text
	Local cDescTp := ''
	Local lCompl := .f.
    Local _cCodForn := ''
    Local _cLojForn := ''


	If cTPCTE ='0'
		cDescTp := 'CT-e Normal'
	ElseIf cTPCTE ='1'
		cDescTp := 'CT-e Complemento'
	ElseIf cTPCTE ='2'
		cDescTp := 'CT-e Anulacao'
	EndIf

	cTpdado2 := valtype(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP)

	if (cTpdado2 == "A")
	   FOR nZ := 1 to  len(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP)
			//EM 20/05/2019 [AKIRA]
			//ALTEADO DE IF PARA ELSEIF

			if oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "FRETE VALOR"
				nFrete :=  VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "FRETE PESO"
				nFreteP:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)	
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "PEDAGIO"
				nPedagio:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "GRIS"
				nGRIS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "EMEX"
				nEmex:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "TAS"
				nTAS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)	
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "DESPACHO"
				nDESPACHO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "TRT"
				nTRT:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "IMP REPASSADO"
				nREPASSADO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)

			Else
				nOutros:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)
			endif

		next nZ
	ELSE

		if oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "FRETE VALOR"
			nFrete :=  VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "FRETE PESO"
			nFreteP:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "PEDAGIO"
			nPedagio:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "GRIS"
			nGRIS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "EMEX"
			nEmex:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "TAS"
			nTAS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "DESPACHO"
			nDESPACHO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "TRT"
			nTRT:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "IMP REPASSADO"
			nREPASSADO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Else
			nOutros:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		endif	
	ENDIF

	//EM 20/05/2019
	//tag imp (icms)
	If type('oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT') <> 'U'
		nValIcms := VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT)
	EndIf
	//ATE AQUI - 20/05/2019
	dbSelectArea('ZC1')
	ZC1->(DBSetOrder(1))
	If !ZC1->(DbSeek( xFilial("ZC1") + cChaveNf))
		lRet:= .t.


        _cCodForn := 'XXXXXX'
        _cLojForn := 'XX'

        IF (Select('TRA2') <> 0)
            TRA2->(DBCloseArea())
        EndIF

        BeginSql Alias 'TRA2'
            SELECT 
                R_E_C_N_O_ REC, A2_COD,A2_LOJA
            FROM 
                %Table:SA2%
            WHERE 
                A2_CGC = %exp:OXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT%
                AND A2_MSBLQL <>'1'
                AND %notdel%
        endSql
        
        IF !TRA2->(EOF())
            _cCodForn := SA2->A2_COD
            _cLojForn := SA2->A2_LOJA
        Else
            aviso('Nao Cadastrado',"Fornecedor"+alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)+" nao cadastrado",{"OK"})
            
        EndIF

		
		RecLock("ZC1",.T.)
            ZC1->ZC1_FILIAL := xFilial("ZC1")
            ZC1->ZC1_DTLANC := DDATABASE
            ZC1->ZC1_DTEMIS := ctod(SUBSTRING(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,9,2)+"/"+SUBSTRING(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,6,2)+"/"+SUBSTRING(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,1,4))
            ZC1->ZC1_FORNEC := _cCodForn
            ZC1->ZC1_LOJFOR :=  _cLojForn
            ZC1->ZC1_CTE    := cChaveNf

            IF TYPE("OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") == "C"
                ZC1->ZC1_CODCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,'A1_COD')
                ZC1->ZC1_LOJCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,'A1_LOJA')
            ELSE
                ZC1->ZC1_CODCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT,'A1_COD')
                ZC1->ZC1_LOJCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT,'A1_LOJA')
            ENDIF

            ZC1->ZC1_VLSERV := VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
            ZC1->ZC1_FRETE  := nFrete+nFreteP
            ZC1->ZC1_PEDAGI := nPedagio
            ZC1->ZC1_OUTROS := nDESPACHO+nTRT+nOutros
            ZC1->ZC1_TAS    := nTas
            ZC1->ZC1_GRIS   := nGRIS
            ZC1->ZC1_EMEX   := nEMEX
            ZC1->ZC1_VALICM := nValIcms
            //em 28/05/2019
            ZC1->ZC1_MUN_I := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_xMunIni:text
            ZC1->ZC1_UF_I  := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFIni:text
            ZC1->ZC1_MUN_F := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_xMunFim:text
            ZC1->ZC1_UF_F  := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFim:text

            //em 15/07/2019
            ZC1->ZC1_TPCTE  := cTpCte
            ZC1->ZC1_DESCTP := cDescTp
            If (cTpCte == '1') //nota complementar
                cChvOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT
                lCompl := ValNFComp(cChvOri)
                //A = Ativo; B = Bloqueado 
                //se n�o encontrou CTE "original" fica bloqueado
                ZC1->ZC1_STATUS := IIf( lCompl, "A", "B" )
            Else
                ZC1->ZC1_STATUS := 'A' //ativo
            EndIf
		ZC1->(MsUnLock())

		If (type('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE') <> 'U')
			cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE) 

			if (cTpDados == "A") //Array

				FOR nX := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)  
					dbSelectArea('ZC2')
					ZC2->(DBSetOrder(1))

					If !ZC2->(DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT+cChaveNf))
						RecLock("ZC2",.T.)
                            ZC2_FILIAL := xFilial("ZC2")
                            ZC2_CTE    := cChaveNf
                            ZC2_CHAVE  := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT
                            ZC2_SEQUEN := cValToChar(nX)
                            ZC2_NUMNFE := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[NX]:_CHAVE:TEXT,26,9)
                            ZC2_SERIE  := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT,23,3)
						ZC2->(MsUnLock())
					endif
				next

			else  // Indetificado que o tipo de dados é "O" Objeto 	

				dbSelectArea('ZC2')
				ZC2->(DBSetOrder(1))
				
				If !ZC2->(DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT+cChaveNf))
					RecLock("ZC2",.T.)
                        ZC2_FILIAL := xFilial("ZC2")
                        ZC2_CTE    := cChaveNf
                        ZC2_CHAVE  := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT
                        ZC2_SEQUEN := "1"
                        ZC2_NUMNFE := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,26,9)
                        ZC2_SERIE  := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,3)
					ZC2->(MsUnLock())
				endif
			endif
		EndIf

		If (type('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP') <> 'U')
			cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP) 
			if cTpDados == "A" //Array
				FOR nX := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP)                      
                    IF (Select('TRZC2') <> 0)
                        TRZC2->(DBCloseArea())
                    EndIF

                    BeginSql Alias 'TRZC2'
                        SELECT
                            ZC2_CHAVE, ZC2_SEQUEN, ZC2_NUMNFE, ZC2_SERIE
                        FROM
                            %TABLE:ZC2%
                        WHERE
                            ZC2_CTE = %EXP:oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP[nx]:_CHCTE:TEXT%
                            AND %NOTDEL%
                    EndSql

					RecLock("ZC2",.T.)
                        ZC2->ZC2_FILIAL := xFilial("ZC2")
                        ZC2->ZC2_CTE    := cChaveNf
                        ZC2->ZC2_CHAVE  := TRZC2->ZC2_CHAVE 
                        ZC2->ZC2_SEQUEN := TRZC2->ZC2_SEQUEN 
                        ZC2->ZC2_NUMNFE := TRZC2->ZC2_NUMNFE 
                        ZC2->ZC2_SERIE  := TRZC2->ZC2_SERIE 
					MsUnLock()
				next Nx
			else 	
				IF Select('TRZC2')<>0
					TRZC2->(DBCloseArea())
				EndIF

                BeginSql Alias 'TRZC2'
                    SELECT
                        ZC2_CHAVE, ZC2_SEQUEN, ZC2_NUMNFE, ZC2_SERIE
                    FROM
                        %TABLE:ZC2%
                    WHERE
                        ZC2_CTE = %EXP:oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT%
                        AND %NOTDEL%
                EndSql

				RecLock("ZC2",.T.)
                    ZC2->ZC2_FILIAL := xFilial("ZC2")
                    ZC2->ZC2_CTE    := cChaveNf
                    ZC2->ZC2_CHAVE  := TRZC2->ZC2_CHAVE 
                    ZC2->ZC2_SEQUEN := TRZC2->ZC2_SEQUEN 
                    ZC2->ZC2_NUMNFE := TRZC2->ZC2_NUMNFE 
                    ZC2->ZC2_SERIE  := TRZC2->ZC2_SERIE 
				MsUnLock()
			endif
		endif
	EndIf

	//18.03.2019 -- Ir� popular tabela ZC3 conforme a TAG  <infCarga>
	If (TYPE('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ') <> 'U')
		cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ) 
		if cTpDados == "A" //Array

			FOR nT := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ)  
				ctpMed := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_tpMed:TEXT
				dbSelectArea('ZC3')
			    ZC3->(DBSetOrder(1))
				If !DbSeek( xFilial("ZC3") + cChaveNf+ctpMed)
					RecLock("ZC3",.T.)
					lRet:= .t.
				Else
					RecLock("ZC3",.F.)
					lRet:= .t.
				endif
				ZC3_FILIAL 	:= xFilial("ZC3")
				ZC3_CTE 	:=  cChaveNf
				ZC3_UNIDAD 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_cUnid:TEXT
				ZC3_TPMED 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_tpMed:TEXT
				ZC3_QCARGA 	:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_qCarga:TEXT)
				ZC3->(MsUnLock())
			next nT
		Else
			ctpMed := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_tpMed:TEXT
			dbSelectArea('ZC3')
			ZC3->(DBSetOrder(1))
			If !ZC3->(DbSeek( xFilial("ZC3") + cChaveNf + ctpMed))
				RecLock("ZC3",.T.)
				lRet:= .t.
			Else
				RecLock("ZC3",.F.)
				lRet:= .t.
			endif
            
            ZC3_FILIAL 	:= xFilial("ZC3")
            ZC3_CTE 	:=  cChaveNf
            ZC3_UNIDAD 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_cUnid:TEXT
            ZC3_TPMED 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_tpMed:TEXT
            ZC3_QCARGA 	:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_qCarga:TEXT)

			ZC3->(MsUnLock())

		EndIf
	EndIf
	//FIM -- 18.03.2019

	//EM 07/08/2020 complemento
	If (cTPCTE == '1')
		IF Select('TRZC3')<>0
			TRZC3->(DBCloseArea())
		EndIF
		
        BeginSql Alias 'TRZC3'
            SELECT
                ZC3_UNIDAD, ZC3_TPMED, ZC3_QCARGA
            FROM
                %TABLE:ZC3%
            WHERE
                ZC3_CTE = %Exp:oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT%
                AND %NOTDEL%
        endSql
		
		While !TRZC3->(eof())
			RecLock("ZC3",.T.)
                ZC3->ZC3_FILIAL := xFilial("ZC3")
                ZC3->ZC3_CTE 	:= cChaveNf
                ZC3->ZC3_UNIDAD := TRZC3->ZC3_UNIDAD
                ZC3->ZC3_TPMED 	:= TRZC3->ZC3_TPMED
                ZC3->ZC3_QCARGA := TRZC3->ZC3_QCARGA
			ZC3->(MsUnLock())

			TRZC3->(DbSkip())		
		Enddo
		
	EndIf

	if !lRet
		msgstop("Arquivo CTE j� importado para a chave: "+ cChaveNf)
    else
	   // daniel em 05//01/2021 
	   // implementa��o direta para o F1 e D1 -   Entrada j� Classificada
       u_cLasCte(cChaveNf,oXml)        
	endif

return

//----------------------------------------------------
/*/{Protheus.doc} ValNFComp
Valida chave da NF

@type function
@version 1.0
@author Andre Roberto Ramos

@since 25/02/2021

@param cChave, character, Chave da Nota

@return Logical, verdadeiro ou falso
/*/
//----------------------------------------------------
Static Function ValNFComp(cChave)
	
    Local lRet := .F.

	If Select('TRBNF')<>0
		TRBNF->(DbCloseArea())
	EndIf

    BeginSql Alias 'TRBNF'
        SELECT 
	        R_E_C_N_O_ REC
        FROM 
            %Table:SF1%
        WHERE 
            F1_CHVNFE = %Exp:cChave%
            AND %NotDel%
    EndSql

	If TRBNF->(EOF())
		lRet := .F.
	Else
		lRet := .T.
	EndIf

Return(lRet)

//----------------------------------------------------
/*/{Protheus.doc} cLasCte
implementa��o direta para o F1 e D1 -   Entrada j� Classificada

@type function
@version 1.0
@author DANIEL PEREIRA

@since 25/02/2021

@param cChaveNf, character, Chave da Nota
@param oXml, object, Objeto XML
/*/
//----------------------------------------------------
user function cLasCte(cChaveNf,oXml)

    Local cError   := ""
    Local cWarning := ""
    
    Local IH       := 0
    Local cCentroC := Alltrim( SuperGetMV("KP_CCKPCTE"	,.F. ,"490050001"))
    
    Local nTipo     := 1
    Local cProd     := 'FRETE'
    Local cTes      := "003"
    Local cCfop     := ''
    Local cQtd      := 1
    Local cVun      := 0 //ZC1->ZC1_VLSERV
    Local _nAliqIcm := 0
    Local _nValIcm  := 0
    Local _nBaseIcm := 0
    Local _nValIpi  := 0
    Local _nBaseIpi := 0
    Local _nValMerc := 0
    Local _nValSol  := 0
    Local _nValDesc := 0
    Local _nPrVen   := 0
    Local nBCcm     := 0 //D1_BASEICM
    Local nPicm     := 0 //D1_PICM
    Local nVicm     := 0 // D1_VALICM

    Private aProd := {} 
    Private aCmps := {}		    
    
    aCmps := {;	
        5,;     //1
        '',;//2 --CAMINHO ARQUIVO
        SPACE(TAMSX3("A2_COD" )[1]),;//3
        SPACE(TAMSX3("A2_LOJA")[1]),;//4
        SPACE(TAMSX3("A2_NOME")[1]),;//5
        SPACE(TAMSX3("F1_DOC" )[1]),;//6
        0.00,;//SPACE(TAMSX3("F1_VALMERC")[1]),;//7
        0.00,;//SPACE(TAMSX3("F1_FRETE")[1]),;//8
        0.00,;//SPACE(TAMSX3("F1_DESCONT")[1]),;//9
        0.00,;//SPACE(TAMSX3("F1_DESPESA")[1]),;//10
        0.00,;//SPACE(TAMSX3("F1_VALIPI")[1]),;//11
        0.00,;//SPACE(TAMSX3("F1_VALBRUT")[1]),;//12
        0.00,;//SPACE(TAMSX3("F1_VALMERC")[1]),;//13
        0.00,;//SPACE(TAMSX3("F1_FRETE")[1]),;//14
        0.00,;//SPACE(TAMSX3("F1_DESCONT")[1]),;//15
        0.00,;//SPACE(TAMSX3("F1_DESPESA")[1]),;//16
        0.00,;//SPACE(TAMSX3("F1_VALIPI")[1]),;//17
        0.00,;//SPACE(TAMSX3("F1_VALBRUT")[1]),;//18
        SPACE(TAMSX3("C8_TES")[1]),;//19
        SPACE(TAMSX3("E4_CODIGO")[1]),;//20
        SPACE(TAMSX3("F1_CHVNFE")[1]),;//21
        SPACE(TAMSX3("E2_NATUREZ")[1]),;//22
        SPACE(TAMSX3("D1_PEDIDO")[1]),; //23
        space(TAMSX3('A2_COND')[1]),; //24
        space(TAMSX3('D1_DESCRI')[1]);
    } //25 -- 210201001           

    DBSelectArea('ZC1')
    ZC1->(DBSETORDER(1))
    IF ZC1->( DBSEEK( XfILIAL('ZC1') + cChaveNf ) )
        cVun := ZC1->ZC1_VLSERV 

        DBSelectArea('SA2')
        SA2->(DBsEToRDER(1))
        IF SA2->(DBSEEK( XfILIAL('SA2') + ZC1->ZC1_FORNEC + ZC1->ZC1_LOJFOR ))
            IF(SA2->A2_MSBLQL='1')
                _cCgc := SA2->A2_CGC
                IF (Select('TRA2') <> 0)
                    TRA2->(DBCloseArea())
                EndIF

                BeginSql Alias 'TRA2'
                    SELECT 
                        R_E_C_N_O_ REC 
                    FROM 
                        %Table:SA2%
                    WHERE 
                        A2_CGC = %exp:_cCgc%
                        AND A2_MSBLQL <>'1'
                        AND %notdel%
                endSql
                if(!TRA2->(eof()))
                    SA2->(DBGOTO(TRA2->REC))
                EndIF
            ENDIF
            aCmps[03] := SA2->A2_COD
            aCmps[04] := SA2->A2_LOJA
            aCmps[05] := SA2->A2_NOME
            //    aCmps[24] := SA2->A2_COND comentada a linha para obedecer as regras de faturar nos dias

            IF(day(dDataBase) <= 10) //pagar dia 21
                aCmps[24] := '436'
            ElseIf(day(dDataBase) <= 20) // pagar dia  01
                aCmps[24] := '437'
            Else //PAGAR DIA 11
                aCmps[24] := '438'
            EndIf
            aCmps[22] := SA2->A2_NATUREZ
        Endif

        DBSelectArea('SB1')
        SB1->(DBsEToRDER(1))
        IF SB1->( DBSEEK( XfILIAL('SB1') + padr(cProd ,tamsx3('B1_COD')[1])) )
            ACmps[25] := SB1->B1_CONTA
        Endif 

    Endif  

    DBSelectArea('C00')
    C00->(DBSETORDER(1))
    IF C00->( DBSEEK( XfILIAL('CC0') + cChaveNf ) )
    
        oXml := XmlParser( FwNoAccent(C00->C00_RSXML), "_", @cError,  @cWarning )//XmlParserFile( cFile, "_", @cError, @cWarning )	//acessando o CONTEUDO do meu nodo ""
        _oxml := oxml
        LCTE  := .f.
        cNota := C00->C00_NUMNFE
        if type('_oXml:_CTEPROC')<>'U'
            dEmis := stod(STRTRAN(SUBSTR(_oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,10),'-',''))
            LCTE := .T.
        EndiF

        if (TYPE('_oXml:_NFE:_INFNFE:_IDE:_DEMI:TEXT')<>'U')
            dEmis := stod(STRTRAN(SUBSTR(_oXml:_NFE:_INFNFE:_IDE:_DEMI:TEXT,1,10),'-',''))
            Ldev := if("DEVOLUCAO" $_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NATOP:TEXT ,.T.,.F.)
        else
            IF TYPE('_oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT') <>'U'
                dEmis := STOD(STRTRAN(SUBSTR(_oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10),'-','')) 
                Ldev := if("DEVOLUCAO" $_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NATOP:TEXT ,.T.,.F.)
            endif
        ENDIF


        //CONDI��O DE PAGAMENTO BASEADA NA DATA DE EMISS�O DO CTE
        //cte�s emitidos de 01 a 10 = venc 21     
        IF(day(dEmis) <= 10) 
            aCmps[24] := '436'//pagar dia 21
        //cte�s emitidos de 11 a 20 = venc 01
        ElseIf(day(dEmis) <= 20) 
            aCmps[24] := '437'// pagar dia  01
        //cte�s emitidos de 21 a 30/31 = venc 11   
        Else 
            aCmps[24] := '438' //PAGAR DIA 11
        EndIf

        ddtAUx := dDataBase
        if (nTipo == 1)
            aCab := {;
                {"F1_FILIAL" 	    ,XfILIAL('SF1')  			     ,NIL,Nil},;
                {"F1_TIPO" 	        ,"N"  							 ,NIL,Nil},;
                {"F1_FORMUL"        ,"N"              				 ,Nil,Nil},;
                {"F1_DOC"           ,C00->C00_NUMNFE        		 ,Nil,Nil},;
                {"F1_SERIE"        	,C00->C00_SERNFE      			 ,Nil,Nil},;
                {"F1_EMISSAO"       ,if(empty(dEmis),ddatabase,dEmis),Nil,Nil},;
                {"F1_FORNECE"       ,aCmps[3]       				 ,Nil,Nil},;
                {"F1_LOJA"          ,aCmps[4]                     	 ,Nil,Nil},;
                {"F1_COND"          ,aCmps[24]             			 ,Nil,Nil},;
                {"F1_CHVNFE"        ,C00->C00_CHVNFE				 ,Nil,Nil},;
                {"E2_NATUREZ"       ,aCmps[22]						 ,Nil,Nil},;
                {"F1_ESPECIE"       ,'CTE'              			 ,Nil,Nil};
            }
        Else
            If (nTipo == 2)
                aCab := {;
                    {"F1_TIPO" 	 , iIF(Ldev,"D","N")				                   ,NIL,Nil},;
                    {"F1_FORMUL" , "N"              				                   ,Nil,Nil},;
                    {"F1_DOC"    , C00->C00_NUMNFE       			                   ,Nil,Nil},;
                    {"F1_SERIE"  , C00->C00_SERNFE       		                       ,Nil,Nil},;
                    {"F1_EMISSAO", iif(empty(C00->C00_DTEMI),ddatabase,C00->C00_DTEMI) ,Nil,Nil},;
                    {"F1_FORNECE", aCmps[3]       					                   ,Nil,Nil},;
                    {"F1_LOJA"   , aCmps[4]            	                               ,Nil,Nil},;
                    {"F1_CHVNFE" , C00->C00_CHVNFE							           ,Nil,Nil},;
                    {"F1_ESPECIE", iIF(LCTE,'CTE',"SPED")                              ,Nil,Nil};
                }
            endif
        EndIF

        aItem   := {}
        aItemPC := {}

        cNota    := padl(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT,tamsx3('F1_DOC')[1],'0')
        cChaveNf := padl(C00->C00_CHVNFE,tamsx3('F1_CHVNFE')[1],'0')
                
        aCmps[06] := cNota
        aCmps[21] := cChaveNf
        lFOr := .t.
        
        IF (Select('TRA2') <> 0)
            TRA2->(DBCloseArea())
        EndIF

        BeginSql Alias 'TRA2'
            SELECT 
                R_E_C_N_O_ REC 
            FROM 
                %Table:SA2%
            WHERE 
                A2_CGC = %exp:oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT%
                AND A2_MSBLQL <>'1'
                AND %notdel%
        endSql
        
        IF !TRA2->(EOF())
            //posiciona no forneecdor
            DBSelectArea('SA2')
            SA2->( DBGoto(TRA2->REC) )
            IF(SA2->A2_MSBLQL='1')
                aviso('Cadastro do Fornencedor est� bloqueado '+SA2->A2_COD+'/'+SA2->A2_LOJA+' - '+ALLTRIM(SA2->A2_NOME),"Fornecedor"+alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)+" nao cadastrado",{"OK"})
                
                lFOr := .f.
            ENDIF
        Else
            aviso('Nao Cadastrado',"Fornecedor"+alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)+" nao cadastrado",{"OK"})
            
            lFOr := .f.
        EndIF

        aCmps[3] := iif( lfor, SA2->A2_COD , '' )
        aCmps[4] := iif( lfor, SA2->A2_LOJA, '' )
        aCmps[5] := iif( lfor, SA2->A2_NOME, alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT) )
        nRecSA2 := iif( lfor, SA2->(RECNO()), 0 )
        
        aCols := {}
        aCmps[07] := VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT) + IIF(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U", 0, VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT))
        aCmps[12] := aCmps[7]
        
        IF ((NTIPO == 1) .or. (NTIPO == 3))
            _oXml:=oxml
            if Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VICMS:TEXT")<>"U"
                nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VICMS:TEXT)
            Else
                nVicm:=0
            EndIF
            
            if Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VBC:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VBC:TEXT")<>"U"
                nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VBC:TEXT)
            eLSE
                nBCcm:=0
            EndIF
            
            if Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_PICMS:TEXT)
            ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_PICMS:TEXT")<>"U"
                nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_PICMS:TEXT)
            ELSE
                nPicm :=0
            EndIF
            
            AADD(Acols,{;
                PADL('1',TAMSX3('D1_ITEM')[1],'0')  ,;
                PADR(IIF(Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",'FRETE1','FRETE'),TAMSX3('D1_COD')[1])  		,;
                PADR(IIF(Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",'FRETE1','FRETE') ,TAMSX3('D1_COD')[1])  		,;
                'FRETE'  		,;
                'UN'  			,;
                '01',;
                1  	,;
                VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)	,;
                VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)   ,;
                SPACE(tamsx3('D1_PEDIDO')[1]),;
                SPACE(tamsx3('D1_ITEMPC')[1]),;
                SPACE(tamsx3('D1_OPER')[1]),;
                SPACE(tamsx3('D1_TES')[1]),;
                0,;
                0,;
                nBCcm,;//D1_BASEICM
                nPicm,;//D1_PICM
                nVicm,;// D1_VALICM
                "",;
                0,;
                "",;
                "",;
                ,.f.;
            } ) //nIpi
        Else
            AADD(Acols,{;
                PADL('1',TAMSX3('D1_ITEM')[1],'0')  ,;
                PADR(IIF(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=='U','FRETE1',IIF(VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT)==0,'FRETE1','FRETE')),TAMSX3('D1_COD')[1])  		,;
                PADR(IIF(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",'FRETE1','FRETE'),TAMSX3('D1_COD')[1])  		,;
                'FRETE'  		,;
                'UN'  			,;
                '01',;
                1  	,;
                VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)	,;
                VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)   ,;
                SPACE(tamsx3('D1_PEDIDO')[1]),;
                SPACE(tamsx3('D1_ITEMPC')[1]),;
                0,;
                0,;
                "",;
                0,;
                ,.f.;
            } )
        EndIF

        MaFisIni(SA2->A2_COD,SA2->A2_LOJA,"f","N",SA2->A2_TIPO,MaFisRelImp("MT100",{ "SD1" }),,,"SD1","MT100")

        cQtd :=1
        cProd := IIF(nVicm==0,'FRETE1','FRETE')
        cVun := ZC1->ZC1_VLSERV

        SB1->(DBSEEK(FWFILIAL('SB1')+PADR(cProd,TAMSX3('D1_COD')[1])))
        cCentroC := SB1->B1_CC
        
        IF Select('TRFM')<>0
            TRFM->(DBCloseArea())
        EndIF

        BeginSql Alias 'TRFM'
            SELECT 
                FM_TE CTES , F4_CF CFOP
            FROM 
                %Table:SFM% SFM
                INNER JOIN %Table:SF4% SF4 ON F4_FILIAL=%xFilial:SF4%  AND FM_TE=F4_CODIGO AND SF4.D_E_L_E_T_=' '
            WHERE  
                FM_FILIAL = %xFilial:SFM%  
                AND FM_TIPO = '54' 
                AND FM_PRODUTO = %Exp:cProd%
                AND SFM.D_E_L_E_T_=' '
        EndSql
        
        IF !TRFM->(EOF())
            cTes := TRFM->CTES 
            cCfop := TRFM->CFOP
        Else
            cTes := ''
            aviso('Nao Cadastrado',"TES INTELIGENTE PARA OPERACAO 54 - VERIFIQUE ",{"OK"})
            lFOr:=.f.
        EndIF

        MaFisAdd(cProd,cTes,cQtd,cVun,0,"","",0,0,0,0,0,(cQtd*cVun),0,0,0)
        _nAliqIcm += MaFisRet(1,"IT_ALIQICM")
        _nValIcm += MaFisRet(1,"IT_VALICM" )
        _nBaseIcm += MaFisRet(1,"IT_BASEICM")
        _nValIpi += MaFisRet(1,"IT_VALIPI" )
        _nBaseIpi += MaFisRet(1,"IT_BASEICM")
        _nValMerc += MaFisRet(1,"IT_VALMERC")
        _nValSol += MaFisRet(1,"IT_VALSOL" )
        _nValDesc += MaFisRet(1,"IT_DESCONTO" )
        _nPrVen += MaFisRet(1,"IT_PRCUNI")

        MaFisEnd()

        aCmps[13]:=_nValMerc
        aCmps[14]:=0
        aCmps[15]:=_nValDesc
        aCmps[16]:=0
        aCmps[17]:=_nValIpi
        aCmps[18]:=_nValMerc+_nValIpi

        aadd(aItemPC,	{'D1_FILIAL',XFILIAL('SD1'),NIL})
        aadd(aItemPC,	{'D1_ITEM','0001',NIL})
        aadd(aItemPC,	{'D1_COD',cProd,NIL})
        //aadd(aItemPC,	{'D1_DESCRI',aCmps[25],NIL})
        aadd(aItemPC,	{'D1_UM','UN',NIL})
        aadd(aItemPC,	{'D1_QUANT',1,NIL})
        aadd(aItemPC,	{'D1_VUNIT',_nPrVen,NIL})
        aadd(aItemPC,	{'D1_TOTAL',cQtd*cVun,NIL})
        aadd(aItemPC,	{'D1_TES',cTes,NIL})
        aadd(aItemPC,	{'D1_CF',cCfop,NIL})

        aadd(aItemPC,	{'D1_FORNECE',aCmps[3],NIL})
        aadd(aItemPC,	{'D1_LOJA',aCmps[4],NIL})
        aadd(aItemPC,	{'D1_CC',cCentroC,NIL})
        aadd(aItemPC,	{'D1_VALMERC',_nValMerc,NIL})
        //aadd(aItemPC,	{'D1_OPER',54,NIL}) 
        aadd(aItemPC,	{'D1_PICM',nPicm,NIL}) 
        aadd(aItemPC,	{'D1_VALICM', nVicm,NIL}) //_nValIcm,NIL})
        aadd(aItemPC,	{'D1_BASEICM',nbCcm,NIL}) //_nBaseIcm,NIL})
        aadd(aItemPC,	{'D1_CONTA',aCmps[25],NIL})
        aadd(aItemPC,	{'D1_GRUPO','SR09',NIL})
        aadd(aItemPC,	{'D1_CLASFIS','000',NIL})
        aadd(aItemPC,	{'D1_ALIQICM', nPicm,NIL}) //_nAliqIcm,NIL})
        aadd(aItemPC,	{'D1_SDOC','000',NIL})
        aadd(aItemPC,	{'D1_RATEIO','2',NIL})
        aadd(aItemPC,	{'D1_SERIE',C00->C00_SERNFE,NIL})

        aadd(aItemPC,	{'D1_EMISSAO',dEmis,NIL})
        aadd(aItemPC,	{'DTDIGT',DDATABASE,NIL})
        aadd(aItemPC,	{'D1_LOCAL','01',NIL}) 
        aadd(aItemPC,	{'D1_TIPO','N',NIL}) 
        aadd(aItemPC,	{'D1_TP','MO',NIL})  

        AADD(aItem,aClone(aItemPC))

        lMsErroAuto := .F.
        if (nTipo == 1) //documento de entrada
            MSExecAuto({ |x,y,z| Mata103(x,y,z)},aCab,aItem,3)
        ElseIf (nTipo == 2) //pre-nota
            MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItem,3)
        EndIF

        If lMsErroAuto
            MostraErro()
        
            NITE := 00
            DBSelectArea('SE2')
            SE2->(dbSetOrder(6))
            AJAFOI := {}

            if SE2->(DBSeek(xFilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC ))
                WHILE !SE2->(EOF()) .AND. (SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC) == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
                    FOR IH := 1 TO LEN(aParcelas)
                        if aParcelas[IH][1]==SE2->E2_PARCELA
                            IF ASCAN(AJAFOI,SE2->E2_PARCELA)==0
                                REClock('SE2',.F.)
                                    SE2->E2_VENCTO  := aParcelas[IH][2]
                                    SE2->E2_VENCREA := DATAVALIDA(aParcelas[IH][2])
                                SE2->(MSUNLOCK())

                                AADD(AJAFOI,SE2->E2_PARCELA)                                
                            ENDIF
                        EndIf

                        if aParcelas[IH][1]=='01' .and. empty(SE2->E2_PARCELA)
                            IF ASCAN(AJAFOI,SE2->E2_PARCELA)==0
                                REClock('SE2',.F.)
                                    SE2->E2_VENCTO  := aParcelas[IH][2]
                                    SE2->E2_VENCREA := DATAVALIDA(aParcelas[IH][2])
                                SE2->(MSUNLOCK())

                                AADD(AJAFOI,SE2->E2_PARCELA)                                
                            ENDIF
                        EndIf                
                    Next
        
                    NITE++
                    SE2->(DBsKIP())
                EndDo
            EndIF
        Else 
            dDataBase := ddtAUx

            RECLOCK('C00',.F.)
                C00->C00_JAIMP := 'S'
            C00->(MSUNLOCK())

            aCaminho := StrTokArr(cFile,"\")
        EndIF
    Else
        aviso("Aten��o!","o Ct-e de numero: " + alltrim(C00->C00_NUMNFE)+ ' n�o foi classificada, verifique!',{"Ok"})
    endif

Return

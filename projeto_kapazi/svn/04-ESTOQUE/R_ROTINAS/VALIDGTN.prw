#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: VALIDGTN 	|	Autor: Luis Paulo									|	Data: 26/03/2020//
//==================================================================================================//
//	Descri��o: Validacao       		  							                                    //
//																									//
//==================================================================================================//
//Trim(M->B1_CODGTIN)+EANDigito(Trim(M->B1_CODGTIN))                                                  
//ANDRE SAKAI - 20210223 - Alterado o calculo do digito verificador para usar tamanho fixo de 12 no tamanho do codigo e retirada triger, valida��o est� pela sx3 - vlduser
User function VALIDGTN()
Local lRet  := .T.

if upper(Alltrim(M->B1_CODGTIN)) == "SEM GETIN"
    lRet  := .f.    
endif

Return(lRet)

//Gatilho B1_CODGTIN

User function GATIDGTN()
Local lRet          := .T.
Local oModelB1	    := FWModelActive()
Local cCodGTIN      := ''

Public oView

cCodGTIN := alltrim(upper(oModelB1:GetModel("SB1MASTER"):getValue("B1_CODGTIN")))//carrega a nforma��o do cod pela model

if cCodGTIN == "SEM GETIN"
        //M->B1_CODBAR :=  "SEM GETIN"
    Else 
        cCodGTIN := trim(substr(cCodGTIN,1,12)) //faz o tratamento para tamanho 12
        cCodGTIN += eandigito(cCodGTIN) //ADICIONA O DIGITO VERIFICADOR
        cCodGTIN := PADR(cCodGTIN,15,' ')
        //M->B1_CODBAR := trim(M->B1_CODBAR)+eandigito(trim(M->cCodGTIN))
        M->cCodGTIN := cCodGTIN

            oModelB1:GetModel("SB1MASTER"):LoadValue("B1_CODGTIN", cCodGTIN)

            // RECUPERA A VIEW ATIVA E ATUALIZA (NECESS�RIO PARA EXIBI��O DO CONTE�DO)
            oView := FwViewActive()
            oView:Refresh()

            //A010CodBar(M->B1_CODGTIN,.F.)                                                                                                   
        /*
        oSB1:LoadValue("B1_CODGTIN",cCodGTIN)

        oViewSb1 := fwViewActive()
        oViewSb1:refresh('FORMSB1')
//        oSB1:refresh()
*/
endif

Return(lRet)


//Gatilho B1_CODGTIN
//trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR))
User function GATGTNCB()
Local lRet          := .T.
Local oModelB1	    := FWModelActive()
Local oSB1		    := oModelB1:GetModel('SB1MASTER')
Local lInclui		:= oSB1:GetOperation() == 3
Local lAltera		:= oSB1:GetOperation() == 4

if upper(Alltrim(M->B1_CODBAR)) == "SEM GETIN"
    //M->B1_CODBAR :=  "SEM GETIN"
Else 
    //M->B1_CODBAR := trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR))
    oSB1:LoadValue("B1_CODBAR",trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR)))
endif

Return(lRet)

#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/
    {Protheus.doc} User Function WSINTMS
    @type  Function
    @author Marcos Felipe Xavier
    @since 17/10/2020
    @version 1.000
    @description Funcao responsavel por realizar integracao com o Mobile Sales
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/
/*
User Function AUXTABLE()
	
	Local cEdit1	:= Space(3)
	Local nRGrp		:= 0
	Local oEdit1
	Local oRGrp
	
	Private _oDlg    
	
	//RpcSetType(3)//Nao consome licencas
	PREPARE ENVIRONMENT EMPRESA '04' FILIAL '01'              
	
	DEFINE MSDIALOG _oDlg TITLE "UPDATE DE BANCO DE DADOS" FROM 311,537 TO 431,858 PIXEL
	
		@ 001, 003 TO 056,087 LABEL "Opera��o" PIXEL OF _oDlg
		@ 001, 095 Say "Alias" Size 013,008 COLOR CLR_BLACK PIXEL OF _oDlg
		@ 005, 006 Radio oRGrp Var nRGrp Items "Update Table","Create Table" Size 052,008 PIXEL OF _oDlg
		@ 011, 094 MsGet oEdit1 Var cEdit1 Size 060,009 COLOR CLR_BLACK PIXEL OF _oDlg
		DEFINE SBUTTON FROM 041,129 TYPE 1 ENABLE OF _oDlg ACTION fSelRadio(nRGrp,cEdit1)
	
	ACTIVATE MSDIALOG _oDlg CENTERED 

Return(.T.)

Static Function fSelRadio(nChoice,cxAlias)
	
	Local cStrExec := '' 

	If nChoice == 1
		cStrExec := 'X31UpdTable' 
	Else
		cStrExec := 'DbSelectArea'
	EndIf
	
	cStrExec += '("' + cxAlias + '")'
	
	conout('Expressao gerada:' + cStrExec)
	
	&(cStrExec)
	
	_oDlg:END()

Return
*/



/*/
    {Protheus.doc} trataAmbiente
    @type  Static Function
    @author Marcos Felipe Xavier
    @since 10/07/2020
    @version 1.0.1
    @param oBody, object, Body recebido na requisicao
    @param cSvcName, character, Nome do servico que sera validado
/*/
User Function WSK0001(oBody, cSvcName)
Local aAtribs	:= {}
Local aRet := {.T.,""}	

aAtribs := oBody:GetNames()


if select('TZ09') > 0
    TZ09->(DbCloseArea())
endif

BEGINSQL ALIAS 'TZ09'
    SELECT Z09.Z09_ATIVO,Z08.* 
    FROM %TABLE:Z09% Z09
    INNER JOIN %TABLE:Z08% Z08 ON Z09.Z09_FILIAL = Z08.Z08_FILIAL AND Z09.Z09_CODIGO = Z08.Z08_CODIGO AND Z08.%NOTDEL%
    WHERE Z09.%NOTDEL%
        AND Z09.Z09_FILIAL = %xFilial:Z09%
        AND LOWER(Z09.Z09_NOME) = %EXP:lower(cSvcName)%
        AND Z08_OBRIG = 'S'
        AND Z08_CAMPO NOT LIKE '%.%'
ENDSQL

while ! TZ09->(EoF())
    if ascan(aAtribs,alltrim(TZ09->Z08_CAMPO)) > 0
        if ! TZ09->Z08_TPATRI $ 'A/L' .and. empty(oBody[alltrim(TZ09->Z08_CAMPO)])
            aRet := {.F.,"Campo obrigatorio enviado em branco: " + TZ09->Z08_CAMPO}
            EXIT
        endif
    else
        aRet := {.F.,"Campo obrigatorio nao enviado: " + TZ09->Z08_CAMPO}
        EXIT
    endif

    TZ09->(DbSkip())	
end

Return aRet



// User Function WSK0002()


// Return


User Function WSKAMBI( cTenantId, cUsrPsw, cUserLogin )

    Local cEmpK := ''
    Local cFilK := ''
	Local cBaseEmp := '04'
	Local cBaseFil := '01'

    WSKLOG('Inicio da Rotina de tratativa de ambientes','WSKAMBI')

    /*----------------------------------------------------------------------------------------*\
    | Sempre prepara em uma empresa e filial fixas, apenas pra realizar as validac�es na SM0.  |
    | Posteriormente, caso a empresa e filial recebidas no tenantId sejam v�lidas e diferentes |
	| da prepara��o inicial, � feita uma nova prepa��o.                                        |
    \*----------------------------------------------------------------------------------------*/
    if select("SX6") == 0
        RPCSetType(3)
        RpcSetEnv( cBaseEmp , cBaseFil )
        WSKLOG( 'Primeira prepara��o de ambiente. Empresa: ' + cEmpAnt + ' / Filial: ' + cFilAnt, 'WSKAMBI' )
    endif
   

    /*----------------------------------------------------------------------------------------*\
    | Realiza as validacoes do tenantId                                                        |
    \*----------------------------------------------------------------------------------------*/
    cEmpK := alltrim(substr(cTenantId,1,at(',',cTenantId)-1))
    cFilK := alltrim(substr(cTenantId,at(',',cTenantId)+1))

    Do Case
        Case empty(cEmpK)
            montaErro("Header tenantId enviado no formato incorreto.", 400, 2)
        Case empty(cFilK)
            montaErro("Header tenantId enviado no formato incorreto.", 400, 3)
        Case len(cEmpK) <> len(alltrim(cEmpAnt))
            montaErro("Header tenantId enviado no formato incorreto.", 400, 4)
        Case len(cFilK) <> len(alltrim(cFilAnt))
            montaErro("Header tenantId enviado no formato incorreto.", 400, 5)
    EndCase


    /*--------------------------------------------------------------------------------------*\
    | Realiza a alteracao de empresa e filial, caso necessario                               |
    \*--------------------------------------------------------------------------------------*/
    if lOK .and. (cEmpK <> '04' .or. cFilK <> '01')
        if !ExistCpo("SM0", cEmpK + cFilK)
            montaErro("Empresa/Filial recebidas nao encontradas no sistema. Verificar header tenantId.", 404, 6)
        else
            RpcClearEnv()
            RPCSetType(3)
            RpcSetEnv(cEmpK,cFilK)
            WSKLOG('Segunda preparacao de ambiente. Empresa: ' + cEmpAnt + ' / Filial: ' + cFilAnt,'WSKAMBI')
        endif
    endif

Return



User Function WSKLOG(cMsgLog,cRotina)

    Local cDtHr := dtoc(date()) + ' ' + time()

	Default cRotina := 'EXEC'

    conout( '[' + cDtHr + '] ' + '[' + Upper(cRotina) + '] - ' + cMsgLog)
    
Return

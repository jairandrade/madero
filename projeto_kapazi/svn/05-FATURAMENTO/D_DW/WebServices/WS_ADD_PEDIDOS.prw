#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#Include "TbiConn.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Anexo 1 : Campos disponiveis DWFDV : WS Pedido : Cabecalho �
//�------------------------------------------------------------�
//� Campo							Tamanho	Tipo               �
//�------------------------------------------------------------�
//� codigo							60		char               �
//� filial_codigo					60		char               �
//� condicao_pagamento_codigo		60		char               �
//� forma_pagamento_codigo			60		char               �
//� transportadora_codigo			60		char               �
//� tabela_preco_codigo				60		char               �
//� vendedor_codigo					60		char               �
//� operacao_codigo					60		char               �
//� evento_codigo					60		char               �
//� cliente_codigo					60		char               �
//� frete_codigo					60		char               �
//� observacao_comercial					text               �
//� mensagem_nota_fiscal					text               �
//� ordem_compra					60		char               �
//� data_entrega 							date               �
//� data_emissao							date               �
//� hora_emissao							time               �
//� valor_total_com_impostos				double precision   �
//� valor_total_sem_impostos            	double precision   �
//� valor_total_sem_descontos				double precision   �
//� valor_total_descontos					double precision   �
//� percentual_total_descontos				double precision   �
//� vendedor_percentual_comissao			double precision   �
//� valor_total_comissao					double precision   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Anexo 2 : Campos disponiveis DWFDV : WS Pedido : Itens     �
//�------------------------------------------------------------�
//� Campo							Tamanho	Tipo               �
//�------------------------------------------------------------�
//� numero							60		char               �
//� produto_codigo					60		char               �			
//� quantidade_un_1							double precision   �
//� quantidade_un_2							double precision   �
//� valor_unitario_tabela_preco				double precision   �
//� valor_total_com_impostos				double precision   �
//� valor_total_sem_impostos				double precision   �
//� valor_total_descontos					double precision   �
//� percentual_total_descontos				double precision   �
//� valor_unitario_venda					double precision   �
//� valor_total_sem_descontos				double precision   �
//� comissao_valor							real               �
//� comissao_porcentagem					real               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴敲굇
굇튡rograma  � tAddPedidoCab 튍utor  � Welinton Martins  � Data � 20/12/17볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴묽�
굇튒esc.     � Estrutura do Cabecalho do Pedido de Venda                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튟bs.      � Campos utilizados vide Anexo 1                             볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � WebService Pedido de Venda                                 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
WSSTRUCT tAddPedidoCab

	//--> Cabecalho
	WSDATA CodigoVendedor			As String				//C5_VEND1
	WSDATA CondicaoPagamento		AS String				//C5_CONDPAG
	WSDATA DataEntrega				As Date					//C5_ENTREG
	WSDATA Operacao					As String				//C5_OPER
	WSDATA PedidoCliente			AS String	OPTIONAL	//C5_PEDCLI
	WSDATA Redespacho				AS String	OPTIONAL	//C5_REDESP
	WSDATA TabelaPreco				AS String				//C5_TABELA
	WSDATA TipoFrete				As String				//C5_TPFRETE
	WSDATA Transportadora			AS String				//C5_TRANSP
	WSDATA FilialCodigo				As String				//C5_FILIAL
	WSDATA Observacao				As String	OPTIONAL	//C5_XOBSVEN
	WSDATA MensagemNotaFiscal		As String	OPTIONAL	//C5_MENNOTA
	WSDATA PedidoDW					AS String				//C5_IDDW
	WSDATA Evento					AS String	OPTIONAL	//
	
	WSDATA Frete					AS Float	OPTIONAL	// Luis - C5_FRETE 03-05-18
	WSDATA TipoPedidoKapazi			AS String	OPTIONAL	// Luiz Jacinto C5_K_TPPV 2018-07-13
	
	//--> Itens
	WSDATA tzItensDoPedido			AS Array Of tAddPedidoDet

ENDWSSTRUCT

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴敲굇
굇튡rograma  � tAddPedidoDet 튍utor  � Welinton Martins  � Data � 20/12/17볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴묽�
굇튒esc.     � Estrutura dos Itens do Pedido de Venda                     볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튟bs.      � Campos utilizados vide Anexo 2                             볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � WebService Pedido de Venda                                 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
WSSTRUCT tAddPedidoDet

	WSDATA PrecoVendaProduto		AS Float	//C6_PRCVEN
	WSDATA ValorTabelaPreco			AS Float	//C6_PRCTAB		--> Campo customizado Waleu
	WSDATA ProdutoPedido			AS String	//C6_PRODUTO
	WSDATA QuantidadeProduto		AS Float	//C6_QTDVEN
	WSDATA DescontoValorItem		AS Float	//C6_VALDESC
	WSDATA DescontoPercentualItem	AS Float	//C6_DESCONT
	WSDATA Numero					AS Float	//C6_XITEMDW	--> Campo customizado Waleu
	
	WSDATA Largura					AS Float	//C6_XLARG
	WSDATA Comprim					AS Float	//C6_XCOMPRI
	WSDATA QtdPc					AS Float	//C6_XQTDPC
	
ENDWSSTRUCT

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿐mpresa   � Welinton Martins (11) 99161-8225                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴눙�
굇쿑uncao    � U_WSFDV002� Autor � Welinton Martins     � Data � 20/12/17 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Web Service Server, para integracao do sistema DW Forca de 낢�
굇�          � Vendas (Developweb X Protheus).                            낢�
굇�          � Integracao Pedido de Venda.                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿚bs.      �                                                            낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � U_WSFDV002():New()                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    낢�
굇쳐컴컴컴컴컫컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏ata      � Programador      � Manutencao efetuada                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�  /  /    �                  �                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � WebService Pedido de Venda                                 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
WSSERVICE U_WSFDV002 DESCRIPTION "Integra豫o Developweb X Protheus | Servi�o de inclus�o do Pedido de Venda" // NAMESPACE "http://"

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Campos utilizados pela aplicacao DWFDV �
	//� GET                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	
	//--> Propriedades
	WSDATA CNPJ				AS String
	//--> Estruturas
	WSDATA tAddPedido		AS tAddPedidoCab
	
	//旼컴컴컴컴컴컴컴컴컴컴컴�
	//� Retorno do WebService �
	//� RET                   �
	//읕컴컴컴컴컴컴컴컴컴컴컴�
	WSDATA NumeroDoPedido	AS String
	WSDATA WsStrDel			AS String

	//旼컴컴컴컴컴컴컴컴컴컴컴�
	//� Metodos do WebService �
	//읕컴컴컴컴컴컴컴컴컴컴컴�	
	WSMETHOD AddPedido      DESCRIPTION "M�todo de Inclus�o do Pedido de Venda"

ENDWSSERVICE

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿐mpresa   � Welinton Martins (11) 99161-8225                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴눙�
굇쿑uncao    � AddPedido  � Autor � Welinton Martins    � Data � 20/12/17 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Metodo para Inclusao do Pedido de Venda.                   낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿚bs.      �                                                            낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � oWs := WSU_WSFDV001():New()                                낢�
굇�          � oWs:AddPedido()                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� Vide Anexo 1 e 2 : Estrutura WS Pedido de Venda.           낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    낢�
굇쳐컴컴컴컴컫컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏ata      � Programador      � Manutencao efetuada                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�  /  /    �                  �                                         낢�
굇�          �                  �                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � WebService Pedido de Venda                                 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
WSMETHOD AddPedido WSRECEIVE CNPJ, tAddPedido WSSEND NumeroDoPedido WSSERVICE U_WSFDV002
Local cCNPJ		:=	U_UnMaskCNPJ(::CNPJ)

Local cVend1	:=	::tAddPedido:CodigoVendedor
Local cCondPag	:=	::tAddPedido:CondicaoPagamento
Local dDtEntreg	:=	::tAddPedido:DataEntrega
Local cOperacao	:=	::tAddPedido:Operacao
Local cPedCli	:=	::tAddPedido:PedidoCliente
Local cRedespac	:=	::tAddPedido:Redespacho
Local cTabPrc	:=	::tAddPedido:TabelaPreco
Local cTpFrete	:=	::tAddPedido:TipoFrete
Local cTransp	:=	::tAddPedido:Transportadora
Local cFilPed	:=	::tAddPedido:FilialCodigo
Local cObsPed	:=	::tAddPedido:Observacao
Local cMenNF	:=	::tAddPedido:MensagemNotaFiscal
Local cPedidoDW	:=	::tAddPedido:PedidoDW
Local cEvento	:=	::tAddPedido:Evento		
Local oItsPed	:=	::tAddPedido:tzItensDoPedido

Local cEmpWel	:=	"04"	// Kapazi Ind.
Local cFilWel	:=	cFilPed

Local aArea		:=	{}
Local aAreaA1	:=	{}
Local aAreaB1	:=	{}
Local aAreaC5	:=	{}
Local aAreaC6	:=	{}
Local aAreaC9	:=	{}
	
Local aCab		:=	{}
Local aItens	:=	{}
Local cMsgErro	:=	""
Local cObsWS	:=	""
Local cCodCli	:=	""
Local cLjCli	:=	""
Local lRet		:=	.T.                
Local cFilSA1	:= ""
Local lAtvCD	:= .f.

/*Tratamento de erros*/
Local _nXX		:= 0
Local _cProBlq	:= ""
/*Tratamento de erros*/

Private lMsErroAuto		:=	.F.	// Variavel que define que o help deve ser gravado no arquivo de log e que as informacoes estao vindo a partir da rotina automatica
Private lMsHelpAuto		:=	.T.	// Forca a gravacao das informacoes de erro em array para manipulacao da gravacao ao inves de gravar direto no arquivo temporario
Private lAutoErrNoFile	:=	.T.
Private aAutoErro		:=	{}
Private lAuto			:=	.F.

/*Tratamento de erros*/
Private _cMsblql	:= ""
Private _aArayPB	:= {}
Private _cIdDw		:= ""
Private _lTesV		:= .F.
Private _cTesInt		:= ""
Private _cItenTe 		:= ""

Private _lErrGer		:= .F.
Private _lErrCBr		:= .F. //Erro cliente em branco
Private _lErrCNe		:= .F. //Erro cliente nao Existe na base
Private _lErrCBL		:= .F. //Erro cliente Bloqueado
Private _lErrIIm		:= .F. //Erro ID DW ja importado
Private _lErrCPV		:= .F. //Erro cabecalho do PV(generico)
Private _lErrPBL		:= .F. //Erro Produtos Bloqueados
Private _lErrTes		:= .F. //Erro Tes
Private _lErrIte		:= .F. ////Erro Itens do PV(generico)
Private _lErroPV		:= .F.
Private _lErrVBl		:= .F.

Private _cPedInc		:= ""

Private _cVended		:= ""
Private _lErrFil		:= .f.

/*Tratamento de erros*/

//Tratamento CD
/*
Quando for um pedido da 0401, validar:

1) Cliente: 
	- Ver o campo A1_XFILFAT para ver qual a filial que deve ser faturada.
		- Depois verificar adicionamente
			1.1) Cliente � PJ?
				- sim = 0408 CD, resumo, PJ fatura em qqr filial
				- Nao = 0401, pois nao pode faturar pelo CD
			Obs: Caso esteja divergente, enviar erro pelo WS.
*/


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Estabelece conexao com o Protheus �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
RPCClearEnv()	//-> Reseta ambiente
RPCSetType(3)	//-> Nao consome licenca de uso
If !RPCSetEnv(cEmpWel,cFilWel,,,"FAT",,{"SA1","SA3","SB1","SC5","SC6","SC9"},.F.,.F.)	//-> Set novo ambiente
	cMsgErro 	:=	"[U_WSFDV002] Erro ao tentar estabelecer conexao com a unidade: "+cEmpWel+"-"+cFilWel
	cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	SetSoapFault(ProcName(),cObsWS)
	ConOut(cObsWS)
	
	::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
	lRet := .F.

	DelClassIntf() //-> Exclui todas classes de interface da thread
	RPCClearEnv()
	RESET ENVIRONMENT
	Return(lRet)
Else
	lAuto	:=	.T.
EndIf
 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Tratamento de variaveis locais �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aArea	:=	GetArea()
aAreaA1	:=	SA1->(GetArea())
aAreaB1	:=	SB1->(GetArea())
aAreaC5	:=	SC5->(GetArea())
aAreaC6	:=	SC6->(GetArea())
aAreaC9	:=	SC9->(GetArea())
	
Begin Sequence

ConOut(Repl("-",80))
ConOut("[U_WSFDV002] WebService Pedido de Venda")
ConOut("[U_WSFDV002] Inicio: "+Time()+" Data: "+DtoC(Date()))
ConOut("[U_WSFDV002] Iniciando Metodo ( "+ProcName()+" )")
ConOut("[U_WSFDV002] Numero DW: "+cPedidoDW)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Valida se foi passado o CNPJ do Cliente �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If Empty(cCNPJ)
	/*
	cMsgErro 	:=	"[U_WSFDV002] CNPJ do cliente em branco"
	cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	SetSoapFault(ProcName(),cObsWS)
	ConOut(cObsWS)
	ConOut("[U_WSFDV002] Representante: "+cVend1)
	ConOut("[U_WSFDV002] Numero DW: "+cPedidoDW)
	::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
	lRet := .F.
	Break
	*/
	_lErroPV		:= .T. 	//Erro no PV
	_lErrCBr		:= .T.	//Erro cliente em branco 
EndIf

lAtvCD	:= SuperGetMv("KP_CDOPERA",.F.,.F.) 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Valida se o CNPJ do Cliente esta cadastrado �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
dbSelectArea("SA1")
SA1->(dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_CGC")))
If !SA1->(dbSeek(xFilial("SA1")+cCNPJ))
		/*
		cMsgErro 	:=	"[U_WSFDV002] CNPJ ("+cCNPJ+") nao localizado na base de dados do Protheus"
		cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
		SetSoapFault(ProcName(),cObsWS)
		ConOut(cObsWS)
		
		::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
		lRet := .F.
		Break
		*/
		
		_lErroPV		:= .T. 	//Erro no PV
		_lErrCNe		:= .T. //Erro cliente nao Existe na base

	Else
		If Alltrim(SA1->A1_MSBLQL) == '1'
			/*
			cMsgErro 	:=	"CLIENTE BLOQUEADO("+SA1->A1_COD+")!! Verificar!!!"
			cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
			SetSoapFault(ProcName(),cObsWS)
			ConOut(cObsWS)
			
			::NumeroDoPedido := "Erro na inclusao do pedido. " + cObsWS
			lRet := .F.
			Break
			*/
			_lErroPV		:= .T. 	//Erro no PV
			_lErrCBL		:= .T. //Erro cliente Bloqueado
		EndIf

		cFilSA1	:= Alltrim(SA1->A1_XFILFAT)
		
		If lAtvCD .And. !_lErroPV//Ativa a operacao do CD?

			Conout("")
			//COnout("------------ FATURAMENTO PELO CD ESTA ATIVO ------------")
			//COnout("Empresa enviada: " + cEmpWel)
			//COnout("Filial enviada: " + cFilWel)
			COnout("Filial de faturamento: " + cFilSA1)
			Conout("")	

			If !Empty(cFilSA1)
				
					If Alltrim(SA1->A1_PESSOA) == "J" //Juridica
							//Validar a filial correta
							If Alltrim(cEmpWel) == "04" .And. Alltrim(cFilWel) $ "01/08"
								/*
								If Alltrim(cFilSA1) != Alltrim(cFilWel)
									_lErroPV		:= .T. 	//Erro no PV
									_lErrFil		:= .t.	//Cliente com problema de cadastro na filial
								EndIf
								*/
							EndIf

						ElseIf Alltrim(SA1->A1_PESSOA) == "F" //Fisica
							If Alltrim(cEmpWel) == "04" .And. Alltrim(cFilSA1) == "08"
								_lErroPV		:= .T. 	//Erro no PV
								_lErrFil		:= .t.	//Cliente com problema de cadastro na filial - 
							EndIf

							If Alltrim(cEmpWel) == "04" .And. Alltrim(cFilWel) == "08"
								_lErroPV		:= .T. 	//Erro no PV
								_lErrFil		:= .t.	//Cliente com problema de cadastro na filial - 
							EndIf
						
						Else //Campo em branco

					EndIf
				
				Else 
					//_lErroPV		:= .T. 	//Erro no PV
					//_lErrFil		:= .t.	//Cliente com problema de cadastro na filial -
			EndIf

		EndIf
EndIf

ConOut("")
ConOut("Cliente ->>> " + SA1->A1_COD)
ConOut("[U_WSFDV002] CNPJ Cliente "+Transform(cCNPJ,IIf(Len(cCNPJ)<14,"@R 999.999.999-99","@R 99.999.999/9999-99")))
ConOut("[U_WSFDV002] UF Cliente "+SA1->A1_EST)
ConOut("[U_WSFDV002] Empresa Trabalho "+cEmpAnt)
ConOut("[U_WSFDV002] Filial Trabalho "+cFilAnt)
ConOut("")


If lAtvCD //Ativa a operacao do CD?
	
	If !_lErroPV .And. !_lErrFil .And. !Empty(cFilSA1) //nao tem erro
		
		If (Alltrim(cEmpWel) == "04" .And. Alltrim(cFilWel) == "01" .And. Alltrim(cFilSA1) == "08") 
			
			RPCClearEnv()	//-> Reseta ambiente
			RPCSetType(3)	//-> Nao consome licenca de uso
			If !RPCSetEnv(cEmpWel,cFilSA1,,,"FAT",,{"SA1","SA3","SB1","SC5","SC6","SC9"},.F.,.F.)	//-> Set novo ambiente
					cMsgErro 	:=	"[U_WSFDV002] Erro ao tentar estabelecer conexao com a unidade: "+cEmpWel+"-"+cFilSA1
					cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
					SetSoapFault(ProcName(),cObsWS)
					ConOut(cObsWS)
					
					::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
					lRet := .F.

					DelClassIntf() //-> Exclui todas classes de interface da thread
					RPCClearEnv()
					RESET ENVIRONMENT
					Return(lRet)
				Else
					lAuto	:=	.T.

					dbSelectArea("SA1")
					SA1->(dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_CGC")))
					SA1->(dbSeek(xFilial("SA1")+cCNPJ))

			EndIf	

		EndIf

	EndIf 

EndIf


//旼컴컴컴컴컴컴컴컴컴컴컴컴�
//� Atribuicao de variaveis �
//읕컴컴컴컴컴컴컴컴컴컴컴컴�
cCodCli	:=	SA1->A1_COD
cLjCli	:=	SA1->A1_LOJA

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Atualizacao do Cabecalho do Pedido de Venda �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
lRet := PutPvHead(::tAddPedido,@aCab,cCodCli,cLjCli)

If !lRet
	
	If !Empty(_cVended) //Vendedor bloqueado
		_lErroPV		:= .T. 	//Erro no PV
		_lErrVBl		:= .T. //Erro ID ja imputado no sistema
	EndIf
	
	If Empty(_cVended)
		/*
		cMsgErro 	:=	"[U_WSFDV002] Problema no cabecalho do pedido"
		cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
		SetSoapFault(ProcName(),cObsWS)
		ConOut(cObsWS)
		::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
		Break
		*/
		
		_lErroPV		:= .T. 	//Erro no PV
		_lErrCPV		:= .T. //Erro cabecalho do pedido
	EndIf
	
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Atualizacao dos Itens do Pedido de Venda �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
lRet := PutPvItem(::tAddPedido,::tAddPedido:tzItensDoPedido,@aItens)

If !lRet
	
	If Len(_aArayPB) > 0
		For _nXX := 1 To Len(_aArayPB) //Array dos produtos bloqueados
			_cProBlq += _aArayPB[_nXX] + "/"
		Next
		
		/*
		cMsgErro 	:=	"[U_WSFDV002] Pedido possui itens com PRODUTO BLOQUEADO("+_cProBlq+")"
		cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
		SetSoapFault(ProcName(),cObsWS)
		ConOut(cObsWS)
		*/
		_lErroPV		:= .T. 	//Erro no PV
		_lErrPBL		:= .T. //Erro Pedido possui itens com PRODUTO BLOQUEADO
	EndIf		
	
	If _lTesV
		/*
		cMsgErro 	:=	"[U_WSFDV002] Pedido possui itens sem TES("+_cItenTe+")"
		cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
		SetSoapFault(ProcName(),cObsWS)
		ConOut(cObsWS)
		*/
		
		_lErroPV		:= .T. 	//Erro no PV
		_lErrTes		:= .T. //Erro Pedido possui itens sem TES
	EndIf			
	
	If !_lTesV .And. Len(_aArayPB) == 0
		/*
		cMsgErro 	:=	"[U_WSFDV002] Problema nos itens do pedido"
		cObsWS 		:=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
		SetSoapFault(ProcName(),cObsWS)
		ConOut(cObsWS)
		*/
		_lErroPV		:= .T. 	//Erro no PV
		_lErrIte		:= .T. //Erro Problema nos itens do pedido generico
			
	EndIf
	//Break
EndIf

/* TRATAMENTOS DOS ERROS */
If _lErroPV //Deu Erro no PV
	
	If _lErrCBr	//Erro cliente em branco 
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] CNPJ do cliente em branco"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
		ConOut("[U_WSFDV002] Representante: "+cVend1)
		ConOut("[U_WSFDV002] Numero DW: "+cPedidoDW)
	EndIf
	
	If _lErrCNe	//Erro cliente nao Existe na base
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] CNPJ ("+cCNPJ+") nao localizado na base de dados do Protheus"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	If _lErrCBL //Erro cliente Bloqueado
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"CLIENTE BLOQUEADO("+SA1->A1_COD+")!! Verificar!!!"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	/*
	If _lErrIIm //Erro ID ja imputado no sistema
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] Problema! existe um ID ja imputado no sistema! Verificar!!"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	*/
	If _lErrCPV //Erro cabecalho do pedido
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] Problema no cabecalho do pedido"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	If _lErrPBL //Erro Pedido possui itens com PRODUTO BLOQUEADO
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] Pedido possui itens com PRODUTO BLOQUEADO("+_cProBlq+")"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	If _lErrTes //Erro Pedido possui itens sem TES
		cMsgErro	+= CRLF
		cObsWS		+= CRLF

		cMsgErro 	+=	"[U_WSFDV002] Pedido possui itens sem TES("+_cItenTe+")"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	If _lErrIte //Erro Problema nos itens do pedido generico
		cMsgErro	+= CRLF
		cObsWS	+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] Problema nos itens do pedido"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	If _lErrVBl //Erro de vendedor bloqueado/inexistente
		cMsgErro	+= CRLF
		cObsWS		+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] Vendedor do Pedido Bloqueado("+_cVended+")!!!"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
	EndIf
	
	If _lErrFil
		cMsgErro	+= CRLF
		cObsWS	+= CRLF
		
		cMsgErro 	+=	"[U_WSFDV002] Cliente com problema no vinculo por filial"
		cObsWS 		+=	AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)	
	EndIf 

	ConOut(cObsWS)

	GrvLgDw(AllTrim(::tAddPedido:PedidoDW), Date(),Time(),cObsWS)

	SetSoapFault(ProcName(),cObsWS)
	
	//::NumeroDoPedido := "Erro na inclusao do pedido. " + cObsWS
	lRet := .F.
	Break
EndIf		
/* FIM DOS TRATAMENTOS DOS ERROS */

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Efetiva a Inclusao do Pedido de Venda �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//Conout("")
//VARINFO ("aItens",aItens)
//Conout("")

If !_lErroPV //Sem erros

	If ValiIDDw() //Valida se pode incluir o PV 

			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCab,aItens,3) //-> 3=Inclusao; 4=Alteracao; 5=Exclusao

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Verifica a ocorrencia de erros na incluso do pedido �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			If lMsErroAuto
					/*
					conout("")
					conout(varinfo("aCab",aCab))
					conout("")
					conout(varinfo("aItens",aItens))
					conout("")
					*/
					aAutoErro 	:= GetAutoGRLog()
					
					cObsWS := MostraErro("\") + CRLF
					
					cObsWS 		:= cObsWS + AllTrim(U_xDatAt()+" [ERRO] "+U_xConverrLog(aAutoErro))
					
					Conout("")
					ConOut(cObsWS)
					Conout("")

					GrvLgDw(AllTrim(::tAddPedido:PedidoDW), Date(),Time(),cObsWS)

					SetSoapFault(ProcName(),cObsWS)

					//::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
					lRet := .F.
					Break
				Else
					_cPedInc	:= SC5->C5_NUM

					Conout("")
					Conout("Pedido incluido com sucesso --> " + ::tAddPedido:PedidoDW + " -  Numero: " + _cPedInc)
					Conout("")
					GrvLgDw(AllTrim(::tAddPedido:PedidoDW), Date(),Time(),"Pedido " + _cPedInc + " incluido com sucesso!!!")
			EndIf

			If Empty(_cPedInc) .And. !lMsErroAuto
					cMsgErro 	+= "[U_WSFDV002] Pedido nao localizado apos a inclusao("+_cPedInc+"-lMsErroAuto)"
					cObsWS 		+= AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
					
					ConOut(cObsWS)
					SetSoapFault(ProcName(),cObsWS)
					//::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS

					lRet := .F.
					Break
				
				ElseIf !Empty(_cPedInc) .And. !lMsErroAuto
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//� Verifica se o registro foi realmente incluido �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					::NumeroDoPedido := _cPedInc //SC5->C5_FILIAL+SC5->C5_NUM
				
					ConOut("[U_WSFDV002] Pedido incluido com sucesso!")
					ConOut("[U_WSFDV002] Filial: "+SC5->C5_FILIAL+" Pedido: "+SC5->C5_NUM)
					/*
					SC5->(dbSetOrder(RetOrder("SC5","C5_FILIAL+C5_NUM")))
					If SC5->(dbSeek(SC5->C5_FILIAL+_cPedInc))
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
						//� Alimenta Retorno do WS com a Filial e Numero do Pedido. �
						//� Indicando que a integracao foi realizada com sucesso!   �
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
						::NumeroDoPedido := SC5->C5_NUM //SC5->C5_FILIAL+SC5->C5_NUM
				
						ConOut("[U_WSFDV002] Pedido incluido com sucesso!")
						ConOut("[U_WSFDV002] Filial: "+SC5->C5_FILIAL+" Pedido: "+SC5->C5_NUM)
					Else
						cMsgErro 	:= "[U_WSFDV002] Pedido nao localizado apos a inclusao NA SC5!!!"
						cObsWS 		:= AllTrim(U_xDatAt()+" [ERRO] "+cMsgErro)
						
						ConOut(cObsWS)
						SetSoapFault(ProcName(),cObsWS)
						//::NumeroDoPedido := "Erro ao realizar a inclusao do pedido. " + cObsWS
						
						lRet := .F.
						Break
					EndIf
					*/
			EndIf

		Else //J� existe o ID
			::NumeroDoPedido := SC5->C5_NUM //SC5->C5_FILIAL+SC5->C5_NUM
			ConOut("[KAPAZI] Pedido DW j� existe na base!!!!!!")
			ConOut("[KAPAZI] Filial: "+ SC5->C5_FILIAL +" Pedido: " + SC5->C5_NUM)

			GrvLgDw(AllTrim(::tAddPedido:PedidoDW), Date(),Time(),"Pedido j� existe na base -> "+ SC5->C5_NUM + " -  ID -> " +::tAddPedido:PedidoDW) ///_cIdDw

	EndIf

EndIf

End Sequence
RestArea(aArea)
RestArea(aAreaA1)
RestArea(aAreaB1)
RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)

ConOut("[U_WSFDV002] Fim: "+Time()+" Data: "+DtoC(Date()))
ConOut(Repl("-",80))
	
If lAuto
	DelClassIntf() //-> Exclui todas classes de interface da thread
	RpcClearEnv()
	RESET ENVIRONMENT
EndIf

Return(lRet)

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴컴엽�
굇쿑uncao    � PutPvHead � Autor � Welinton Martins   � Data � 20/12/17   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴컴눙�
굇쿏escricao � Monta o cabecalho do Pedido de Venda.                      낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � PutPvHead(oObj,aCab,cCliente,cLoja)                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oObj  	: Objeto contendo dados recebidos pelo WS         낢�
굇�          � aCab 	: Variavel utilizada para armazenar cabecalho PDV 낢�
굇�          � cCliente	: Codigo do Cliente                               낢�
굇�          � cLoja 	: Loja do Cliente                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿚bservacao�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � WebService Pedido de Venda                                 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
Static Function PutPvHead(oObj,aCab,cCliente,cLoja)

Local aArea			:=	GetArea()
Local cMsgNF		:=	IIf(FindFunction("U_FRemAcento"),U_FRemAcento(oObj:MensagemNotaFiscal),FwNoAccent(oObj:MensagemNotaFiscal))
Local lRet			:=	.T.
Local dDtEntrega	:=	DataValida(oObj:DataEntrega,.T.)
Local cK_TPCL		:=	"000056"	//-> A Segmentar
Local cTPPVDW		:= Alltrim( SuperGetMV("KP_TPPVDW"	,.F. ,"001"))

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Atualizacao do cabecalho do pedido de venda �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//--> Campos fixos
aAdd( aCab , { "C5_FILIAL"	, xFilial("SC5")	   					, NIL } )
aAdd( aCab , { "C5_EMISSAO"	, dDataBase      						, NIL } )
aAdd( aCab , { "C5_TIPO"	, "N"									, NIL } )
//--> Campos de variaveis
aAdd( aCab , { "C5_CLIENTE"	, cCliente	 			 				, NIL } )
aAdd( aCab , { "C5_LOJACLI"	, cLoja									, NIL } )
aAdd( aCab , { "C5_CLIENT"	, cCliente								, NIL } )
aAdd( aCab , { "C5_LOJAENT"	, cLoja									, NIL } )

//--> Campos do WS
If SC5->(FieldPos("C5_K_OPER")) > 0
	//-> Tipo de Operacao: 01-Venda 08-Bonificacao
	aAdd( aCab , { "C5_K_OPER"	, AllTrim(oObj:Operacao)			, NIL } )
EndIf
If SC5->(FieldPos("C5_K_TPCL")) > 0
	aAdd( aCab , { "C5_K_TPCL"	, cK_TPCL							, NIL } )
EndIf
aAdd( aCab , { "C5_TABELA"	, AllTrim(oObj:TabelaPreco)				, NIL } )
aAdd( aCab , { "C5_CONDPAG"	, AllTrim(oObj:CondicaoPagamento)		, NIL } )
aAdd( aCab , { "C5_VEND1"	, AllTrim(oObj:CodigoVendedor)			, NIL } )
aAdd( aCab , { "C5_TPFRETE"	, Upper(oObj:TipoFrete)					, NIL } )

aAdd( aCab , { "C5_FRETE"	, oObj:Frete							, NIL } ) //Adicionado Luis 03-05-18
If SC5->( FieldPos("C5_K_TPPV")) >0
	//  1=Produtos Kapazi;2=Redes atacadistas;3=Pv Especiais;4=Pv Exporta豫o;5=Pv Varejo
	aAdd( aCab , { "C5_K_TPPV"	, oObj:Evento						, NIL } ) //Adicionado Luiz 2018-07-13
Endif

aAdd( aCab , { "C5_TRANSP"	, AllTrim(oObj:Transportadora)			, NIL } )
aAdd( aCab , { "C5_REDESP"	, AllTrim(oObj:Redespacho)				, NIL } )
aAdd( aCab , { "C5_FECENT"	, dDtEntrega							, NIL } )
aAdd( aCab , { "C5_PEDCLI"	, AllTrim(oObj:PedidoCliente)			, NIL } )
aAdd( aCab , { "C5_MENNOTA"	, cMsgNF 								, NIL } )
If SC5->(FieldPos("C5_MSGNOTA")) > 0
	aAdd( aCab , { "C5_MSGNOTA"	, cMsgNF							, NIL } )
EndIf
If SC5->(FieldPos("C5_MSGCLI")) > 0
	aAdd( aCab , { "C5_MSGCLI"	, IIf(FindFunction("U_FRemAcento"),;
	U_FRemAcento(oObj:Observacao),FwNoAccent(oObj:Observacao))		, NIL } )
EndIf
If SC5->(FieldPos("C5_IDDW")) > 0
	aAdd( aCab , { "C5_IDDW"	, AllTrim(oObj:PedidoDW)			, NIL } )
EndIf

If SC5->(FieldPos("C5_XTPPED")) > 0
	aAdd( aCab , { "C5_XTPPED"	, cTPPVDW			, NIL } )
EndIf

 _cIdDw		:= AllTrim(oObj:PedidoDW)

_cVended 	:=  AllTrim(oObj:CodigoVendedor)

If !ValVendK()
		lRet := .F.
	Else
		_cVended := ""
EndIf
			      
aCab := WsAutoOpc( @aCab )

RestArea(aArea)

Return(lRet)

//valida se o vendedor
Static Function ValVendK()
Local lRet		:= .T.
Local cQry		:= ""
Local cAliasVE	:= GetNextAlias()

cQry	+= " SELECT *
cQry	+= " FROM SA3010
cQry	+= " WHERE A3_COD = '"+_cVended+"'
cQry	+= " AND D_E_L_E_T_ = '' "

TcQuery cQry New Alias (cAliasVE)

DbSelectArea((cAliasVE))
(cAliasVE)->(DbGoTop())

If (cAliasVE)->(EOF()) //Ja existe o id 
		lRet := .F.
	Else
		If Alltrim((cAliasVE)->A3_MSBLQL) == '1' //Vendedor Bloqueado
			lRet := .F.
		EndIf
EndIf


(cAliasVE)->(DbCloseArea())
Return(lRet)


//valida se o ID ja existe na base
Static Function ValiIdDW()
Local lRet		:= .T.
Local cQry		:= ""
Local cAliasID	:= GetNextAlias()

cQry	+= " SELECT R_E_C_N_O_ AS RECORECO,*
cQry	+= " FROM SC5040
cQry	+= " WHERE C5_IDDW = '"+_cIdDw+"'
cQry	+= " AND D_E_L_E_T_ = '' "

TcQuery cQry New Alias (cAliasID)

DbSelectArea((cAliasID))
(cAliasID)->(DbGoTop())

If !(cAliasID)->(EOF()) //Ja existe o id 
	lRet := .F.

	DbSelectArea("SC5")
	SC5->(DbGotop())
	SC5->(DbGoto((cAliasID)->RECORECO))
EndIf

(cAliasID)->(DbCloseArea())
Return(lRet)




/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴컴엽�
굇쿑uncao    � PutPvItem � Autor � Welinton Martins   � Data � 20/12/17   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴컴눙�
굇쿏escricao � Monta os itens do Pedido de Venda.                         낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � PutPvItem(oObjSC5,oObjSC6,aItens)                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oObjSC5  : Objeto contendo dados do cabecalho recebidos WS 낢�
굇�          � oObjSC6 	: Objeto contendo dados dos itens recebidos WS    낢�
굇�          � aItens	: Variavel utilizada para armazenar os itens PDV  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿚bservacao�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � WebService Pedido de Venda                                 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
Static Function PutPvItem(oObjSC5,oObjSC6,aItens)
Local aArea		:=	GetArea()
Local aItem		:=	{}
Local cItemSeq	:=	Replicate("0",GetSx3Cache("C6_ITEM","X3_TAMANHO"))
Local lRet		:=	.T.
Local nItem		:=	0
Local nItens	:=	0
Local cUm		:= ""
Local cSegUm	:= ""
Local aConv		:= {}
Local cProduto	:= ""
Local nComp		:= 0
Local nLarg		:= 0
Local nQtde1	:= 0
Local nQtde2	:= 0
Local nPc		:= 0
Local nPrcVen	:= 0
Local lConv		:= StaticCall(M521CART,TGetMv,"  ","KA_DWCNVRL","L",.T.,"WS_ADD_PEDIDOS WS Ativa conversao de rolo para m2 na entrada de pedido pelo app DW" )

nItens := Len(oObjSC6)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Atualizacao dos itens do pedido de venda �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
For nItem := 1 To nItens
	aItem 		:= {}
	_cTesInt	:= ""
	
	If !Empty(oObjSC6[nItem]:ProdutoPedido)
		
		_cMsblql	:= POSICIONE("SB1", 1, xFilial("SB1") + oObjSC6[nItem]:ProdutoPedido, "B1_MSBLQL")
		
		If Alltrim(_cMsblql) == "1" //Bloqueado
			lRet :=	.F.
			//Exit //Sai do For
			aAdd(_aArayPB,oObjSC6[nItem]:ProdutoPedido)
		EndIf
		
		cItemSeq:= Soma1(cItemSeq)
		cUm		:= POSICIONE("SB1", 1, xFilial("SB1") + oObjSC6[nItem]:ProdutoPedido, "B1_UM")
		cSegUm	:= POSICIONE("SB1", 1, xFilial("SB1") + oObjSC6[nItem]:ProdutoPedido, "B1_SEGUM")
		cProduto:= oObjSC6[nItem]:ProdutoPedido
		nQtde1	:= oObjSC6[nItem]:QuantidadeProduto
		nQtde2	:= 0
		nLarg	:= oObjSC6[nItem]:Largura
		nComp	:= oObjSC6[nItem]:Comprim
		nPc		:= oObjSC6[nItem]:QtdPc
		nPrcVen	:= oObjSC6[nItem]:PrecoVendaProduto
		
		//--> Campos fixos
		aAdd( aItem , { "C6_ITEM"  		, cItemSeq	, NIL } )
		//--> Campos do WS
		aAdd( aItem , { "C6_PRODUTO"	, cProduto	, NIL } )
		
		// se converte rolo para m2
		if lConv 
			// chama a conversao
			aConv	:= ConvRolo(cProduto,nQtde1,nLarg,nComp,nPc,nPrcVen)
			// se retornou algo
			If !Empty(aConv)
				// atualiza os campos 
				nQtde1	:= aConv[1]
				cUm		:= aConv[2]
				nQtde2	:= aConv[3]
				cSegUm	:= aConv[4]
				nComp	:= aConv[5]
				nLarg	:= aConv[6]
				nPc		:= nQtde2
				If aConv[7] > 0
					nPrcVen	:= aConv[7]
				Endif
			Endif	
		Endif
		
		// adiciona quantidade primeiro para gatilhos nao alterarem a quantidade de pecas
		// depois que informar os dados do m2 
		aAdd( aItem , { "C6_QTDVEN"  	, nQtde1								, NIL } )
		
		// se usa m2
		If Alltrim(cUm) == "M2"
			aAdd( aItem , { "C6_XLARG"  	, nLarg			, NIL } ) //Adicionado Posteriormente
			aAdd( aItem , { "C6_XCOMPRI"  	, nComp			, NIL } ) //Adicionado Posteriormente
			aAdd( aItem , { "C6_XQTDPC"  	, nPc			, NIL } ) //Adicionado Posteriormente
		EndIf
		
		aAdd( aItem , { "C6_OPER"  		, AllTrim(oObjSC5:Operacao)				, NIL } )
		aAdd( aItem , { "C6_PRCVEN"  	, nPrcVen								, NIL } )
		aAdd( aItem , { "C6_DESCONT"  	, oObjSC6[nItem]:DescontoPercentualItem	, NIL } )
		aAdd( aItem , { "C6_VALDESC"  	, oObjSC6[nItem]:DescontoValorItem		, NIL } ) //Adicionado Posteriormente
		
		If SC6->( FieldPos("C6_XITEMDW") ) > 0
			aAdd( aItem , { "C6_XITEMDW", oObjSC6[nItem]:Numero					, NIL } )
		EndIf
				
		aItem := WsAutoOpc( @aItem , .T. )   

		aAdd(aItens,aItem)
	
		_cTesInt := MaTesInt(2,AllTrim(oObjSC5:Operacao),SA1->A1_COD,SA1->A1_LOJA,"C",cProduto,)
		
		//Conout("")
		//Conout("Item ->" + cItemSeq + " - TES -> "+_cTesInt)
		/*
		If Empty(_cTesInt)
			_lTesV	:= .T.
			_cItenTe += cItemSeq+"-"+cProduto + " / "
			lRet := .f.
		EndIf
		*/	
	EndIf
	
	          
	//cTesInt := MaTesInt( 2,Padr("6",2)	,cCliente	,cLoja	, "C",SB1->B1_COD	,NIL)
	//cTesPed := MaTESInt(2, "01", SC5->C5_CLIENTE, SC5->C5_LOJACLI, "C", SB1->B1_COD)
	//cTesInt := MaTesInt( 2	,cTpOper	,cCliente, cLojaCli,"C",SBI->BI_COD,NIL)
	
Next nItem

RestArea(aArea)
Return(lRet)

/*
Converte o rolo recebido pelo portal para m2
Parametros: 
	cProduto -> codigo do produto
	nQtde 	 -> quantidade do produto na segunda unidade de medida
	_nLarg 	 -> largura recebida do portal
	_nComp 	 -> comprimento recebido do portal
	_nPc 	 -> qtde de peca recebida do porta
	_nPrcVen -> Preco de venda em rolo

Retorno -> Array(6) ou Array(vazio)
	aRet[1] := Qtde primeira unidade de medida c6_qtdven
	aRet[2] := Primeira unidade de medida
	aRet[3] := Qtde segunda unidade de medida 
	aRet[4] := Segunda unidade de medida
	aRet[5] := Comprimento 
	aRet[6] := Largura de acordo com o codigo do produto
	aRet[7] := Preco de venda em m2
*/
Static Function ConvRolo(cProduto,nQtde,_nLarg,_nComp,_nPc,_nPrcVen)
	Local 	aArea	:= GetArea()
	Local 	aRet	:= {}
	Local	lRet	:= .T.
	Local	nQtd1	:= 0
	Local	nQtdDec	:= TamSx3("C6_QTDVEN")[2]
	Local	nLarg	:= 0
	Local	nComp	:= 0
	Local	nPrc	:= 0
	
	Default cProduto:= ""
	Default nQtde	:= 0
	Default _nLarg	:= 0
	Default _nComp	:= 0
	Default _nPc	:= 0
	Default _nPrcVen:= 0
	
	// se nao recebeu campos obrigatorios
	if Empty(AllTrim(cProduto)) .or. nQtde == 0
		Return aRet
	Endif
	
	// se recebeu dimensoes do item do pedido
	if _nLarg > 0 .or. _nComp > 0 .or. _nPc > 0
		lRet := .F.
	Endif
	
	if lRet
		SB1->( DbSetOrder(1) )
		// se o produto nao existe
		If !SB1->( MsSeek(xFilial("SB1")+cProduto))
			lRet := .F.
		Endif
	Endif
	
	// se o produto nao usa a segunda unidade de medida
	If lRet .and. SB1->B1_XUSGUM <> "S"
		lRet := .F.
	Endif
	
	// se o produto nao usa M2 e RL 
	If lRet .and. !( SB1->B1_UM == "M2" .AND. SB1->B1_SEGUM == "RL" )
		lRet := .F.
	Endif
	
	// se fator de conversao nao preenchido
	If lRet .and. SB1->B1_CONV == 0
		lRet := .F.
	Endif
	
	if lRet
		// convum(produto,qtde1aunidade,qtde2aunidade,qualUMretornar)
		nQtd1 := Round( ConvUm(SB1->B1_COD,0,nQtde,1),nQtdDec )
		
		// se retornou algo
		if nQtd1 > 0
			// comprimento fixo
			nComp	:= 15
			// obtem a largura
			nLarg	:= GetLarg(cProduto)
			// recebeu preco
			if _nPrcVen > 0
				// converte o preco
				nPrc	:= A410Arred(_nPrcVen / SB1->B1_CONV,"C6_PRCVEN")
			Endif	
			// monta retorno
			aadd(aRet,nQtd1			) // 1 qtde 1 unidade de medida
			aadd(aRet,SB1->B1_UM	) // 2 unidade de medida
			aadd(aRet,nQtde			) // 3 qtde 2 unidade de medida
			aadd(aRet,SB1->B1_SEGUM	) // 4 segunda unidade de medida
			aadd(aRet,nComp			) // 5 comprimento
			aadd(aRet,nLarg			) // 6 largura
			aadd(aRet,nPrc			) // 7 preco convertido
			
		Endif
	Endif
	
	RestArea(aArea)
Return aRet

Static Function GetLarg(cProduto)
	Local 	nRet	:= 0
	Local	cRaiz	:= ""
	
	Default	cProduto:= ""
	
	If Empty(AllTrim(cProduto))
		Return nRet
	Endif
	
	cRaiz := Substr(cProduto,1,4)
	
	If cRaiz == "0201"
		nRet := 0.43
	Endif
	
	If cRaiz == "0202"
		nRet := 0.65
	Endif
	
	If cRaiz == "0203"
		nRet := 1.30 
	Endif
	
Return nRet

/*
funcao de teste da conversao de rolo para m2
*/
User Function TConvRol()
	Local	lEnv 	:= StaticCall(KAP_WF03,environmentActions,1,"04","01",,,"04",{"SB1"})
	Local	aRet	:= {}
	Local	cProduto:= "020100068"

	// converte 1 rolo
	aRet := ConvRolo(cProduto, 1, 0, 0, 0, 153.31)
	
	// nao converte
	aRet := ConvRolo(cProduto, 6.45, 0.43, 15, 1, 23.77)

	cProduto := "0201MUCZ"
	
	// converte 1 rolo
	aRet := ConvRolo(cProduto, 1, 0, 0, 0, 153.31)
	
	// nao converte
	aRet := ConvRolo(cProduto, 6.45, 0.43, 15, 1, 23.77)

	IF lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif
Return

//Funcao responsavel por gravar logs das operacoes
Static Function GrvLgDw(cIDDW, dData,cHrDw,cObsDw)
DbSelectArea("ZDW")
ZDW->(DbSetOrder(1))
 
Reclock("ZDW",.t.)
ZDW->ZDW_FILIAL	:=  xFilial("SC5")
ZDW->ZDW_IDDW  	:= cIDDW
ZDW->ZDW_DATA  	:= dData
ZDW->ZDW_HORA  	:= cHrDw
ZDW->ZDW_MSG  	:= cObsDw
ZDW->(MsUnlock())

Conout("")
Conout("Log Gravado com SUcesso!!!")
Conout("")

Return()

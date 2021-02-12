#Include 'Protheus.ch'

/*/{Protheus.doc} MA415COR
//TODO Alterar cores do browse do cadastro de status do or�amento.
Este ponto de entrada pertence � rotina de atualiza��o de or�amentos de venda, 
MATA415(). Usado, em conjunto com o ponto MA415LEG, para alterar cores do �browse� 
do cadastro, que representam o �status� do or�amento..
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MA415COR()

	Local aNovCor :=  {}

	aNovCor := {{ "SCJ->CJ_STATUS=='A'  .and. SCJ->CJ_XAPROVA == '1' " , "BR_AZUL"   },;//Pendente de aprova��o no Fluig
				{ "SCJ->CJ_STATUS=='A'  .and. SCJ->CJ_XAPROVA == '2' " , "ENABLE"    },; //Aprovado pelo Fraqeuado (FLUIG)
				{ "SCJ->CJ_STATUS=='A'  .and. SCJ->CJ_XAPROVA == '3' " , "BR_LARANJA"},; //Cancelado pelo Franqueado (FLUIG)
				{ 'SCJ->CJ_STATUS=="B"' , 'DISABLE'},;		//Orcamento Baixado
				{ 'SCJ->CJ_STATUS=="C"' , 'BR_PRETO'},;		//Orcamento Cancelado
				{ 'SCJ->CJ_STATUS=="D"' , 'BR_AMARELO'},;	//Orcamento nao Orcado
				{ 'SCJ->CJ_STATUS=="F"' , 'BR_MARROM' }}	//Orcamento bloqueado

Return aNovCor
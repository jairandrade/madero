#include 'protheus.ch'
#include 'parmtype.ch'

//Teste dia 14/01/2019
//tESTE 5
user function GatAtf01()

oModelx := fwModelActive()

oModelxMo := oModelx:getModel('SN1MASTER')

oModelxMo:loadValue('N1_ITEM', strZero(val(allTrim(oModelxMo:getValue('N1_ITEM'))) ,4 ,0) )

oView := fwViewActive()

oView:refresh()

return strZero(val(allTrim(oModelxMo:getValue('N1_ITEM'))), 4, 0) 

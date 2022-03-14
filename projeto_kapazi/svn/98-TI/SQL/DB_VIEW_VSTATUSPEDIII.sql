--USE [P12_PROD]
--GO

/****** Object:  View [dbo].[VSTATUSPEDII]    Script Date: 22/04/2019 10:58:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VSTATUSPEDIII]
AS

-------------------------------------------------------------------------------------INDUSTRIA-----------------------------------------------------------------------------------------------------
---------------------CRIADA EM: 17/04/2019----------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------
---------------------ALTERADA EM: 18/04/2019--------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------

	SELECT
		'KI' AS 'EMPRESA',
		'04' AS 'C5_EMPRESA',
		a.C5_FILIAL AS 'FILIAL',
		a.C5_NUM AS 'PEDIDO',
		a.C5_CLIENTE AS 'CLIENTE',
		b.A1_NOME AS 'RAZ�O SOCIAL',
		b.A1_EST AS 'ESTADO',
		b.A1_MUN AS 'CIDADE',
		a.C5_XTOTMER AS 'VALOR PDV',
		a.C5_PBRUTO AS 'PESO BRUTO',
		a.C5_VOLUME1 AS 'VOLUME',
		ISNULL(f.A4_COD,'') AS 'TRANSP',
		ISNULL(f.A4_NOME,'') AS 'NOME TRANSP',
		a.C5_XTPPED AS 'TIPO PDV',
		c.ZF_CODIGO AS 'STATUS',
		c.ZF_STATUS AS 'DESCRI��O STATUS',
		ZF_OBS AS 'OBSERVA��O',
		CONVERT(CHAR(10), CAST(a.C5_EMISSAO AS DATE),103) AS 'EMISSAO DO PEDIDO',
		CONVERT(CHAR(10), CAST(c.ZF_DATA AS DATE),103) 'DATA REAL DA OCORRENCIA',
		c.ZF_HORA 'HORA REAL DA OCORRENCIA',
		CONVERT(CHAR(10), CAST(a.INI_PRAZO AS DATE),103) AS 'DATA INICIO PRAZO',
		CASE c.ZF_CODIGO
			--LIBERA��O COMERCIAL
			WHEN '02' THEN d.ZE_REVISAO
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN d.ZE_REVISAO + d.ZE_FINANCE
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--FATURAMENTO
			WHEN '05' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC
			--EXPEDI��O
			WHEN '06' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC
			ELSE
				0
		END AS 'PRAZO EM DIAS',
		CASE c.ZF_CODIGO
			--INCLUSAO
			WHEN '01' THEN CONVERT(CHAR(10),CONVERT(DATE,C5_EMISSAO),103)
			--LIBERA��O COMERCIAL
			WHEN '02' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE) ,CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--FATURAMENTO
			WHEN '05' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC),CONVERT(DATE,INI_PRAZO)),103)
			--EXPEDI��O
			WHEN '06' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC),CONVERT(DATE,INI_PRAZO)),103)
			ELSE
				CASE
					WHEN ZF_DATA <= INI_PRAZO THEN CONVERT(CHAR(10), CAST(INI_PRAZO AS DATE),103)
					ELSE CONVERT(CHAR(10), CAST(ZF_DATA AS DATE),103)
				END
		END AS 'PROMETIDO'

	FROM dbo.SZF040 AS c WITH (NOLOCK)
		LEFT OUTER JOIN (SELECT C5_FILIAL,C5_NUM,C5_TRANSP,C5_TIPO,C5_CLIENTE,C5_XTOTMER,C5_PBRUTO,C5_VOLUME1,C5_EMISSAO,C5_XTPPED
								-- CHAMA A FUNCAO QUE RETORNA A ULTIMA DATA DE REPROGRAMACAO DE PRAZO QUE SERA USADA NO INICIO DO CALCULO DO PRAZO
								,dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_04(C5_FILIAL,C5_NUM) INI_PRAZO
								FROM SC5040 WHERE C5_TIPO = 'N' AND C5_EMISSAO >= '20190101'
						 ) a ON C5_FILIAL = ZF_FILIAL
								AND C5_NUM = ZF_PEDIDO

		LEFT OUTER JOIN (SELECT DISTINCT F2_TRANSP, TRA.D2_FILIAL, TRA.D2_PEDIDO FROM SD2040 AS TRA
							INNER JOIN SF2040 ON
								TRA.D_E_L_E_T_<>'*' AND
								F2_FILIAL = TRA.D2_FILIAL AND
								F2_DOC = TRA.D2_DOC AND
								F2_SERIE = TRA.D2_SERIE

							WHERE
							TRA.D_E_L_E_T_<>'*') TRA ON
				TRA.D2_FILIAL = a.C5_FILIAL	AND
				TRA.D2_PEDIDO = a.C5_NUM

		LEFT OUTER JOIN dbo.SA1010 AS b WITH (NOLOCK) ON
				b.A1_FILIAL = '' AND
				b.A1_COD = a.C5_CLIENTE

		LEFT OUTER JOIN dbo.SZE040 AS d WITH (NOLOCK) ON d.D_E_L_E_T_<>'*' and
				d.ZE_FILIAL='' AND
				C5_XTPPED = d.ZE_MODALID

		INNER JOIN dbo.SA4010 AS f WITH (NOLOCK) ON
				f.A4_FILIAL = '' AND
				f.A4_COD =	CASE
								WHEN TRA.F2_TRANSP IS NOT NULL AND F2_TRANSP <> ''
								THEN F2_TRANSP
								ELSE a.C5_TRANSP
							END
	WHERE
		c.D_E_L_E_T_<>'*'

UNION ALL

-------------------------------------------------------------------------------------INDUSTRIA-----------------------------------------------------------------------------------------------------
---------------------CRIADA EM: 17/04/2019----------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------
---------------------ALTERADA EM: 18/04/2019--------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------

	SELECT
		'ALB' AS 'EMPRESA',
		'02' AS 'C5_EMPRESA',
		a.C5_FILIAL AS 'FILIAL',
		a.C5_NUM AS 'PEDIDO',
		a.C5_CLIENTE AS 'CLIENTE',
		b.A1_NOME AS 'RAZ�O SOCIAL',
		b.A1_EST AS 'ESTADO',
		b.A1_MUN AS 'CIDADE',
		a.C5_XTOTMER AS 'VALOR PDV',
		a.C5_PBRUTO AS 'PESO BRUTO',
		a.C5_VOLUME1 AS 'VOLUME',
		ISNULL(f.A4_COD,'') AS 'TRANSP',
		ISNULL(f.A4_NOME,'') AS 'NOME TRANSP',
		a.C5_XTPPED AS 'TIPO PDV',
		c.ZF_CODIGO AS 'STATUS',
		c.ZF_STATUS AS 'DESCRI��O STATUS',
		ZF_OBS AS 'OBSERVA��O',
		CONVERT(CHAR(10), CAST(a.C5_EMISSAO AS DATE),103) AS 'EMISSAO DO PEDIDO',
		CONVERT(CHAR(10), CAST(c.ZF_DATA AS DATE),103) 'DATA REAL DA OCORRENCIA',
		c.ZF_HORA 'HORA REAL DA OCORRENCIA',
		CONVERT(CHAR(10), CAST(a.INI_PRAZO AS DATE),103) AS 'DATA INICIO PRAZO',
		CASE c.ZF_CODIGO
			--LIBERA��O COMERCIAL
			WHEN '02' THEN d.ZE_REVISAO
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN d.ZE_REVISAO + d.ZE_FINANCE
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--FATURAMENTO
			WHEN '05' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC
			--EXPEDI��O
			WHEN '06' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC
			ELSE
				0
		END AS 'PRAZO EM DIAS',
		CASE c.ZF_CODIGO
			--INCLUSAO
			WHEN '01' THEN CONVERT(CHAR(10),CONVERT(DATE,C5_EMISSAO),103)
			--LIBERA��O COMERCIAL
			WHEN '02' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE) ,CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--FATURAMENTO
			WHEN '05' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC),CONVERT(DATE,INI_PRAZO)),103)
			--EXPEDI��O
			WHEN '06' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC),CONVERT(DATE,INI_PRAZO)),103)
			ELSE
				CASE
					WHEN ZF_DATA <= INI_PRAZO THEN CONVERT(CHAR(10), CAST(INI_PRAZO AS DATE),103)
					ELSE CONVERT(CHAR(10), CAST(ZF_DATA AS DATE),103)
				END
		END AS 'PROMETIDO'

	FROM dbo.SZF020 AS c WITH (NOLOCK)
		LEFT OUTER JOIN (SELECT C5_FILIAL,C5_NUM,C5_TRANSP,C5_TIPO,C5_CLIENTE,C5_XTOTMER,C5_PBRUTO,C5_VOLUME1,C5_EMISSAO,C5_XTPPED
								-- CHAMA A FUNCAO QUE RETORNA A ULTIMA DATA DE REPROGRAMACAO DE PRAZO QUE SERA USADA NO INICIO DO CALCULO DO PRAZO
								,dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_02(C5_FILIAL,C5_NUM) INI_PRAZO
								FROM SC5020 WHERE C5_TIPO = 'N' AND C5_EMISSAO >= '20190101'
						 ) a ON C5_FILIAL = ZF_FILIAL
								AND C5_NUM = ZF_PEDIDO

		LEFT OUTER JOIN (SELECT DISTINCT F2_TRANSP, TRA.D2_FILIAL, TRA.D2_PEDIDO FROM SD2020 AS TRA
							INNER JOIN SF2020 ON
								TRA.D_E_L_E_T_<>'*' AND
								F2_FILIAL = TRA.D2_FILIAL AND
								F2_DOC = TRA.D2_DOC AND
								F2_SERIE = TRA.D2_SERIE

							WHERE
							TRA.D_E_L_E_T_<>'*') TRA ON
				TRA.D2_FILIAL = a.C5_FILIAL	AND
				TRA.D2_PEDIDO = a.C5_NUM

		LEFT OUTER JOIN dbo.SA1010 AS b WITH (NOLOCK) ON
				b.A1_FILIAL = '' AND
				b.A1_COD = a.C5_CLIENTE

		LEFT OUTER JOIN dbo.SZE010 AS d WITH (NOLOCK) ON d.D_E_L_E_T_<>'*' and
				d.ZE_FILIAL='' AND
				C5_XTPPED = d.ZE_MODALID

		INNER JOIN dbo.SA4010 AS f WITH (NOLOCK) ON
				f.A4_FILIAL = '' AND
				f.A4_COD =	CASE
								WHEN TRA.F2_TRANSP IS NOT NULL AND F2_TRANSP <> ''
								THEN F2_TRANSP
								ELSE a.C5_TRANSP
							END
	WHERE
		c.D_E_L_E_T_<>'*'


UNION ALL

-------------------------------------------------------------------------------------INDUSTRIA-----------------------------------------------------------------------------------------------------
---------------------CRIADA EM: 17/04/2019----------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------
---------------------ALTERADA EM: 18/04/2019--------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------

	SELECT
		'KD' AS 'EMPRESA',
		'01' AS 'C5_EMPRESA',
		a.C5_FILIAL AS 'FILIAL',
		a.C5_NUM AS 'PEDIDO',
		a.C5_CLIENTE AS 'CLIENTE',
		b.A1_NOME AS 'RAZ�O SOCIAL',
		b.A1_EST AS 'ESTADO',
		b.A1_MUN AS 'CIDADE',
		a.C5_XTOTMER AS 'VALOR PDV',
		a.C5_PBRUTO AS 'PESO BRUTO',
		a.C5_VOLUME1 AS 'VOLUME',
		ISNULL(f.A4_COD,'') AS 'TRANSP',
		ISNULL(f.A4_NOME,'') AS 'NOME TRANSP',
		a.C5_XTPPED AS 'TIPO PDV',
		c.ZF_CODIGO AS 'STATUS',
		c.ZF_STATUS AS 'DESCRI��O STATUS',
		ZF_OBS AS 'OBSERVA��O',
		CONVERT(CHAR(10), CAST(a.C5_EMISSAO AS DATE),103) AS 'EMISSAO DO PEDIDO',
		CONVERT(CHAR(10), CAST(c.ZF_DATA AS DATE),103) 'DATA REAL DA OCORRENCIA',
		c.ZF_HORA 'HORA REAL DA OCORRENCIA',
		CONVERT(CHAR(10), CAST(a.INI_PRAZO AS DATE),103) AS 'DATA INICIO PRAZO',
		CASE c.ZF_CODIGO
			--LIBERA��O COMERCIAL
			WHEN '02' THEN d.ZE_REVISAO
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN d.ZE_REVISAO + d.ZE_FINANCE
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--FATURAMENTO
			WHEN '05' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC
			--EXPEDI��O
			WHEN '06' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC
			ELSE
				0
		END AS 'PRAZO EM DIAS',
		CASE c.ZF_CODIGO
			--INCLUSAO
			WHEN '01' THEN CONVERT(CHAR(10),CONVERT(DATE,C5_EMISSAO),103)
			--LIBERA��O COMERCIAL
			WHEN '02' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE) ,CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--FATURAMENTO
			WHEN '05' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC),CONVERT(DATE,INI_PRAZO)),103)
			--EXPEDI��O
			WHEN '06' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC),CONVERT(DATE,INI_PRAZO)),103)
			ELSE
				CASE
					WHEN ZF_DATA <= INI_PRAZO THEN CONVERT(CHAR(10), CAST(INI_PRAZO AS DATE),103)
					ELSE CONVERT(CHAR(10), CAST(ZF_DATA AS DATE),103)
				END
		END AS 'PROMETIDO'

	FROM dbo.SZF010 AS c WITH (NOLOCK)
		LEFT OUTER JOIN (SELECT C5_FILIAL,C5_NUM,C5_TRANSP,C5_TIPO,C5_CLIENTE,C5_XTOTMER,C5_PBRUTO,C5_VOLUME1,C5_EMISSAO,C5_XTPPED
								-- CHAMA A FUNCAO QUE RETORNA A ULTIMA DATA DE REPROGRAMACAO DE PRAZO QUE SERA USADA NO INICIO DO CALCULO DO PRAZO
								,dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_01(C5_FILIAL,C5_NUM) INI_PRAZO
								FROM SC5010 WHERE C5_TIPO = 'N' AND C5_EMISSAO >= '20190101'
						 ) a ON C5_FILIAL = ZF_FILIAL
								AND C5_NUM = ZF_PEDIDO

		LEFT OUTER JOIN (SELECT DISTINCT F2_TRANSP, TRA.D2_FILIAL, TRA.D2_PEDIDO FROM SD2010 AS TRA
							INNER JOIN SF2010 ON
								TRA.D_E_L_E_T_<>'*' AND
								F2_FILIAL = TRA.D2_FILIAL AND
								F2_DOC = TRA.D2_DOC AND
								F2_SERIE = TRA.D2_SERIE

							WHERE
							TRA.D_E_L_E_T_<>'*') TRA ON
				TRA.D2_FILIAL = a.C5_FILIAL	AND
				TRA.D2_PEDIDO = a.C5_NUM

		LEFT OUTER JOIN dbo.SA1010 AS b WITH (NOLOCK) ON
				b.A1_FILIAL = '' AND
				b.A1_COD = a.C5_CLIENTE

		LEFT OUTER JOIN dbo.SZE010 AS d WITH (NOLOCK) ON d.D_E_L_E_T_<>'*' and
				d.ZE_FILIAL='' AND
				C5_XTPPED = d.ZE_MODALID

		INNER JOIN dbo.SA4010 AS f WITH (NOLOCK) ON
				f.A4_FILIAL = '' AND
				f.A4_COD =	CASE
								WHEN TRA.F2_TRANSP IS NOT NULL AND F2_TRANSP <> ''
								THEN F2_TRANSP
								ELSE a.C5_TRANSP
							END
	WHERE
		c.D_E_L_E_T_<>'*'

UNION ALL

-------------------------------------------------------------------------------------INDUSTRIA-----------------------------------------------------------------------------------------------------
---------------------CRIADA EM: 17/04/2019----------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------
---------------------ALTERADA EM: 18/04/2019--------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------

	SELECT
		'CAP' AS 'EMPRESA',
		'03' AS 'C5_EMPRESA',
		a.C5_FILIAL AS 'FILIAL',
		a.C5_NUM AS 'PEDIDO',
		a.C5_CLIENTE AS 'CLIENTE',
		b.A1_NOME AS 'RAZ�O SOCIAL',
		b.A1_EST AS 'ESTADO',
		b.A1_MUN AS 'CIDADE',
		a.C5_XTOTMER AS 'VALOR PDV',
		a.C5_PBRUTO AS 'PESO BRUTO',
		a.C5_VOLUME1 AS 'VOLUME',
		ISNULL(f.A4_COD,'') AS 'TRANSP',
		ISNULL(f.A4_NOME,'') AS 'NOME TRANSP',
		a.C5_XTPPED AS 'TIPO PDV',
		c.ZF_CODIGO AS 'STATUS',
		c.ZF_STATUS AS 'DESCRI��O STATUS',
		ZF_OBS AS 'OBSERVA��O',
		CONVERT(CHAR(10), CAST(a.C5_EMISSAO AS DATE),103) AS 'EMISSAO DO PEDIDO',
		CONVERT(CHAR(10), CAST(c.ZF_DATA AS DATE),103) 'DATA REAL DA OCORRENCIA',
		c.ZF_HORA 'HORA REAL DA OCORRENCIA',
		CONVERT(CHAR(10), CAST(a.INI_PRAZO AS DATE),103) AS 'DATA INICIO PRAZO',
		CASE c.ZF_CODIGO
			--LIBERA��O COMERCIAL
			WHEN '02' THEN d.ZE_REVISAO
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN d.ZE_REVISAO + d.ZE_FINANCE
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--FATURAMENTO
			WHEN '05' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC
			--EXPEDI��O
			WHEN '06' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC
			ELSE
				0
		END AS 'PRAZO EM DIAS',
		CASE c.ZF_CODIGO
			--INCLUSAO
			WHEN '01' THEN CONVERT(CHAR(10),CONVERT(DATE,C5_EMISSAO),103)
			--LIBERA��O COMERCIAL
			WHEN '02' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE) ,CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--FATURAMENTO
			WHEN '05' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC),CONVERT(DATE,INI_PRAZO)),103)
			--EXPEDI��O
			WHEN '06' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC),CONVERT(DATE,INI_PRAZO)),103)
			ELSE
				CASE
					WHEN ZF_DATA <= INI_PRAZO THEN CONVERT(CHAR(10), CAST(INI_PRAZO AS DATE),103)
					ELSE CONVERT(CHAR(10), CAST(ZF_DATA AS DATE),103)
				END
		END AS 'PROMETIDO'

	FROM dbo.SZF030 AS c WITH (NOLOCK)
		LEFT OUTER JOIN (SELECT C5_FILIAL,C5_NUM,C5_TRANSP,C5_TIPO,C5_CLIENTE,C5_XTOTMER,C5_PBRUTO,C5_VOLUME1,C5_EMISSAO,C5_XTPPED
								-- CHAMA A FUNCAO QUE RETORNA A ULTIMA DATA DE REPROGRAMACAO DE PRAZO QUE SERA USADA NO INICIO DO CALCULO DO PRAZO
								,dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_03(C5_FILIAL,C5_NUM) INI_PRAZO
								FROM SC5030 WHERE C5_TIPO = 'N' AND C5_EMISSAO >= '20190101'
						 ) a ON C5_FILIAL = ZF_FILIAL
								AND C5_NUM = ZF_PEDIDO

		LEFT OUTER JOIN (SELECT DISTINCT F2_TRANSP, TRA.D2_FILIAL, TRA.D2_PEDIDO FROM SD2030 AS TRA
							INNER JOIN SF2030 ON
								TRA.D_E_L_E_T_<>'*' AND
								F2_FILIAL = TRA.D2_FILIAL AND
								F2_DOC = TRA.D2_DOC AND
								F2_SERIE = TRA.D2_SERIE

							WHERE
							TRA.D_E_L_E_T_<>'*') TRA ON
				TRA.D2_FILIAL = a.C5_FILIAL	AND
				TRA.D2_PEDIDO = a.C5_NUM

		LEFT OUTER JOIN dbo.SA1010 AS b WITH (NOLOCK) ON
				b.A1_FILIAL = '' AND
				b.A1_COD = a.C5_CLIENTE

		LEFT OUTER JOIN dbo.SZE010 AS d WITH (NOLOCK) ON d.D_E_L_E_T_<>'*' and
				d.ZE_FILIAL='' AND
				C5_XTPPED = d.ZE_MODALID

		INNER JOIN dbo.SA4010 AS f WITH (NOLOCK) ON
				f.A4_FILIAL = '' AND
				f.A4_COD =	CASE
								WHEN TRA.F2_TRANSP IS NOT NULL AND F2_TRANSP <> ''
								THEN F2_TRANSP
								ELSE a.C5_TRANSP
							END
	WHERE
		c.D_E_L_E_T_<>'*'

UNION ALL

-------------------------------------------------------------------------------------INDUSTRIA-----------------------------------------------------------------------------------------------------
---------------------CRIADA EM: 17/04/2019----------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------
---------------------ALTERADA EM: 18/04/2019--------------------------------------------------------------------------------------------------POR: ALUISIO AUGUSTO---------------------------------

	SELECT
		'KB' AS 'EMPRESA',
		'07' AS 'C5_EMPRESA',
		a.C5_FILIAL AS 'FILIAL',
		a.C5_NUM AS 'PEDIDO',
		a.C5_CLIENTE AS 'CLIENTE',
		b.A1_NOME AS 'RAZ�O SOCIAL',
		b.A1_EST AS 'ESTADO',
		b.A1_MUN AS 'CIDADE',
		a.C5_XTOTMER AS 'VALOR PDV',
		a.C5_PBRUTO AS 'PESO BRUTO',
		a.C5_VOLUME1 AS 'VOLUME',
		ISNULL(f.A4_COD,'') AS 'TRANSP',
		ISNULL(f.A4_NOME,'') AS 'NOME TRANSP',
		a.C5_XTPPED AS 'TIPO PDV',
		c.ZF_CODIGO AS 'STATUS',
		c.ZF_STATUS AS 'DESCRI��O STATUS',
		ZF_OBS AS 'OBSERVA��O',
		CONVERT(CHAR(10), CAST(a.C5_EMISSAO AS DATE),103) AS 'EMISSAO DO PEDIDO',
		CONVERT(CHAR(10), CAST(c.ZF_DATA AS DATE),103) 'DATA REAL DA OCORRENCIA',
		c.ZF_HORA 'HORA REAL DA OCORRENCIA',
		CONVERT(CHAR(10), CAST(a.INI_PRAZO AS DATE),103) AS 'DATA INICIO PRAZO',
		CASE c.ZF_CODIGO
			--LIBERA��O COMERCIAL
			WHEN '02' THEN d.ZE_REVISAO
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN d.ZE_REVISAO + d.ZE_FINANCE
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA
			--FATURAMENTO
			WHEN '05' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC
			--EXPEDI��O
			WHEN '06' THEN d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC
			ELSE
				0
		END AS 'PRAZO EM DIAS',
		CASE c.ZF_CODIGO
			--INCLUSAO
			WHEN '01' THEN CONVERT(CHAR(10),CONVERT(DATE,C5_EMISSAO),103)
			--LIBERA��O COMERCIAL
			WHEN '02' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O FINANCEIRO
			WHEN '03' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE) ,CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE TOTAL
			WHEN '04' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--LIBERA��O DE ESTOQUE PARCIAL
			WHEN '14' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA),CONVERT(DATE,INI_PRAZO)),103)
			--FATURAMENTO
			WHEN '05' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC),CONVERT(DATE,INI_PRAZO)),103)
			--EXPEDI��O
			WHEN '06' THEN CONVERT(CHAR(10),DATEADD(d,(d.ZE_REVISAO + d.ZE_FINANCE + d.ZE_PRODUCA + d.ZE_SEPARAC + d.ZE_EXPEDIC),CONVERT(DATE,INI_PRAZO)),103)
			ELSE
				CASE
					WHEN ZF_DATA <= INI_PRAZO THEN CONVERT(CHAR(10), CAST(INI_PRAZO AS DATE),103)
					ELSE CONVERT(CHAR(10), CAST(ZF_DATA AS DATE),103)
				END
		END AS 'PROMETIDO'

	FROM dbo.SZF070 AS c WITH (NOLOCK)
		LEFT OUTER JOIN (SELECT C5_FILIAL,C5_NUM,C5_TRANSP,C5_TIPO,C5_CLIENTE,C5_XTOTMER,C5_PBRUTO,C5_VOLUME1,C5_EMISSAO,C5_XTPPED
								-- CHAMA A FUNCAO QUE RETORNA A ULTIMA DATA DE REPROGRAMACAO DE PRAZO QUE SERA USADA NO INICIO DO CALCULO DO PRAZO
								,dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_07(C5_FILIAL,C5_NUM) INI_PRAZO
								FROM SC5070 WHERE C5_TIPO = 'N' AND C5_EMISSAO >= '20190101'
						 ) a ON C5_FILIAL = ZF_FILIAL
								AND C5_NUM = ZF_PEDIDO

		LEFT OUTER JOIN (SELECT DISTINCT F2_TRANSP, TRA.D2_FILIAL, TRA.D2_PEDIDO FROM SD2070 AS TRA
							INNER JOIN SF2070 ON
								TRA.D_E_L_E_T_<>'*' AND
								F2_FILIAL = TRA.D2_FILIAL AND
								F2_DOC = TRA.D2_DOC AND
								F2_SERIE = TRA.D2_SERIE

							WHERE
							TRA.D_E_L_E_T_<>'*') TRA ON
				TRA.D2_FILIAL = a.C5_FILIAL	AND
				TRA.D2_PEDIDO = a.C5_NUM

		LEFT OUTER JOIN dbo.SA1010 AS b WITH (NOLOCK) ON
				b.A1_FILIAL = '' AND
				b.A1_COD = a.C5_CLIENTE

		LEFT OUTER JOIN dbo.SZE010 AS d WITH (NOLOCK) ON d.D_E_L_E_T_<>'*' and
				d.ZE_FILIAL='' AND
				C5_XTPPED = d.ZE_MODALID

		INNER JOIN dbo.SA4010 AS f WITH (NOLOCK) ON
				f.A4_FILIAL = '' AND
				f.A4_COD =	CASE
								WHEN TRA.F2_TRANSP IS NOT NULL AND F2_TRANSP <> ''
								THEN F2_TRANSP
								ELSE a.C5_TRANSP
							END
	WHERE
		c.D_E_L_E_T_<>'*'

GO


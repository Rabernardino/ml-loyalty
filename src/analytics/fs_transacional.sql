


WITH tb_transacao AS (

SELECT
    *,
    substr(DtCriacao,0,11) as dtDia,
    CAST(substr(DtCriacao,12,2) as INT) as dtHora
FROM
    transacoes
WHERE
    1=1
    AND DtCriacao < '{date}'
),

tb_agg_transacao AS (
    SELECT
        IdCliente,

        MAX(julianday('{date}', '-1 day')) - julianday(DtCriacao) as idadeDias,

        COUNT(DISTINCT dtDia) as qtdeAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-7 day') THEN dtDia END) as qtdeAtivacaoVidaD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-14 day') THEN dtDia END) as qtdAtivacaoVidaD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-28 day') THEN dtDia END) as qtdAtivacaoVidaD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-56 day') THEN dtDia END) as qtdAtivacaoVidaD56,

        COUNT(DISTINCT IdTransacao) as qtdeTransacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-7 day') THEN IdTransacao END) as qtdeTransacaoVidaD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-14 day') THEN IdTransacao END) as qtdTransacaoVidaD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-28 day') THEN IdTransacao END) as qtdTransacaoVidaD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-56 day') THEN IdTransacao END) as qtdTransacaoVidaD56,

        SUM(qtdePontos) AS saldoVida,
        SUM(CASE WHEN dtDia >= date('{date}', '-7 day') THEN qtdePontos ELSE 0 END) as saldoVidaD7,
        SUM(CASE WHEN dtDia >= date('{date}', '-14 day') THEN qtdePontos ELSE 0 END) as saldoVidaD14,
        SUM(CASE WHEN dtDia >= date('{date}', '-28 day') THEN qtdePontos ELSE 0 END) as saldoVidaD28,
        SUM(CASE WHEN dtDia >= date('{date}', '-56 day') THEN qtdePontos ELSE 0 END) as saldoVidaD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        SUM(CASE WHEN dtDia >= date('{date}', '-7 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) as qtdePontosPosVidaD7,
        SUM(CASE WHEN dtDia >= date('{date}', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) as qtdePontosPosVidaD14,
        SUM(CASE WHEN dtDia >= date('{date}', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) as qtdePontosPosVidaD28,
        SUM(CASE WHEN dtDia >= date('{date}', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) as qtdePontosPosVidaD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        SUM(CASE WHEN dtDia >= date('{date}', '-7 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) as qtdePontosVidaD7,
        SUM(CASE WHEN dtDia >= date('{date}', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) as qtdePontosNegVidaD14,
        SUM(CASE WHEN dtDia >= date('{date}', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) as qtdePontosNegVidaD28,
        SUM(CASE WHEN dtDia >= date('{date}', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) as qtdePontosNegVidaD56,
        
        COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN idTransacao END) AS qtdeTransacaoManha,
        COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN idTransacao END) AS qtdeTransacaoTarde,
        COUNT(CASE WHEN dtHora > 21 OR dtHora < 10 THEN idTransacao END) AS qtdeTransacaoNoite,

        1. * COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN idTransacao END) / COUNT(IdTransacao) AS pctTransacaoManha,
        1. * COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN idTransacao END) / COUNT(IdTransacao) AS pctTransacaoTarde,
        1. * COUNT(CASE WHEN dtHora > 21 OR dtHora < 10 THEN idTransacao END) / COUNT(IdTransacao) AS pctTransacaoNoite


    FROM
        tb_transacao
    GROUP BY
        IdCliente
),

tb_agg_calc AS (

    SELECT
        *,
    COALESCE(1. * qtdeTransacaoVida / qtdeAtivacaoVida, 0) as qtdeTransacaoDiaVida,
    COALESCE(1. * qtdeTransacaoVidaD7 / qtdeAtivacaoVidaD7, 0) as qtdeTransacaoDiaD7, 
    COALESCE(1. * qtdTransacaoVidaD14 / qtdAtivacaoVidaD14, 0) as qtdeTransacaoDia14, 
    COALESCE(1. * qtdTransacaoVidaD28 / qtdAtivacaoVidaD28, 0) as qtdeTransacaoDia28, 
    COALESCE(1. * qtdTransacaoVidaD56 / qtdAtivacaoVidaD56, 0) as qtdeTransacaoDia56,

    COALESCE(1.* qtdAtivacaoVidaD28 / 28, 0) as pctAtivacaoMAU

    FROM
        tb_agg_transacao
),

tb_hora_dia AS (

    SELECT
        idCliente,
        dtDia,
        (24) * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) as duracao
    FROM
        tb_transacao
    GROUP BY
        idCliente,
        dtDia
),

tb_hora_cliente as (

    SELECT
        idCliente,
        SUM(duracao) as qtdeHorasVida,
        SUM(CASE WHEN dtDia >= date('{date}', '-7 day') THEN duracao ELSE 0 END) as qtdeHorasD7,
        SUM(CASE WHEN dtDia >= date('{date}', '-14 day') THEN duracao ELSE 0 END) as qtdeHorasD14,
        SUM(CASE WHEN dtDia >= date('{date}', '-28 day') THEN duracao ELSE 0 END) as qtdeHorasD28,
        SUM(CASE WHEN dtDia >= date('{date}', '-56 day') THEN duracao ELSE 0 END) as qtdeHorasD56
    FROM
        tb_hora_dia
    GROUP BY
        idCliente
),

tb_lag_day as (

    SELECT
        idCliente,
        dtDia,
        LAG(dtDia) OVER (PARTITION BY idCliente) as lagDia
    FROM
        tb_hora_dia
),

tb_intervalo_dias AS (

    SELECT
        idCliente,
        AVG(julianday(dtDia) - julianday(lagDia)) as avgIntervaloDiasVida,
        AVG(CASE WHEN dtDia >= date('{date}', '-28 day') THEN julianday(dtDia) - julianday(lagDia) END) as avgIntervaloDiasD28
    FROM
        tb_lag_day
    GROUP BY
        idCliente
),


tb_share_produtos AS (

    SELECT 
        idCliente,
        1. * COUNT(CASE WHEN descNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteChatMessage,
        1. * COUNT(CASE WHEN descNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteAirflowLover,
        1. * COUNT(CASE WHEN descNomeProduto = 'R Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteRLover,
        1. * COUNT(CASE WHEN descNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteResgatarPonei,
        1. * COUNT(CASE WHEN descNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteListadepresenca,
        1. * COUNT(CASE WHEN descNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtePresencaStreak,
        1. * COUNT(CASE WHEN descNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteTrocaStreamElements,
        1. * COUNT(CASE WHEN descNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qteReembolsoStreamElements,
        1. * COUNT(CASE WHEN descCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRPG,
        1. * COUNT(CASE WHEN descCategoriaProduto = 'churn_model' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChurnModel

    FROM tb_transacao AS t1

    LEFT JOIN transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN produtos AS t3
    ON t2.IdProduto = t3.IdProduto

    GROUP BY idCliente

),

tb_join AS (
    SELECT
        t1.*,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t3.avgIntervaloDiasVida,
        t3.avgIntervaloDiasD28,
        t4.qteChatMessage,
        t4.qteAirflowLover,
        t4.qteRLover,
        t4.qteResgatarPonei,
        t4.qteListadepresenca,
        t4.qtePresencaStreak,
        t4.qteTrocaStreamElements,
        t4.qteReembolsoStreamElements,
        t4.qtdeRPG,
        t4.qtdeChurnModel
    FROM
        tb_agg_calc as t1

    LEFT JOIN
        tb_hora_cliente as t2
    ON t1.IdCliente = t2.idCliente

    LEFT JOIN
        tb_intervalo_dias as t3
    ON t1.idCliente = t3.idCliente

    LEFT JOIN
        tb_share_produtos as t4
    ON t1.idCliente = t4.idCliente

)

SELECT
    date('{date}', '-1 day') as dtRef,
    *
FROM
    tb_join



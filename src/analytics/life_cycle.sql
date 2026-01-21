WITH tb_daily AS(

    SELECT
        DISTINCT
        substr(DtCriacao,0,11) as dtDia,
        idCliente
    FROM
        transacoes
    WHERE
        DtCriacao < '{date}'
),

tb_transacoes AS (
    SELECT
        idCliente,
        -- min(dtDia) as PrimeiraData,
        CAST(max(julianday('{date}') - julianday(dtDia)) as int) as qtdDiasPrimeiraTransacao,
        -- max(dtDia) as UltimaData,
        CAST(min(julianday('{date}') - julianday(dtDia)) as int) as qtdDiasUltimaTransacao
    FROM
        tb_daily
    GROUP BY
        idCliente
),

tb_rn AS (

    SELECT
        idCliente,
        dtDia,
        ROW_NUMBER() OVER(PARTITION BY idCliente ORDER BY dtDia DESC) as RN
    FROM
        tb_daily
),

tb_penultima_transacao AS (

    SELECT
        idCliente,
        -- dtDia as PenultimaDatam,
        CAST((julianday('{date}') - julianday(dtDia)) as int) as qtdDiasPenultimaTransacao
    FROM
        tb_rn
    WHERE
        1=1
        AND RN = 2
),

tb_life_cycle AS (
    
    SELECT
        t1.*,
        t2.qtdDiasPenultimaTransacao,
        CASE
            WHEN t1.qtdDiasPrimeiraTransacao <= 7 THEN '01-CURIOSO'
            WHEN t1.qtdDiasUltimaTransacao <= 7 AND t2.qtdDiasPenultimaTransacao - t1.qtdDiasUltimaTransacao <= 14 THEN '02-FIEL'
            WHEN t1.qtdDiasUltimaTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
            WHEN t1.qtdDiasUltimaTransacao BETWEEN 15 AND 28 THEN '04-DESENCANTADA'
            WHEN t1.qtdDiasUltimaTransacao > 28 THEN '05-ZUMBI'
            WHEN t1.qtdDiasUltimaTransacao <= 7 AND t2.qtdDiasPenultimaTransacao - t1.qtdDiasUltimaTransacao BETWEEN 15 AND 28 THEN '02-RECONQUISTADA'
            WHEN t1.qtdDiasUltimaTransacao <=7 AND t2.qtdDiasPenultimaTransacao - t1.qtdDiasUltimaTransacao > 28 THEN '02-REBORN'
        END AS lifeCycleStatus

    FROM
        tb_transacoes t1
    LEFT JOIN
        tb_penultima_transacao t2
    ON
        t1.idCliente = t2.idCliente
),


tb_freq_valor AS (

    SELECT
        idCliente,
        COUNT(DISTINCT substr(DtCriacao,0,11)) as qtdeFrequencia,
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) as qtdePontosPos,
        sum(abs(QtdePontos)) as qtddePontosAbs
    FROM
        transacoes
    WHERE
        1=1
        AND DtCriacao < '{date}'
        AND DtCriacao >= date('{date}','-28 day')
    GROUP BY
        idCliente

    ORDER BY
        2 DESC

),

tb_cluster AS (
    
    SELECT
        *,
        CASE
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 1500 THEN '12-HYPERS'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '22-EFICIENTES'
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11-INDECISOS'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN '21-ESFORÇADO'
            WHEN qtdeFrequencia < 5 THEN '00-LURKER'
            WHEN qtdeFrequencia <= 10 THEN '01-PREGUIÇOSO'
            WHEN qtdeFrequencia > 10 THEN '20-POTENCIAL'
        END AS cluster
    FROM
        tb_freq_valor

)

SELECT
    date('{date}', '-1 day') AS dtRef,
    t1.*,
    t2.qtdeFrequencia,
    t2.qtdePontosPos,
    t2.cluster
FROM
    tb_life_cycle AS t1

LEFT JOIN
    tb_cluster AS t2
    ON t1.idCliente = t2.idCliente



WITH tb_freq_valor AS (

    SELECT
        idCliente,
        COUNT(DISTINCT substr(DtCriacao,0,11)) as qtdeFrequencia,
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) as qtdePontosPos,
        sum(abs(QtdePontos)) as qtddePontosAbs
    FROM
        transacoes
    WHERE
        1=1
        AND DtCriacao < '2025-09-01'
        AND DtCriacao >= date('2025-09-01','-28 day')
    GROUP BY
        idCliente

    ORDER BY
        2 DESC

),

tb_cluster AS (
    
    SELECT
        *,
        CASE
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 1500 THEN 'HYPERS'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN 'EFICIENTES'
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN 'INDECISOS'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN 'ESFORÇADO'
            WHEN qtdeFrequencia < 5 THEN 'LURKER'
            WHEN qtdeFrequencia <= 10 THEN 'PREGUIÇOSO'
            WHEN qtdeFrequencia > 10 THEN 'POTENCIAL'
        END AS cluster
    FROM
        tb_freq_valor

)

SELECT
    cluster,
    COUNT(*) as Total
FROM
    tb_cluster
GROUP BY
    cluster


WITH tb_daily AS(

    SELECT
        DISTINCT
        substr(DtCriacao,1,10) as Dt_Dia,
        IdCliente
    FROM
        transacoes
    ORDER BY
        1 ASC
),

tb_distinct_day AS (

    SELECT
        DISTINCT(Dt_Dia) as DtRef
    FROM
        tb_daily
)


SELECT
    DtRef,
    COUNT(DISTINCT Dt_Dia) as Dias
    --COUNT(idCliente) as MAU
FROM
    tb_distinct_day
LEFT JOIN
    tb_daily
ON
    tb_distinct_day.DtRef >= tb_daily.Dt_Dia
    AND julianday(tb_distinct_day.DtRef) - julianday(tb_daily.Dt_Dia) < 28

GROUP BY
    1

ORDER BY
    1 ASC

LIMIT 100
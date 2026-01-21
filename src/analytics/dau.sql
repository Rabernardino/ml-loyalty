


SELECT
    substr(DtCriacao,1,10) as Dt_Dia,
    COUNT(DISTINCT IdCliente) as DAU
FROM
    transacoes
GROUP BY
    Dt_Dia
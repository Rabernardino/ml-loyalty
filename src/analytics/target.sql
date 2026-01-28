

-- DROP TABLE IF EXISTS abt_fiel;

CREATE TABLE IF NOT EXISTS abt_fiel AS 


WITH tb_join as (

    SELECT
        t1.dtRef,
        t1.idCliente,
        t1.lifeCycleStatus,
        t2.lifeCycleStatus,
        CASE
            WHEN t2.lifeCycleStatus = '02-FIEL' THEN 1 ELSE 0
        END AS flFiel,
        ROW_NUMBER() OVER(PARTITION BY t1.idCliente ORDER BY random()) as RN
    FROM
        life_cycle t1
    LEFT JOIN
        life_cycle t2

    ON (t1.idCliente = t2.idCliente
        AND date(t1.dtRef, '+28 day') = date(t2.dtRef))

    WHERE
        ((t1.dtRef >= '2024-03-01' AND t1.dtRef <= '2025-08-01') 
        OR t1.dtRef = '2025-09-01')
        AND t1.lifeCycleStatus <> '05-ZUMBI'
),

tb_cohort AS (

    SELECT
        t1.dtRef,
        t1.idCliente,
        t1.flFiel
    FROM
        tb_join t1
    WHERE
        RN <= 2
    ORDER BY
        idCliente, dtRef
)

SELECT
    t1.*,
    t2.idadeDias, 
    t2.qtdeAtivacaoVida, 
    t2.qtdeAtivacaoVidaD7, 
    t2.qtdAtivacaoVidaD14, 
    t2.qtdAtivacaoVidaD28, 
    t2.qtdAtivacaoVidaD56, 
    t2.qtdeTransacaoVida, 
    t2.qtdeTransacaoVidaD7, 
    t2.qtdTransacaoVidaD14, 
    t2.qtdTransacaoVidaD28, 
    t2.qtdTransacaoVidaD56, 
    t2.saldoVida, 
    t2.saldoVidaD7, 
    t2.saldoVidaD14, 
    t2.saldoVidaD28, 
    t2.saldoVidaD56, 
    t2.qtdePontosPosVida, 
    t2.qtdePontosPosVidaD7, 
    t2.qtdePontosPosVidaD14, 
    t2.qtdePontosPosVidaD28, 
    t2.qtdePontosPosVidaD56, 
    t2.qtdePontosNegVida, 
    t2.qtdePontosVidaD7, 
    t2.qtdePontosNegVidaD14, 
    t2.qtdePontosNegVidaD28, 
    t2.qtdePontosNegVidaD56, 
    t2.qtdeTransacaoManha, 
    t2.qtdeTransacaoTarde, 
    t2.qtdeTransacaoNoite, 
    t2.pctTransacaoManha, 
    t2.pctTransacaoTarde, 
    t2.pctTransacaoNoite, 
    t2.qtdeTransacaoDiaVida, 
    t2.qtdeTransacaoDiaD7, 
    t2.qtdeTransacaoDia14, 
    t2.qtdeTransacaoDia28, 
    t2.qtdeTransacaoDia56, 
    t2.pctAtivacaoMAU, 
    t2.qtdeHorasVida, 
    t2.qtdeHorasD7, 
    t2.qtdeHorasD14, 
    t2.qtdeHorasD28, 
    t2.qtdeHorasD56, 
    t2.avgIntervaloDiasVida, 
    t2.avgIntervaloDiasD28, 
    t2.qteChatMessage, 
    t2.qteAirflowLover, 
    t2.qteRLover, 
    t2.qteResgatarPonei, 
    t2.qteListadepresenca, 
    t2.qtePresencaStreak, 
    t2.qteTrocaStreamElements, 
    t2.qteReembolsoStreamElements, 
    t2.qtdeRPG, 
    t2.qtdeChurnModel,
    t3.descLifeCycleAtual, 
    t3.descLifeCycleD28, 
    t3.pctFiel, 
    t3.pctZumbi, 
    t3.pctDesencantada, 
    t3.pctCurioso, 
    t3.pctTurista, 
    t3.pctReconquistada, 
    t3.pctReborn, 
    t3.avgFreqGrupo, 
    t3.ratioFreqGrupo,
    t4.qtedCursosCompletos TEXT, 
    t4.qtedCursosIncompletos, 
    t4.carreira, 
    t4.coletaDados2024, 
    t4.dsDatabricks2024, 
    t4.dsPontos2024, 
    t4.estatistica2024, 
    t4.estatistica2025, 
    t4.github2024, 
    t4.github2025, 
    t4.iaCanal2025, 
    t4.lagoMago2024, 
    t4.loyaltyPredict2025, 
    t4.machineLearning2025, 
    t4.matchmakingTramparDeCasa2024, 
    t4.ml2024, 
    t4.mlflow2025, 
    t4.nekt2025, 
    t4.pandas2024, 
    t4.pandas2025, 
    t4.python2024, 
    t4.python2025, 
    t4.speedF1, 
    t4.sql2020, 
    t4.sql2025, 
    t4.streamlit2025, 
    t4.tramparLakehouse2024, 
    t4.tseAnalytics2024, 
    t4.qtdeDiasUltimaInteracao
FROM
    tb_cohort t1

LEFT JOIN
    fs_transacional t2
ON t1.idCliente = t2.IdCliente
    AND t1.dtRef = t2.dtRef

LEFT JOIN
    fs_life_cycle t3
ON t1.idCliente = t3.IdCliente
    AND t1.dtRef = t3.dtRef

LEFT JOIN
    fs_education t4
ON t1.idCliente = t4.IdCliente
    AND t1.dtRef = t4.dtRef


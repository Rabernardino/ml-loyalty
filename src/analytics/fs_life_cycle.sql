


WITH tb_life_cycle_atual AS(

    SELECT
        idCliente,
        qtdeFrequencia,
        lifeCycleStatus as descLifeCycleAtual
    FROM
        life_cycle
    WHERE
        dtRef = date('2025-10-01', '-1 day')
),

tb_life_cycle_D28 as (

    SELECT 
        idCliente,
        lifeCycleStatus as descLifeCycleD28
    FROM
        life_cycle
    WHERE
        dtRef = date('2025-10-01', '-28 day')
),


tb_share_ciclos AS(

    SELECT
        idCliente,
        1. * SUM(CASE WHEN lifeCycleStatus = '02-FIEL' THEN 1 ELSE 0 END) / COUNT(*) as pctFiel,
        1. * SUM(CASE WHEN lifeCycleStatus = '05-ZUMBI' THEN 1 ELSE 0 END) / COUNT(*) as pctZumbi,
        1. * SUM(CASE WHEN lifeCycleStatus = '04-DESENCANTADA' THEN 1 ELSE 0 END) / COUNT(*) as pctDesencantada,
        1. * SUM(CASE WHEN lifeCycleStatus = '01-CURIOSO' THEN 1 ELSE 0 END) / COUNT(*) as pctCurioso,
        1. * SUM(CASE WHEN lifeCycleStatus = '03-TURISTA' THEN 1 ELSE 0 END) / COUNT(*) as pctTurista,
        1. * SUM(CASE WHEN lifeCycleStatus = '02-RECONQUISTADA' THEN 1 ELSE 0 END) / COUNT(*) as pctReconquistada,
        1. * SUM(CASE WHEN lifeCycleStatus = '02-REBORN' THEN 1 ELSE 0 END) / COUNT(*) as pctReborn
    FROM
        life_cycle
    WHERE
        dtRef < date('2025-10-01')
    GROUP BY
        idCliente
),

tb_avg_ciclo AS (
    SELECT
        lifeCycleStatus,
        AVG(qtdeFrequencia) as avgFreqGrupo
    FROM
        life_cycle
    GROUP BY
        lifeCycleStatus

),


tb_join AS (

    SELECT
        t1.idCliente,
        t1.descLifeCycleAtual,
        t2.descLifeCycleD28,
        t3.pctFiel,
        t3.pctZumbi,
        t3.pctDesencantada,
        t3.pctCurioso,
        t3.pctTurista,
        t3.pctReconquistada,
        t3.pctReborn,
        t4.avgFreqGrupo,
        1. * t1.qtdeFrequencia/t4.avgFreqGrupo as ratioFreqGrupo
    FROM
        tb_life_cycle_atual t1
    LEFT JOIN
        tb_life_cycle_D28 t2
    ON
        t1.idCliente = t2.idCliente

    LEFT JOIN
        tb_share_ciclos t3
    ON
        t1.idCliente = t3.idCliente

    LEFT JOIN
        tb_avg_ciclo t4
    ON 
        t1.descLifeCycleAtual = t4.lifeCycleStatus
)


SELECT
    date('2025-10-01', '-1 day') as dtRef,
    *
FROM
    tb_join
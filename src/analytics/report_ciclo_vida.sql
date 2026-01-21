


SELECT
    dtRef,
    lifeCycleStatus,
    cluster,
    COUNT(*) as qtdCliente
FROM
    life_cycle
WHERE
    1=1
    AND lifeCycleStatus <> '05-ZUMBI'
GROUP BY
    dtRef,
    lifeCycleStatus,
    cluster
ORDER BY
    dtRef,
    lifeCycleStatus,
    cluster


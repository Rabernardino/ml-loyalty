

WITH tb_usuario_curso AS (
    SELECT
        idUsuario,
        descSlugCurso,
        COUNT(descSlugCursoEpisodio) as qtdeEps
    FROM
        cursos_episodios_completos
    WHERE
        DtCriacao < '2025-09-01'
    GROUP BY
        idUsuario,
        descSlugCurso
),

tb_cursos_total_eps AS (

    SELECT
        descSlugCurso,
        COUNT(nrEp) as qtdeTotalEps
    FROM
        cursos_episodios
    GROUP BY
        descSlugCurso
),

tb_pct_cursos AS (

    SELECT
        t1.idUsuario,
        t1.descSlugCurso,
        t1.qtdeEps,
        t2.qtdeTotalEps,
        ROUND(1. * t1.qtdeEps/t2.qtdeTotalEps,3) pctCursoCompleto
    FROM
        tb_usuario_curso t1
    LEFT JOIN
        tb_cursos_total_eps t2

    ON t1.descSlugCurso = t2.descSlugCurso
),

tb_usuario_cursos_pivot AS (

    SELECT
        idUsuario,
        SUM(CASE WHEN pctCursoCompleto = 1 THEN 1 ELSE 0 END) as qtedCursosCompletos,
        SUM(CASE WHEN pctCursoCompleto > 0 AND pctCursoCompleto < 1 THEN 1 ELSE 0 END) as qtedCursosIncompletos, 
        SUM(CASE WHEN descSlugCurso = 'carreira' THEN pctCursoCompleto ELSE 0 END) as carreira,
        SUM(CASE WHEN descSlugCurso = 'coleta-dados-2024' THEN pctCursoCompleto ELSE 0 END) as coletaDados2024,
        SUM(CASE WHEN descSlugCurso = 'ds-databricks-2024' THEN pctCursoCompleto ELSE 0 END) as dsDatabricks2024,
        SUM(CASE WHEN descSlugCurso = 'ds-pontos-2024' THEN pctCursoCompleto ELSE 0 END) as dsPontos2024,
        SUM(CASE WHEN descSlugCurso = 'estatistica-2024' THEN pctCursoCompleto ELSE 0 END) as estatistica2024,
        SUM(CASE WHEN descSlugCurso = 'estatistica-2025' THEN pctCursoCompleto ELSE 0 END) as estatistica2025,
        SUM(CASE WHEN descSlugCurso = 'github-2024' THEN pctCursoCompleto ELSE 0 END) as github2024,
        SUM(CASE WHEN descSlugCurso = 'github-2025' THEN pctCursoCompleto ELSE 0 END) as github2025,
        SUM(CASE WHEN descSlugCurso = 'ia-canal-2025' THEN pctCursoCompleto ELSE 0 END) as iaCanal2025,
        SUM(CASE WHEN descSlugCurso = 'lago-mago-2024' THEN pctCursoCompleto ELSE 0 END) as lagoMago2024,
        SUM(CASE WHEN descSlugCurso = 'loyalty-predict-2025' THEN pctCursoCompleto ELSE 0 END) as loyaltyPredict2025,
        SUM(CASE WHEN descSlugCurso = 'machine-learning-2025' THEN pctCursoCompleto ELSE 0 END) as machineLearning2025,
        SUM(CASE WHEN descSlugCurso = 'matchmaking-trampar-de-casa-2024' THEN pctCursoCompleto ELSE 0 END) as matchmakingTramparDeCasa2024,
        SUM(CASE WHEN descSlugCurso = 'ml-2024' THEN pctCursoCompleto ELSE 0 END) as ml2024,
        SUM(CASE WHEN descSlugCurso = 'mlflow-2025' THEN pctCursoCompleto ELSE 0 END) as mlflow2025,
        SUM(CASE WHEN descSlugCurso = 'nekt-2025' THEN pctCursoCompleto ELSE 0 END) as nekt2025,
        SUM(CASE WHEN descSlugCurso = 'pandas-2024' THEN pctCursoCompleto ELSE 0 END) as pandas2024,
        SUM(CASE WHEN descSlugCurso = 'pandas-2025' THEN pctCursoCompleto ELSE 0 END) as pandas2025,
        SUM(CASE WHEN descSlugCurso = 'python-2024' THEN pctCursoCompleto ELSE 0 END) as python2024,
        SUM(CASE WHEN descSlugCurso = 'python-2025' THEN pctCursoCompleto ELSE 0 END) as python2025,
        SUM(CASE WHEN descSlugCurso = 'speed-f1' THEN pctCursoCompleto ELSE 0 END) as speedF1,
        SUM(CASE WHEN descSlugCurso = 'sql-2020' THEN pctCursoCompleto ELSE 0 END) as sql2020,
        SUM(CASE WHEN descSlugCurso = 'sql-2025' THEN pctCursoCompleto ELSE 0 END) as sql2025,
        SUM(CASE WHEN descSlugCurso = 'streamlit-2025' THEN pctCursoCompleto ELSE 0 END) as streamlit2025,
        SUM(CASE WHEN descSlugCurso = 'trampar-lakehouse-2024' THEN pctCursoCompleto ELSE 0 END) as tramparLakehouse2024,
        SUM(CASE WHEN descSlugCurso = 'tse-analytics-2024' THEN pctCursoCompleto ELSE 0 END) as tseAnalytics2024

    FROM
        tb_pct_cursos
    GROUP BY
        idUsuario

),

tb_atividades AS (

    SELECT
        idUsuario,
        max(dtRecompensa) as dtCriacao
    FROM
        recompensas_usuarios
    WHERE
        dtRecompensa < '2025-09-01'
    GROUP BY
        idUsuario

    UNION ALL

    SELECT
        idUsuario,
        max(dtCriacao) as dtCriacao
    FROM
        habilidades_usuarios
    WHERE
        dtCriacao < '2025-09-01'
    GROUP BY
        idUsuario
        
    UNION ALL

    SELECT
        idUsuario,
        max(dtCriacao) as dtCriacao
    FROM
        cursos_episodios_completos
    WHERE
        dtCriacao < '2025-09-01'
    GROUP BY
        idUsuario
),

tb_ultima_atividade AS (

    SELECT
        idUsuario,
        MIN(julianday('2025-10-01') - julianday(dtCriacao)) as qtdeDiasUltimaInteracao
    FROM
        tb_atividades
    GROUP BY
        idUsuario
),

tb_join AS (

    SELECT
        t3.idTMWCliente as idCliente,
        t1.qtedCursosCompletos,
        t1.qtedCursosIncompletos,
        t1.carreira,
        t1.coletaDados2024,
        t1.dsDatabricks2024,
        t1.dsPontos2024,
        t1.estatistica2024,
        t1.estatistica2025,
        t1.github2024,
        t1.github2025,
        t1.iaCanal2025,
        t1.lagoMago2024,
        t1.loyaltyPredict2025,
        t1.machineLearning2025,
        t1.matchmakingTramparDeCasa2024,
        t1.ml2024,
        t1.mlflow2025,
        t1.nekt2025,
        t1.pandas2024,
        t1.pandas2025,
        t1.python2024,
        t1.python2025,
        t1.speedF1,
        t1.sql2020,
        t1.sql2025,
        t1.streamlit2025,
        t1.tramparLakehouse2024,
        t1.tseAnalytics2024,
        t2.qtdeDiasUltimaInteracao 
    FROM
        tb_usuario_cursos_pivot t1

    LEFT JOIN
        tb_ultima_atividade t2

    ON t1.idUsuario = t2.idUsuario

    INNER JOIN
        usuarios_tmw t3
    ON t1.idUsuario = t3.idUsuario

)

SELECT
    date('2025-10-01', '-1 day') as dtRef,
    *
FROM
    tb_join

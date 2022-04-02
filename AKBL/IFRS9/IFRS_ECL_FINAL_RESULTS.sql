/* Formatted on 4/2/2022 10:49:09 PM (QP5 v5.215.12089.38647) */
SELECT AA.N_ACCT_SKEY, AA.P_SUM - BB.P_SUM
  FROM    (  SELECT N_ACCT_SKEY, SUM (N_PRINCIPAL_RUN_OFF) AS P_SUM
               FROM FSI_CF_PROCESS_OUTPUTS A
              WHERE A.N_RUN_SKEY = 2200 AND N_PRINCIPAL_RUN_OFF > 0
           GROUP BY N_ACCT_SKEY) AA
       INNER JOIN
          (  SELECT N_ACCT_SKEY, SUM (N_PRINCIPAL_RUN_OFF) AS P_SUM
               FROM FSI_CF_PROCESS_OUTPUTS A
              WHERE A.N_RUN_SKEY = 2200 AND N_PRINCIPAL_RUN_OFF < 0
           GROUP BY N_ACCT_SKEY) BB
       ON AA.N_ACCT_SKEY = BB.N_ACCT_sKEY
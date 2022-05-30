select * from dim_run
order by n_run_Skey desc

SELECT SUM(M.N_MITIGANT_VALUE) FROM STG_MITIGANTS M
INNER JOIN (SELECT DISTINCT V_MITIGANT_CODE,FIC_MIS_DATE FROM STG_ACCOUNT_MITIGANT_MAP) E ON M.FIC_MIS_DATE=E.FIC_MIS_DATE AND E.V_MITIGANT_CODE=M.V_MITIGANT_CODE
WHERE M.FIC_MIS_DATE=:DATED

SELECT SUM(M.N_MITIGANT_VALUE),M.V_MITIGANT_TYPE_CODE,M.V_CCY_CODE FROM STG_MITIGANTS M
INNER JOIN (SELECT DISTINCT V_MITIGANT_CODE,FIC_MIS_DATE FROM STG_ACCOUNT_MITIGANT_MAP) E ON M.FIC_MIS_DATE=E.FIC_MIS_DATE AND E.V_MITIGANT_CODE=M.V_MITIGANT_CODE
WHERE M.FIC_MIS_DATE=:DATED
group by M.V_MITIGANT_TYPE_CODE,M.V_CCY_CODE

---------TOTAL MITIGANTS-------

SELECT DMT.V_MITIGANT_TYPE,SUM(M.N_MITIGANT_VALUE),SUM(M.N_MITIGANT_VALUE_NCY),M.V_CCY_CODE
 FROM FCT_MITIGANTS M
 INNER JOIN DIM_MITIGANT_TYPE DMT ON DMT.N_MITIGANT_TYPE_SKEY=M.N_MITIGANT_TYPE_SKEY
WHERE M.N_RUN_SKEY=1363
--AND m.N_MITIGANT_SKEY=2760201
AND M.N_MITIGANT_SKEY IN (SELECT DISTINCT N_MITIGANT_SKEY FROM EXP_MITIGANT_MAPPING M WHERE M.N_RUN_SKEY=1363)
GROUP BY DMT.V_MITIGANT_TYPE,M.V_CCY_CODE
ORDER BY DMT.V_MITIGANT_TYPE ,M.V_CCY_CODE

------------TOTAL EXPOSURE-----------------
SELECT SUM(FNSE.N_EAD_PRE_MITIGATION),SUM(FNSE.N_EXP_COVERED_AMT) ,DBPT.V_BASEL_PROD_TYPE_CODE_LEVEL1
FROM FCT_NON_SEC_EXPOSURES FNSE
INNER JOIN (SELECT DISTINCT s.N_ACCT_SKEY FROM exp_mitigant_mapping  S
inner join fct_mitigants fm on FM.N_RUN_SKEY=S.N_RUN_SKEY and S.N_MITIGANT_SKEY=FM.N_MITIGANT_SKEY and FM.N_MITIGANT_TYPE_SKEY is not null
WHERE S.N_RUN_SKEY=1363)D ON FNSE.N_ACCT_SKEY=D.N_ACCT_SKEY
left join dim_basel_product_type dbpt on DBPT.N_BASEL_PROD_TYPE_SKEY=FNSE.N_BASEL_PROD_TYPE_SKEY
WHERE FNSE.N_RUN_SKEY=1363
group by DBPT.V_BASEL_PROD_TYPE_CODE_LEVEL1


----all data---------
select d.V_EXPOSURE_ID,d.N_ACCT_SKEY,d.V_MITIGANT_CODE,d.N_MITIGANT_SKEY,d.N_EAD_PRE_MITIGATION,d.N_MITIGANT_VALUE,d.N_EXP_COVERED_FACTOR,d.N_EAD_POST_MITIGATION,FSE.N_EAD_POST_MITIGATION uncov_amt ,
d.V_EXP_MIT_POOL_CARDINALITY
,d.N_VOLATILITY_HAIRCUT,d.N_FOREX_HAIRCUT,d.N_MATURITY_MISMATCH_HAIRCUT
,d.V_STD_MITIGANT_TYPE_CODE,d.N_POOL_ID, DP.V_PARTY_ID ,DP.V_PROD_CODE,DP.V_PROD_DESC,DP.V_PROD_TYPE_DESC,V_MITIGANT_TYPE
FROM
(
SELECT DE.V_EXPOSURE_ID,FSE.N_ACCT_SKEY,DM.V_MITIGANT_CODE,FSE.N_MITIGANT_SKEY,FSE.N_EAD_PRE_MITIGATION,FSE.N_MITIGANT_VALUE,FSE.N_EXP_COVERED_FACTOR,FSE.N_EAD_POST_MITIGATION,NULL ,
FSE.V_EXP_MIT_POOL_CARDINALITY
,FSE.N_VOLATILITY_HAIRCUT,FSE.N_FOREX_HAIRCUT,FSE.N_MATURITY_MISMATCH_HAIRCUT
,DSMT.V_STD_MITIGANT_TYPE_CODE,FSE.N_POOL_ID,DMT.V_MITIGANT_TYPE
 FROM FCT_SUB_EXPOSURES FSE
LEFT JOIN DIM_STd_MITIGANT_TYPE DSMT ON DSMT.N_STD_MITIGANT_TYPE_SKEY=FSE.N_STD_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_MITIGANT_TYPE DMT ON DMT.N_MITIGANT_TYPE_SKEY=FSE.N_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_EXPOSURE DE ON DE.N_ACCT_SKEY=FSE.N_ACCT_SKEY
LEFT JOIN DIM_MITIGANT DM ON DM.N_MITIGANT_SKEY=FSE.N_MITIGANT_SKEY
WHERE FSE.N_RUN_SKEY=1363
AND DSMT.V_STD_MITIGANT_TYPE_CODE<>'UNCOV'
and FSE.V_EXP_MIT_POOL_CARDINALITY<>'1-0'
ORDER BY 
FSE.N_POOL_ID,FSE.N_ACCT_SKEY,FSE.N_MITIGANT_SKEY
)d left join fct_sub_exposures fse on fse.n_run_skey=1363 and FSE.N_ACCT_SKEY=d.n_acct_Skey and FSE.N_STD_MITIGANT_TYPE_SKEY=1
left join FCT_NON_SEC_EXPOSURES FNSE on fNse.n_run_skey=1363 and FNSE.N_ACCT_SKEY=d.n_acct_Skey
LEFT JOIN DIM_PRODUCT DP ON DP.N_PROD_SKEY=FNSE.N_PROD_SKEY
left join dim_party dp on DP.N_PARTY_SKEY=nvl(FNSE.N_ISSUER_SKEY,FNSE.N_CUST_SKEY)
ORDER BY 
d.N_POOL_ID,d.N_MITIGANT_SKEY


------------EXPOSURES------------------

SELECT DEE.V_EXPOSURE_ID,(FNSE.N_EAD_PRE_MITIGATION),(FNSE.N_EXP_COVERED_AMT)
,DPROD.V_PROD_CODE,DPROD.V_PROD_DESC,DPROD.V_PROD_TYPE_DESC,FNSE.N_ACCT_SKEY,FNSE.N_ENTITY_SKEY
FROM FCT_NON_SEC_EXPOSURES FNSE
INNER JOIN (SELECT DISTINCT s.N_ACCT_SKEY FROM exp_mitigant_mapping  S
inner join fct_mitigants fm on FM.N_RUN_SKEY=S.N_RUN_SKEY and S.N_MITIGANT_SKEY=FM.N_MITIGANT_SKEY and FM.N_MITIGANT_TYPE_SKEY is not null
WHERE S.N_RUN_SKEY=1363)D ON FNSE.N_ACCT_SKEY=D.N_ACCT_SKEY
LEFT JOIN DIM_PRODUCT DPROD ON DPROD.N_PROD_SKEY=FNSE.N_PROD_SKEY
left join dim_exposure dee on DEE.N_ACCT_SKEY=FNSE.N_ACCT_SKEY
WHERE FNSE.N_RUN_SKEY=1363

----------------MISCILLANEOUS-----------

SELECT LC.N_EOP_BAL*1.4255,LC.V_CCY_CODE,LC.V_CONTRACT_CODE,LC.N_ACCRUED_INTEREST,LC.N_PROVISION_AMOUNT,LC.F_PAST_DUE_FLAG,LC.N_CCF_PERCENT_DRAWN,
LC.N_EOP_BAL*1.4255*0.2
 FROM STG_LC_CONTRACTS LC 
WHERE LC.V_CONTRACT_CODE='001LCN1192210001'


SELECT  LC.N_GUARANTEE_AMT,LC.V_CCY_CODE,LC.V_CONTRACT_CODE,LC.N_PROVISION_AMOUNT,LC.N_CCF_PERCENT_DRAWN,
LC.N_GUARANTEE_AMT*LC.N_CCF_PERCENT_DRAWN FROM STG_GUARANTEES LC 
WHERE LC.V_CONTRACT_CODE='001LG01173550006'

SELECT LC.N_EOP_BAL,LC.V_CCY_CODE,LC.N_ACCRUED_INTEREST,LC.N_PROVISION_AMOUNT
 FROM STG_CARDS LC 
WHERE FIC_MIS_DATE=:DATED
AND LC.V_ACCOUNT_NUMBER='9720100001498'


SELECT LC.N_EOP_BAL,LC.V_CCY_CODE,LC.V_ACCOUNT_NUMBER,LC.N_ACCRUED_INTEREST,LC.N_LOAN_PROVISIONS_AMT
FROM STG_LOAN_CONTRACTS LC 
WHERE LC.V_ACCOUNT_NUMBER='1180100577790'

SELECT M.V_MITIGANT_CODE,M.N_MITIGANT_VALUE,M.V_CCY_CODE,A.* FROM STG_ACCOUNT_MITIGANT_MAP A
INNER JOIN STG_MITIGANTS M ON A.FIC_MIS_DATE=M.FIC_MIS_DATE AND A.V_MITIGANT_CODE=M.V_MITIGANT_CODE
WHERE A.FIC_MIS_DATE=:DATED
AND A.V_ACCOUNT_NUMBER IN '015AKTF00003313'

-- ('001LG01140980001',
'001LG01150210001',
'001LG01160470002')


SELECT FNSE.N_EAD_PRE_MITIGATION,FNSE.N_DRAWN_EAD_PRE_MITIGATION,FNSE.N_EXP_COVERED_AMT,FNSE.N_EXP_UNCOVERED_AMT
,FNSE.N_EXPOSURE_AMOUNT,FNSE.N_ACCRUED_INT
,FNSE.N_PROVISION_AMOUNT ,FNSE.N_ACCT_SKEY
FROM FCT_NON_SEC_EXPOSURES FNSE 
left join dim_exposure de on DE.N_ACCT_SKEY=FNSE.N_ACCT_SKEY
WHERE FNSE.N_RUN_SKEY=1363
--AND N_ACCT_SKEY=88820
and DE.V_EXPOSURE_ID='015AKTF00003313'




select d.*,FSE.N_EAD_POST_MITIGATION ll from 
(

SELECT DE.V_EXPOSURE_ID,FSE.N_ACCT_SKEY,DM.V_MITIGANT_CODE,FSE.N_MITIGANT_SKEY,
FSE.N_EAD_PRE_MITIGATION,FSE.N_MITIGANT_VALUE,FSE.N_EXP_COVERED_FACTOR,FSE.N_EAD_POST_MITIGATION,NULL ,
FSE.V_EXP_MIT_POOL_CARDINALITY
,FSE.N_VOLATILITY_HAIRCUT,FSE.N_FOREX_HAIRCUT,FSE.N_MATURITY_MISMATCH_HAIRCUT
,DSMT.V_STD_MITIGANT_TYPE_CODE
 FROM FCT_SUB_EXPOSURES FSE
LEFT JOIN DIM_STd_MITIGANT_TYPE DSMT ON DSMT.N_STD_MITIGANT_TYPE_SKEY=FSE.N_STD_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_MITIGANT_TYPE DMT ON DMT.N_MITIGANT_TYPE_SKEY=FSE.N_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_EXPOSURE DE ON DE.N_ACCT_SKEY=FSE.N_ACCT_SKEY
LEFT JOIN DIM_MITIGANT DM ON DM.N_MITIGANT_SKEY=FSE.N_MITIGANT_SKEY
WHERE FSE.N_RUN_SKEY=1363--1363
--AND FSE.N_ACCT_SKEY=88820
AND DM.V_MITIGANT_CODE='883068-LIENCSHF1'
--AND DSMT.V_STD_MITIGANT_TYPE_CODE<>'UNCOV'
--and FSE.V_EXP_MIT_POOL_CARDINALITY='1-1'
ORDER BY 
--FSE.N_MITIGANT_SKEY
FSE.N_ACCT_SKEY

)d left join fct_sub_exposures fse on fse.n_run_skey=1363 and FSE.N_ACCT_SKEY=d.n_acct_Skey and FSE.N_STD_MITIGANT_TYPE_SKEY=1
ORDER BY 
--FSE.N_MITIGANT_SKEY
d.N_ACCT_SKEY


--------------------------------------

select d.*,FSE.N_EAD_POST_MITIGATION ll from 
(
SELECT DE.V_EXPOSURE_ID,FSE.N_ACCT_SKEY,DM.V_MITIGANT_CODE,FSE.N_MITIGANT_SKEY,
FSE.N_EAD_PRE_MITIGATION,FSE.N_MITIGANT_VALUE,FSE.N_EXP_COVERED_FACTOR,FSE.N_EAD_POST_MITIGATION,NULL ,
FSE.V_EXP_MIT_POOL_CARDINALITY
,FSE.N_VOLATILITY_HAIRCUT,FSE.N_FOREX_HAIRCUT,FSE.N_MATURITY_MISMATCH_HAIRCUT
,DSMT.V_STD_MITIGANT_TYPE_CODE
 FROM FCT_SUB_EXPOSURES FSE
LEFT JOIN DIM_STd_MITIGANT_TYPE DSMT ON DSMT.N_STD_MITIGANT_TYPE_SKEY=FSE.N_STD_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_MITIGANT_TYPE DMT ON DMT.N_MITIGANT_TYPE_SKEY=FSE.N_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_EXPOSURE DE ON DE.N_ACCT_SKEY=FSE.N_ACCT_SKEY
LEFT JOIN DIM_MITIGANT DM ON DM.N_MITIGANT_SKEY=FSE.N_MITIGANT_SKEY
WHERE FSE.N_RUN_SKEY=1363
AND DSMT.V_STD_MITIGANT_TYPE_CODE<>'UNCOV'
and FSE.V_EXP_MIT_POOL_CARDINALITY='1-N'
ORDER BY 
--FSE.N_MITIGANT_SKEY
FSE.N_ACCT_SKEY
)d left join fct_sub_exposures fse on fse.n_run_skey=1363 and FSE.N_ACCT_SKEY=d.n_acct_Skey and FSE.N_STD_MITIGANT_TYPE_SKEY=1
ORDER BY 
--FSE.N_MITIGANT_SKEY
d.N_ACCT_SKEY



------------------N-1------------------

select d.*,FSE.N_EAD_POST_MITIGATION ll from 
(
SELECT DE.V_EXPOSURE_ID,FSE.N_ACCT_SKEY,DM.V_MITIGANT_CODE,FSE.N_MITIGANT_SKEY,FSE.N_EAD_PRE_MITIGATION,FSE.N_MITIGANT_VALUE,FSE.N_EXP_COVERED_FACTOR,FSE.N_EAD_POST_MITIGATION,NULL ,
FSE.V_EXP_MIT_POOL_CARDINALITY
,FSE.N_VOLATILITY_HAIRCUT,FSE.N_FOREX_HAIRCUT,FSE.N_MATURITY_MISMATCH_HAIRCUT
,DSMT.V_STD_MITIGANT_TYPE_CODE
 FROM FCT_SUB_EXPOSURES FSE
LEFT JOIN DIM_STd_MITIGANT_TYPE DSMT ON DSMT.N_STD_MITIGANT_TYPE_SKEY=FSE.N_STD_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_MITIGANT_TYPE DMT ON DMT.N_MITIGANT_TYPE_SKEY=FSE.N_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_EXPOSURE DE ON DE.N_ACCT_SKEY=FSE.N_ACCT_SKEY
LEFT JOIN DIM_MITIGANT DM ON DM.N_MITIGANT_SKEY=FSE.N_MITIGANT_SKEY
WHERE FSE.N_RUN_SKEY=1363
AND DSMT.V_STD_MITIGANT_TYPE_CODE<>'UNCOV'
and FSE.V_EXP_MIT_POOL_CARDINALITY='N-1'
ORDER BY 
FSE.N_MITIGANT_SKEY
)d left join fct_sub_exposures fse on fse.n_run_skey=1363 and FSE.N_ACCT_SKEY=d.n_acct_Skey and FSE.N_STD_MITIGANT_TYPE_SKEY=1
ORDER BY 
d.N_MITIGANT_SKEY
--d.N_ACCT_SKEY

-----------------n-n-----------------

select d.*,FSE.N_EAD_POST_MITIGATION COV_AMT
FROM
(

SELECT DE.V_EXPOSURE_ID,FSE.N_ACCT_SKEY,DM.V_MITIGANT_CODE,FSE.N_MITIGANT_SKEY,FSE.N_EAD_PRE_MITIGATION,FSE.N_MITIGANT_VALUE,FSE.N_EXP_COVERED_FACTOR,FSE.N_EAD_POST_MITIGATION,NULL ,
FSE.V_EXP_MIT_POOL_CARDINALITY
,FSE.N_VOLATILITY_HAIRCUT,FSE.N_FOREX_HAIRCUT,FSE.N_MATURITY_MISMATCH_HAIRCUT
,DSMT.V_STD_MITIGANT_TYPE_CODE,FSE.N_POOL_ID
 FROM FCT_SUB_EXPOSURES FSE
LEFT JOIN DIM_STd_MITIGANT_TYPE DSMT ON DSMT.N_STD_MITIGANT_TYPE_SKEY=FSE.N_STD_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_MITIGANT_TYPE DMT ON DMT.N_MITIGANT_TYPE_SKEY=FSE.N_MITIGANT_TYPE_SKEY
LEFT JOIN DIM_EXPOSURE DE ON DE.N_ACCT_SKEY=FSE.N_ACCT_SKEY
LEFT JOIN DIM_MITIGANT DM ON DM.N_MITIGANT_SKEY=FSE.N_MITIGANT_SKEY
WHERE FSE.N_RUN_SKEY=1363
AND DSMT.V_STD_MITIGANT_TYPE_CODE<>'UNCOV'
and FSE.V_EXP_MIT_POOL_CARDINALITY='N-N'
ORDER BY 
FSE.N_POOL_ID,FSE.N_MITIGANT_SKEY
--FSE.N_ACCT_SKEY

)d left join fct_sub_exposures fse on fse.n_run_skey=1363 and FSE.N_ACCT_SKEY=d.n_acct_Skey and FSE.N_STD_MITIGANT_TYPE_SKEY=1
ORDER BY 
d.N_POOL_ID,d.N_MITIGANT_SKEY





SELECT FSE.N_STD_MITIGANT_TYPE_SKEY,FSE.N_EAD_PRE_MITIGATION,FSE.N_MITIGANT_VALUE,FSE.N_EXP_COVERED_FACTOR,fse.*
FROM FCT_SUB_EXPOSURES fse
WHERE N_RUN_SKEY=1363
and n_acct_skey= 678624--105740--,678624

105740,

SELECT DISTINCT FNSE.N_PROD_SKEY
FROM FCT_NON_SEC_eXPOSURES FNSE
WHERE N_RUN_SKEY=1363


SELECT FNSE.N_EAD_PRE_MITIGATION,FNSE.N_DRAWN_EAD_PRE_MITIGATION
,FNSE.N_EXPOSURE_AMOUNT,FNSE.N_ACCRUED_INT
,FNSE.N_PROVISION_AMOUNT FROM FCT_NON_SEC_EXPOSURES FNSE WHERE FNSE.N_RUN_SKEY=1363
AND N_ACCT_SKEY=15403


SELECT DEE.V_EXPOSURE_ID,(FNSE.N_EAD_PRE_MITIGATION),(FNSE.N_EXP_COVERED_AMT)
,DPROD.V_PROD_CODE,DPROD.V_PROD_DESC,DPROD.V_PROD_TYPE_DESC,FNSE.N_ACCT_SKEY
FROM FCT_NON_SEC_EXPOSURES FNSE
INNER JOIN (SELECT DISTINCT DE.N_ACCT_SKEY FROM STG_ACCOUNT_MITIGANT_MAP  S
 INNER JOIN DIM_EXPOSURE DE ON DE.V_EXPOSURE_ID=S.V_ACCOUNT_NUMBER
WHERE S.FIC_MIS_DATE='31-DEC-2019')D ON FNSE.N_ACCT_SKEY=D.N_ACCT_SKEY
LEFT JOIN DIM_PRODUCT DPROD ON DPROD.N_PROD_SKEY=FNSE.N_PROD_SKEY
left join dim_exposure dee on DEE.N_ACCT_SKEY=FNSE.N_ACCT_SKEY
WHERE FNSE.N_RUN_SKEY=1363
/* Formatted on 4/20/2022 3:39:40 PM (QP5 v5.215.12089.38647) */
SELECT *
  FROM OFSRECON.STG_MR_SCRIPTS_SCHEDULE
 WHERE '08-JAN-2022' > D_FROM_DATE AND '08-JAN-2022' < D_TO_DATE;


/* Formatted on 4/20/2022 3:33:33 PM (QP5 v5.215.12089.38647) */
UPDATE STG_INVESTMENTS SI
   SET SI.N_COUPON_RATE = REC.N_COUPON_RATE, SI.N_COUPON_FREQUENCY = 0.5
FROM OFSRECON.STG_MR_SCRIPTS_SCHEDULE
WHERE V_ACCOUNT_NUMBER = REC.V_ACCOUNT_NUMBER
AND FIC_MIS_DATE = MIS_DATE;

MERGE INTO STG_INVESTMENTS SI
     USING (SELECT *
              FROM OFSRECON.STG_MR_SCRIPTS_SCHEDULE
             WHERE :MIS_DATE >= D_FROM_DATE AND :MIS_DATE < D_TO_DATE) SR
        ON (SI.V_ACCOUNT_NUMBER = SR.V_ACCOUNT_NUMBER
        AND SI.FIC_MIS_dATE = :MIS_dATE)
WHEN MATCHED
THEN
   UPDATE SET
      SI.N_COUPON = SR.N_COUPON_PRICE,
      SI.D_REPRICING_dATE = SR.D_TO_DATE,
      SI.N_COUPON_FREQUENCY = 24
      
           WHERE     SI.V_ACCOUNT_NUMBER = SR.V_ACCOUNT_NUMBER
                 AND SI.FIC_MIS_dATE = :MIS_DATE;


SELECT D_MATURITY_DATE, D_REPRICING_dATE, N_COUPON_FREQUENCY, N_COUPON, SI.D_NEXT_PAYMENT_DATE, SI.D_LAST_PAYMENT_dATE, SI.D_LAST_REPRICE_dATE 
FROM STG_INVESTMENTS SI 
WHERE V_aCCOUNT_NUMBER LIKE '%PKFRV%'
ORDER BY FIC_MIS_dATE DESC

SELECT * FROM OFSRECON.STG_DATA_ADAMS WHERE 


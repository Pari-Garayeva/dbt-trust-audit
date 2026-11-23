-- Grain: one row per order
-- Staging qaydası: yalnız BİR source oxu, yalnız təmizlə (rename, cast), join etmə

select 
 order_id
,customer_id
,amount
,status
from {{ source('raw', 'raw_orders') }}
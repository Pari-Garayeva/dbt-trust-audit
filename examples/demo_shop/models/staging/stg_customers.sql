select 
 customer_id
,name
,city
from {{ source('raw','raw_customers') }}
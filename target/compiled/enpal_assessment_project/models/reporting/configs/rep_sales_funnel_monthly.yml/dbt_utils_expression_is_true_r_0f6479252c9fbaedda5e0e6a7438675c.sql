



select
    1
from "postgres"."reporting"."rep_sales_funnel_monthly"

where not(deals_count >= 0)


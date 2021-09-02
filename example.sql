with table_disagg as 
(
    select
        distinct a.user_id
        ,a.created_at
        ,case
            when o.verified = 'true' then 'y'
            else 'n' end as pn_verified
        ,case
            when v.type in ('PAYMENT','PAYMENT_ID_BACK','PAYMENT_ID_FRONT') then 'y'
            else 'n' end as v_doc_1
        ,case
            when count(v.type) filter (where v.type like '%PAYMENT%') over (partition by v.owner_id) >= 3  then 'y'
            else 'n' end as v_doc_3
        ,case
            when s.owner_id is not null then 'y'
            else 'n' end as stripe_id
        ,case
            when s.charges_enabled = 'true' then 'y'
            else 'n' end as charges_enabled
        ,case
            when s.payouts_enabled = 'true' then 'y'
            else 'n' end as payouts_enabled
        ,case
            when ow.tt_fraud_status = 'APPROVED' then 'y'
            else 'n' end as fraud_status
        ,case
            when a.charges_created > 0 then 'y'
            else 'n' end as charges_created
        ,case
            when a.rent_payments_received > 0 then 'y'
            else 'n' end as rp_received
    from
        analytics_info a
        left join owner_verifications o on o.owner_id = a.user_id
        left join verification_documents v on v.owner_id = a.user_id
        left join stripe_identities s on s.owner_id = a.user_id
        left join owners ow on ow.id = a.user_id
    where
        a.onboarding_answer = 'RENT_PAYMENTS'
        and a.email not like '%turbotenant.com%'
        and a.created_at >= '2020-12-01'
    order by 1 desc
),

table_agg as 
(
    select
        date_trunc('month',created_at) as signup_month
        ,count(*) as total_signups
        ,count(*) filter (where pn_verified = 'y') as pn_verified_ct
        ,count(*) filter (where v_doc_1 = 'y') as v_doc_1_ct
        ,count(*) filter (where v_doc_3 = 'y') as v_doc_3_ct
        ,count(*) filter (where stripe_id = 'y') as stripe_id_ct
        ,count(*) filter (where charges_enabled = 'y') as charges_enabled_ct
        ,count(*) filter (where payouts_enabled = 'y') as payouts_enabled_ct
        ,count(*) filter (where fraud_status = 'y') as fraud_status_ct
        ,count(*) filter (where charges_created = 'y') as charges_created_ct
        ,count(*) filter (where rp_received = 'y') as rp_received_ct
    from
        table_disagg
    group by 1 
    order by 1 desc
)

select
    signup_month
    ,total_signups
    ,pn_verified_ct::numeric / total_signups::numeric as pn_verified_cvr
    ,v_doc_1_ct::numeric / total_signups::numeric as v_doc_1_cvr
    ,v_doc_3_ct::numeric / total_signups::numeric as v_doc_3_cvr
    ,stripe_id_ct::numeric / total_signups::numeric as stripe_id_cvr
    ,charges_enabled_ct::numeric / total_signups::numeric as charges_enabled_cvr
    ,payouts_enabled_ct::numeric / total_signups::numeric as payouts_enabled_cvr
    ,fraud_status_ct::numeric / total_signups::numeric as fraud_status_cvr
    ,charges_created_ct::numeric / total_signups::numeric as charges_created_cvr
    ,rp_received_ct::numeric / total_signups::numeric as rp_received_cvr
from
    table_agg

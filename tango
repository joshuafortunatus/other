with seventeen as
(
select
    l.city                  as city,
    l.state                 as state,
    count(distinct p.id)    as number_of_payments
from
            owners o
    join    listings l          on l.owner_id           = o.id
    join    rental_requests r   on r.listing_id         = l.id
    join    payments p          on p.rental_request_id  = r.id
where
    o.id not in (172484)
    and date_trunc('year',p.created_at at time zone 'utc') at time zone 'america/denver' = '2017-01-01'
group by 1,2
order by 2 desc
),

eighteen as
(
select
    l.city                  as city,
    count(distinct p.id)    as number_of_payments
from
            owners o
    join    listings l          on l.owner_id           = o.id
    join    rental_requests r   on r.listing_id         = l.id
    join    payments p          on p.rental_request_id  = r.id
where
    o.id not in (172484)
    and date_trunc('year',p.created_at at time zone 'utc') at time zone 'america/denver' = '2018-01-01'
group by 1
order by 2 desc
),

nineteen as
(
select
    l.city                  as city,
    count(distinct p.id)    as number_of_payments
from
            owners o
    join    listings l          on l.owner_id           = o.id
    join    rental_requests r   on r.listing_id         = l.id
    join    payments p          on p.rental_request_id  = r.id
where
    o.id not in (172484)
    and date_trunc('year',p.created_at at time zone 'utc') at time zone 'america/denver' = '2019-01-01'
group by 1
order by 2 desc
)

select
    initcap(s.city)                                                                                                     as "City",
    s.state                                                                                                             as "State",
    s.number_of_payments                                                                                                as "2017 Applications",
    e.number_of_payments                                                                                                as "2018 Applications",
    n.number_of_payments                                                                                                as "2019 Applications",
    e.number_of_payments - s.number_of_payments                                                                         as "Volume Growth from '17 to '18",
    n.number_of_payments - e.number_of_payments                                                                         as "Volume Growth from '18 to '19",
    round(100*((e.number_of_payments::numeric - s.number_of_payments::numeric)/s.number_of_payments::numeric),0)||'%'   as "Percentage Growth from '17 to '18",
    round(100*((n.number_of_payments::numeric - e.number_of_payments::numeric)/e.number_of_payments::numeric),0)||'%'   as "Percentage Growth from '18 to '19"
from
    seventeen s
    left join eighteen e on e.city = s.city
    left join nineteen n on n.city = s.city
where n.number_of_payments - e.number_of_payments is not null
group by 1,2,3,4,5
order by 7 desc
limit 50

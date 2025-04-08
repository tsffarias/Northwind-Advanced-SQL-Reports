with sources as (
    select
        order_id,
        product_id,
        unit_price,
        quantity,
        discount
    from {{ source('northwind', 'order_details') }}
)

select * from sources
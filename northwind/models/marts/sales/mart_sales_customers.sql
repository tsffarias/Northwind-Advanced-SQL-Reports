{{ config(
    schema='gold',
    materialized='table'
) }}

select * from {{ref('int_customers')}}
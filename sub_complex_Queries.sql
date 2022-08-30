use sql_invoicing;
select *
from clients
where client_id not in (select distinct invoices.client_id from invoices);


use sql_invoicing;
select *
from invoices i
where invoice_total > (select avg(invoice_total)
                       from invoices
                       where invoices.client_id =i.client_id);


use sql_store ;
select *
from products
where NOT EXISTS(
    select product_id
    from order_items
    where products.product_id = order_items.product_id
    );



use sql_invoicing;

select client_id , name,
       (select sum(invoice_total)
           from invoices
          where client_id= c.client_id )as total_sales,
       (select avg(invoice_total)
           from invoices) as avg_sales,
       (select total_sales - avg_sales) as difference
from clients c;

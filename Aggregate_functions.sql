use sql_invoicing;
select 'First have of 2019' As Date_range,
       SUM(invoice_total)  As Total_sales,
       SUM(payment_total)  As Total_payment,
       SUM(invoice_total - payment_total) As what_we_expect
from invoices
where invoice_date BETWEEN '2019-01-01' AND '2019-06-30'
union
select 'Second have of 2019' As Date_range,
       SUM(invoice_total)  As Total_sales,
       SUM(payment_total)  As Total_payment,
       SUM(invoice_total - payment_total) As what_we_expect
from invoices
where invoice_date BETWEEN '2019-07-01' AND '2019-12-30'
union
select 'Total' As Date_range,
       SUM(invoice_total)  As Total_sales,
       SUM(payment_total)  As Total_payment,
       SUM(invoice_total - payment_total) As what_we_expect
from invoices
where invoice_date BETWEEN '2019-01-01' AND '2019-12-30';


use sql_invoicing;

select date ,
       pm.name as payment_method,
       sum(amount) as total_payments
from payments p join payment_methods pm on pm.payment_method_id = p.payment_method
group by date, pm.name
order by date ;


use sql_store;

select c.customer_id,
       c.first_name,
       c.last_name,
       sum(oi.quantity * oi.unit_price) as Total_sales

from customers c join orders o using (customer_id)
                 join order_items oi using (order_id)
where  state='VA'
group by c.customer_id,
       c.first_name,
       c.last_name ;



use sql_invoicing;

select pm.name as payment_method,
       sum(amount) as total_payments
from payments p join payment_methods pm on pm.payment_method_id = p.payment_method
group by pm.name WITH ROLLUP ;



use sql_hr;

select *
from employees
where salary > (select avg(salary) from employees );

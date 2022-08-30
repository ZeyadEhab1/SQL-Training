USE sql_store;


SELECT order_id, first_name, last_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id ;






USE sql_store;

select o.product_id , quantity , o.unit_price
from order_items o join products p
on o.order_id = p.product_id ;








use sql_hr;

select e.employee_id , e.first_name , m.first_name
from employees e join employees m on e.reports_to = m.employee_id ;


use sql_invoicing;

select c.name as client_name , date , amount , pm.name , invoice_id
from payments join clients c on payments.client_id = c.client_id
join payment_methods pm on pm.payment_method_id = payments.payment_method ;






use sql_invoicing;

select c.name as client , date , amount , pm.name
from payments p join clients c using (client_id)
join payment_methods pm on pm.payment_method_id = p.payment_method ;







use sql_store ;
 select sh.name as shippers , p.name as products
from shippers sh cross join products p
order by sh.name ;


use sql_store ;

select customer_id , first_name , points , 'Bronze' as Type
from customers
where points < 2000
union
select customer_id , first_name , points , 'silver' as Type
from customers
where points BETWEEN 2000 and 3000
union
select customer_id , first_name , points , 'gold' as Type
from customers
where points > 3000
order by first_name;







use sql_invoicing;
create table sql_invoicing.inv_archive As
select invoice_id ,  number ,name , invoice_total , payment_total ,invoice_date , due_date ,payment_date
from invoices i join clients c using (client_id)
where payment_date is not null ;

use sql_store ;

update sql_store.customers
set points = points + 50 where birth_date < '1990-01-01';


use sql_store ;
update sql_store.orders
set comments = 'Golden customer'
where customer_id in
(select customers.customer_id from customers where points > '3000');
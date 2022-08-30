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
where salary > (select avg(salary)




                from employees );


use sql_invoicing;
select *
from clients
where client_id not in (select distinct invoices.client_id
                        from invoices);


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





use sql_store;
select concat(first_name, ' ' , last_name) as customer,
       ifnull(phone, 'UnKnown') as phone
from customers;







use sql_store;
select product_id , name ,
       count(*) As orders,
       if(count(*) > 1, 'Many times', 'once')
from products p join order_items oi using (product_id)
group by  product_id, name;



use sql_store;
select concat(first_name, ' ' , last_name),
       points,
       CASE
         when points > 3000 then 'Gold'
         when points >= 2000 then 'Silver'
         ELSE 'Bronze'
      END as catagory
from customers;


use sql_invoicing;
create view clinets_balance AS
    select client_id,name,
          sum(payment_total-i.invoice_total)as balance

from clients c join invoices i using (client_id)

group by client_id, name;






use sql_invoicing;


delimiter $$
create procedure get_clients()
begin
    select * from clients;
end $$

delimiter ;
call get_clients();




use sql_invoicing;
delimiter $

 create procedure get_invoices_with_balance()
 begin
     select * from invoices
         where invoice_total - invoices.payment_total >0 ;
 end $
 delimiter ;

 call get_invoices_with_balance();






use sql_invoicing ;

delimiter &

create procedure get_invoices_by_client(client_id int)
begin
    select *  from invoices i
        where i.client_id = client_id;
end &

 delimiter ;

call get_invoices_by_client(1);







use sql_invoicing;

delimiter &&
create procedure get_payments( client_id int , payment_method_id smallint)
begin
    if client_id is null and payment_method_id is null then
        select * from payments;

    else
        select * from payments p
            where p.client_id =client_id or payment_method = payment_method_id;

    end if;
end &&
 delimiter ;

call get_payments(NULL,NULL);
call get_payments(5,null);







use sql_invoicing;
delimiter &&&

create procedure get_risk_factor()
begin
    declare risk_factor decimal(9,2) default 0;
    declare invoices_total decimal(9,2);
    declare invoices_count int ;

    select count(*) , sum(invoice_total)
    into invoices_count , invoices_total
    from invoices;
    set risk_factor = invoices_total / invoices_count * 5;


    select risk_factor;

end &&&
delimiter ;

call get_risk_factor();








use sql_invoicing;

create function get_risk_factor_for_client(client_id int)
returns integer
reads sql data
begin
    declare risk_factor decimal(9,2) default 0;
    declare invoices_total decimal(9,2);
    declare invoices_count int ;

    select count(*) , sum(invoice_total)
    into invoices_count , invoices_total
    from invoices i
    where i.client_id = client_id;

    set risk_factor = invoices_total / invoices_count * 5;

    return ifnull(risk_factor , 0 );
end;


select client_id , name ,
       get_risk_factor_for_client(client_id) as risk_factor from clients;








use sql_invoicing ;

delimiter $$
create trigger payment_after_insert
    after insert on payments
    for each row
begin
    update invoices
    set payment_total = payment_total + NEW.amount
    where invoice_id = NEW.invoice_id;
end $$
delimiter ;


insert into payments
values (default, 5 , 3 , '2019-01-01' , 10 , 1);








USE sql_invoicing;
CREATE TABLE payments_audit (
client_id   INT            NOT NULL,

DATE        date           NOT NULL,

amount      DECIMAL (9, 2) NOT NULL,

action_type VARCHAR(50)    NOT NULL,


action_date DATETIME       NOT NULL

);

use sql_invoicing ;
 drop trigger if exists payment_after_insert;

delimiter $$$
create trigger payment_after_insert
    after insert on payments
    for each row
begin
    update invoices
    set payment_total = payment_total + NEW.amount
    where invoice_id = NEW.invoice_id;

    insert into payments_audit
    values (NEW.client_id , NEW.date , NEW.amount, 'insert' , now());
end $$$
delimiter ;



insert into payments
values (default, 5 , 3 , '2019-01-01' , 10 , 1);











CREATE database IF NOT EXISTS sql_store2;
use sql_store2 ;
create table customers (

    customer_id int primary key auto_increment,
    first_name varchar(50) NOT NULL ,
    points int not null default 0,
    email varchar(255) not null unique
);



ALTER table customers
add last_name varchar(50) not null after first_name,
    ADD city varchar(50)not null,
    drop points;


create table orders(
    order_id int primary key ,
    cutomer_id int not null,
    foreign key fk_osders_customers(cutomer_id) references customers (customer_id)
                   on update cascade
                   on delete no action
);



USE sql_store ;
select customer_id from customers where state = 'CA'
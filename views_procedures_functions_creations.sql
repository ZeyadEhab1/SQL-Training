

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


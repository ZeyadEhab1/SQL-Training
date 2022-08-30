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


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

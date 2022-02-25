CREATE TABLE category (
  category_id Serial Primary key,
  category_name varchar(255)
);

 CREATE TABLE Product
 (
   Product_id Serial Primary key,
   category_id int references category(category_id),
   Quantity int ,
   price int
 );

CREATE TABLE Cart
(
   Quantity_wished int ,
   Cart_id  Serial Primary key,
   Product_id int references product(product_id)
);
	
CREATE TABLE Customer
(
  Customer_id Serial Primary key,
  Name VARCHAR(20),
  Address VARCHAR(20) ,
  Phone_number varchar(20) ,
  email varchar(40),
  Cart_id int references cart(Cart_id)
 );
CREATE TABLE Orders
(
 order_id Serial Primary key ,
 order_date DATE ,
 order_type VARCHAR(10),
 Customer_id int REFERENCES Customer(Customer_id),
 Cart_id int REFERENCES cart(Cart_id),
 total_amount int
);
create table invoices
(
	invoice_id  serial primary key,
	order_id REFERENCES ORDERS(ORDER ID),
    order_date DATE ,
    order_type VARCHAR(10),
    Customer_id int REFERENCES Customer(Customer_id),
    Cart_id int REFERENCES cart(Cart_id),
    total_amount int
)

--VIEW
CREATE VIEW total_cost AS
    SELECT p.product_id,category_id,price,quantity,c.cart_id,c.quantity_wished
    from product p
	inner join 
	cart c 
	on 
	p.product_id=c.product_id ;
 
	

--insert
insert into Product(category_id,Quantity)  values(1,50);
insert into Cart(Quantity_wished,Product_id) values(2,1);
insert into category(category_name) values('jeans');
insert into Product(category_id,Quantity,price)  values(2,100,500);
insert into Cart(Quantity_wished,Product_id) values(1,1);
insert into category(category_name) values('Shirt');
insert into Customer(Name ,Address ,Phone_number,email,Cart_id) values('Ram','Delhi','9893135876','ram@google.com' '1');


select * from product,cart where product.product_id=cart.product_id;
select * from cart;
select * from category;
select * from customer;
select * from product;
select * from orders

--Trigger to add total cost to invoices table whenever order is added
create or replace function total_cost(cId in int)
    returns int
	language plpgsql
    as
	$$
    declare
   total_amt int;
	begin
    select sum(price) into total_amt from total_cost where cart_id=$1;
    return total_amt;
	end;
    $$;

create or replace function trigger_total_cost()
    returns trigger
	language plpgsql
    as
	$$
    declare
    total int;
    begin
    total=total_cost(new.cart_id);
	new.total_amount=total;
    insert into INVOICES(order_id,order_date,order_type,customer_id,cart_id) values(new.order_id,new.order_date,new.order_type,new.customer_id,new.cart_id);
	return new;
    end;
    $$;


    create or replace trigger before_payment
    after insert
    on
    orders
    FOR EACH ROW EXECUTE PROCEDURE trigger_total_cost();	
	
	
insert into orders(order_date,order_type,customer_id,cart_id) values(now(),'Cash',1,1)
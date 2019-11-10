create schema if not exists bd_labs;

drop table if exists bd_labs.Subscribers cascade;
drop table if exists bd_labs.Payment cascade;
drop table if exists bd_labs.Optionals cascade;
drop table if exists bd_labs.Tariff_plan cascade;
drop table if exists bd_labs.Subscriber_tariff cascade;

create table bd_labs.Subscribers
(
    id                        	serial primary key,
    name                    	varchar(50) not null,
    birthday_date            	date not null,
    passport_number         	varchar(10) not null,
    phone_number             	varchar(10) not null
);

create table bd_labs.Payment
(
    id                      	serial primary key,
    subscriber_id            	serial not null references bd_labs.Subscribers(id),
    summa                   	money not null,
    bill_number             	varchar(16) not null,
    paymentdate             	date not null
);

create table bd_labs.Optionals
(
    id                      	serial primary key,
    name                    	varchar(50) not null,
    price                    	money not null
);

create table bd_labs.Tariff_plan
(
    id                          	serial primary key,
    name                        	varchar(50) not null,
    price                        	money not null,
    min_same_operator           	money not null,
    min_dif_operator            	money not null,
    sms_same_operator            	money not null,
    sms_dif_operator            	money not null,
    internet_traffic            	int not null
);

create table bd_labs.Subscriber_tariff
(
    id                          	serial primary key,
    subscriber_id                	serial not null references bd_labs.Subscribers(id),
    optional_id                  	serial not null references bd_labs.Optionals(id),
    tariff_plan_id              	serial not null references bd_labs.Tariff_plan(id),
    connection_date                	date not null,
    end_date                    	date not null
);

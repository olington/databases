-- Скалярная функция
-- Средняя стоимость тарифа 
drop function if exists bd_labs.avg_tariff_price;

create function bd_labs.avg_tariff_price(tariff_name text) returns money
as
$$
select sum(price) / count(*)
from bd_labs.Tariff_plan
where name = tariff_name
$$
    language SQL
    stable
    returns null on null input;

select bd_labs.avg_tariff_price('Profitable');


-- Подставляемая табличная функция
-- Возвращает доп. услуги со стоимостью и датой подключения
drop function if exists bd_labs.subscriber_optionals;

create function bd_labs.subscriber_optionals(optional_name text)
    returns table
            (
				id					integer,
    			name        		varchar(50),
    			price        		money,
				connection_date		date
            )
as
$$
select bd_labs.Optionals.*, bd_labs.Subscriber_tariff.connection_date
from bd_labs.Optionals join bd_labs.Subscriber_tariff on Optionals.id = Subscriber_tariff.optional_id
where name = optional_name
$$ language SQL
    stable
    returns null on null input;
	
select * from bd_labs.subscriber_optionals('MMS');


-- Многооператорная табличная функция
-- Возвращает доп. услуги со стоимостью и датой подключения
drop function if exists bd_labs.p_subscriber_optionals;

create function bd_labs.p_subscriber_optionals(optional_name text)
    returns table
            (
                id					integer,
    			name        		varchar(50),
    			price        		money,
				connection_date		date
            )
as
$$
begin
    return query select bd_labs.Optionals.*, bd_labs.Subscriber_tariff.connection_date
                 from bd_labs.Optionals join bd_labs.Subscriber_tariff on Optionals.id = Subscriber_tariff.optional_id
                 where Optionals.name = optional_name;
end;
$$ language plpgsql
    stable
    returns null on null input;

select * from bd_labs.p_subscriber_optionals('MMS');


-- Рекурсивную функцию или функцию с рекурсивным ОТВ
-- Подключение тарифа по убыванию даты
drop function if exists bd_labs.tariffs_by_time(tariff_name text);

create function bd_labs.tariffs_by_time(tariff_name text)
    returns table
            (
				tariff_id			integer,
                tariff_name      	varchar(50),
                connection_date		date,
				tariff_num			integer
            )
as
$$
with recursive tariffs_time as ( 
    select Subscriber_tariff.id, Tariff_plan.name, Subscriber_tariff.connection_date as time, 1 as tariff_num
        from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
        where Tariff_plan.name = tariff_name and connection_date = (
            select max(connection_date)
                from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
                where Tariff_plan.name = tariff_name)

    union all
	
    select Subscriber_tariff.id, Tariff_plan.name, Subscriber_tariff.connection_date, tariff_num + 1
        from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
        join tariffs_time on Subscriber_tariff.connection_date < tariffs_time.time
        where Tariff_plan.name = tariff_name and connection_date in (
                select connection_date
                    from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
                    where Tariff_plan.name = tariff_name
                    order by connection_date desc
                    offset tariff_num
                    limit 1
            )
)
select *
from tariffs_time;
$$
    language SQL
    stable
    returns null on null input;

select *
from bd_labs.tariffs_by_time('Unlimited');



drop function if exists bd_labs.subs_info;

create function bd_labs.subs_info(n integer) returns text
as
$$
select concat(bd_labs.Subscribers.id, ' | ', bd_labs.Subscribers.name, ' | ', 
			  bd_labs.Subscribers.birthday_date, ' | ', bd_labs.Subscribers.passport_number, ' | ',
			  bd_labs.Subscribers.phone_number)
from bd_labs.Subscribers join bd_labs.Subscriber_tariff on Subscribers.id = Subscriber_tariff.subscriber_id
where Subscriber_tariff.subscriber_id = n
$$
    language SQL
    stable
    returns null on null input;

select bd_labs.subs_info(100);



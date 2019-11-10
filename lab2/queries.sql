-- #1
-- Инструкция SELECT, использующая предикат сравнения.
-- Получить список тарифов, включающих больше 10Гб интернет траффика и со стоимость меньше 50$
select distinct internet_traffic, price
from bd_labs.Tariff_plan
where internet_traffic > 10 and price < 50::money;

-- #2
-- Инструкция SELECT, использующая предикат BETWEEN.
-- Получить список абонентов, подключившихся между 2018-01-01 и 2019-01-01
select distinct Subscriber_tariff.*
from bd_labs.Subscriber_tariff
where connection_date between '2018-01-01' and '2019-01-01'
order by connection_date

-- #3
-- Инструкция SELECT, использующая предикат LIKE.
-- Получить список доп. услуг со словом 'call' в названии
select distinct name
from bd_labs.Optionals
where name like 'Call%';

-- #4
-- Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Получить список тарифов с доп. услугой 'Mobile bank'
select distinct *
from bd_labs.Subscriber_tariff
where optional_id in (
	select O.id
	from bd_labs.Subscriber_tariff as ST join bd_labs.Optionals as O on ST.optional_id = O.id
	where name = 'Mobile bank'
)
order by optional_id;

-- #5
-- Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Получить список с доп. услуг 'Mobile bank'
select *
from bd_labs.Optionals as Opt
where exists (
    select O.id, O.name
   	from bd_labs.Subscriber_tariff as ST join bd_labs.Optionals as O on ST.optional_id = O.id
   	where name = 'Mobile bank' and O.id = Opt.id
);

-- #6
-- Инструкция SELECT, использующая предикат сравнения с квантором.
-- Получить список абонентов с самым большим счетом для оплаты
select distinct S.id, S.name, P.summa
from bd_labs.Subscribers as S join bd_labs.Payment as P
	on S.id = P.subscriber_id
where P.summa >= all(
	select summa from bd_labs.Payment
);

-- #7
-- Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- Среднее значение интернет-трафика в тарифных планах
select avg(internet_traffic) as actual_avg, sum(internet_traffic) / count(id) as calc_avg
from (
	select id, internet_traffic 
	from bd_labs.Tariff_plan
	group by id
 ) as avg_traffic

-- #8
-- Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Получить список абонентов с фамилией Смит, их максимальные платежи по счету и максимальный платеж среди абонентов Смит
select distinct Subscribers.*, max(Payment.summa), 
	(
    	select max(Payment.summa)
    	from bd_labs.Subscribers join bd_labs.Payment
        	 on Payment.subscriber_id = Subscribers.id
    	where name like '%Smith'
	) as max_pay
from bd_labs.Payment join bd_labs.Subscriberson Subscribers.id = Payment.subscriber_id
where name like '%Smith'
group by Subscribers.id;

-- # 9
-- Инструкция SELECT, использующая простое выражение CASE.
-- Оценка стоимости тарифа
select name,
	case min_same_operator
	when 0::money then 'one minute is free'
	when 1::money then 'one minute is 1$'
	when 2::money then 'one minute is 2$'
	end as min_same_operator
from bd_labs.Tariff_plan

-- # 10
-- Инструкция SELECT, использующая поисковое выражение CASE.
-- Оценка стоимости тарифа
select price,
	case 
	when price > 50::money then 'expensive'
	when price > 25::money then 'fair'
	when price < 25::money then 'inexpensive'
	end as price_status
from bd_labs.Tariff_plan

-- # 11
-- Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- Новая таблица с абонентами и датой подключения их тарифа
select S.*, ST.connection_date
into temp subscriber_connection
from bd_labs.Subscribers as S join bd_labs.Subscriber_tariff as ST on S.id = ST.subscriber_id
order by S.id;
select * from subscriber_connection;
drop table subscriber_connection;

-- # 12
-- Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
-- Абоненты с тарифом Optimal
select Subscribers.*, subs_with_optimal.name
from bd_labs.Subscribers join (
    select *
    from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan
         on Subscriber_tariff.subscriber_id = Tariff_plan.id
    where Tariff_plan.name = 'Optimal'
) as subs_with_optimal on Subscribers.id = subs_with_optimal.subscriber_id;

-- # 13
-- Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Получить список, всех абонентов, которые подключили тариф со стоимость выше средней, но меньше 50
select distinct id, name
    from bd_labs.Subscribers
    where id in (
        select distinct Subscribers.id
        from bd_labs.Subscribers
        join bd_labs.Subscriber_tariff on Subscribers.id = Subscriber_tariff.subscriber_id
        join bd_labs.Tariff_plan on Subscriber_tariff.tariff_plan_id = Tariff_plan.id
        group by Subscribers.id
        having min(price::numeric) >= all (
                select avg(price::numeric)
                from bd_labs.Subscribers
           		join bd_labs.Subscriber_tariff on Subscribers.id = Subscriber_tariff.subscriber_id
            	join bd_labs.Tariff_plan on Subscriber_tariff.tariff_plan_id = Tariff_plan.id
                where Subscribers.id in (
                       select Subscribers.id
                       from bd_labs.Subscribers
           			   join bd_labs.Subscriber_tariff on Subscribers.id = Subscriber_tariff.subscriber_id
            		   join bd_labs.Tariff_plan on Subscriber_tariff.tariff_plan_id = Tariff_plan.id
                       group by Subscribers.id
                       having max(price) < 50::money
					   notnull
						) group by Subscribers.id
                )
        );

-- # 14
-- Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Средняя стоимость каждого тарифа, подключенного в определенное число
select connection_date, (select sum(price) / count(*)
	from bd_labs.Tariff_plan
	join bd_labs.Subscriber_tariff on Tariff_plan.id = Subscriber_tariff.tariff_plan_id) as avg
from bd_labs.Subscriber_tariff
group by connection_date;

-- # 15
-- Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Даты подключений тарифов со стоимостью меньше 50
select connection_date, price
from bd_labs.Tariff_plan join bd_labs.Subscriber_tariff on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
group by connection_date, price
having price::numeric < 50;

-- # 16
-- Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
select setval('bd_labs.Subscribers_id_seq', max(id))
from bd_labs.Subscribers;
insert into bd_labs.Subscribers(name, birthday_date, passport_number, phone_number)
values ('Name Surname', '1984-07-07', '1234567891', '1234567891');
select * from bd_labs.Subscribers;

--  # 17
-- Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
select setval('bd_labs.Payment_id_seq', max(id))
from bd_labs.Payment;
insert into bd_labs.Payment(subscriber_id, summa, bill_number, paymentdate)
select (select id
         from bd_labs.Subscribers
         where name = 'Name Surname'),
	20::money, '1234567890987654','1990-05-04';
select * from bd_labs.Payment;

-- # 18
-- Простая инструкция UPDATE.
update bd_labs.Optionals
set price = price * 1.2
where id = 10;

-- # 19
-- Инструкция UPDATE со скалярным подзапросом в предложении SET.
update bd_labs.Optionals
set price = (
        select avg(price::numeric)
        from bd_labs.Optionals
        where id = 11
    )
where id = 11;

-- # 20
-- Простая инструкция DELETE.
delete from bd_labs.Payment
where subscriber_id = 200;

-- # 21
-- Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
delete from bd_labs.Payment
where id in (
    select Subscribers.id
        from bd_labs.Subscribers
        where name = 'Name Username'
);

-- # 22
-- Инструкция SELECT, использующая простое обобщенное табличное выражение
with family_tariff as (
    select id, name
        from bd_labs.Tariff_plan
        where name = 'Family'
)
select Subscriber_tariff.*, name
from bd_labs.Subscriber_tariff join family_tariff on family_tariff.id = tariff_plan_id;
	
-- # 23
-- Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
-- Подключение тарифа Unlimited по убыванию даты
with recursive tariffs_time as ( 
	-- Определение закрепленного элемента
    select Subscriber_tariff.id, Tariff_plan.name, Subscriber_tariff.connection_date as time, 1 as tariff_num
        from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
        where Tariff_plan.name = 'Unlimited' and connection_date = (
            select max(connection_date)
                from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
                where Tariff_plan.name = 'Unlimited')

    union all
	
	-- Определение рекурссивного элемента
    select Subscriber_tariff.id, Tariff_plan.name, Subscriber_tariff.connection_date, tariff_num + 1
        from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
        join tariffs_time on Subscriber_tariff.connection_date < tariffs_time.time
        where Tariff_plan.name = 'Unlimited' and connection_date in (
                select connection_date
                    from bd_labs.Subscriber_tariff join bd_labs.Tariff_plan on Tariff_plan.id = Subscriber_tariff.tariff_plan_id
                    where Tariff_plan.name = 'Unlimited'
                    order by connection_date desc
                    offset tariff_num
                    limit 1
            )
)
select * from tariffs_time;

-- Инструкция, использующая ОТВ SELECT ManagerID, EmployeeID, Title, DeptID, Level FROM DirectReports ;
-- # 24
-- Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
select id, name, price,
       (avg(price::numeric) over(partition by name))::money as avg_price,
	   (min(price::numeric) over(partition by name))::money as min_price,
	   (max(price::numeric) over(partition by name))::money as max_price
from bd_labs.Tariff_plan
	
-- #25
-- Оконные фнкции для устранения дублей
select setval('bd_labs.Tariff_plan_id_seq', max(id))
from bd_labs.Tariff_plan;
insert into bd_labs.Tariff_plan(name, price, min_same_operator, min_dif_operator, sms_same_operator, sms_dif_operator, internet_traffic)
select name, price, min_same_operator, min_dif_operator, sms_same_operator, sms_dif_operator, internet_traffic
from bd_labs.Tariff_plan
where id < 10;

delete from bd_labs.Tariff_plan
where id in (
    select Tariff_plan.id
    from bd_labs.Tariff_plan
    join (select id, row_number() over (partition by name, price, min_same_operator, min_dif_operator, sms_same_operator, sms_dif_operator, internet_traffic) as rn
            from bd_labs.Tariff_plan) as TP on TP.id = Tariff_plan.id
    where rn > 1);
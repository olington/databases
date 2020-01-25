drop table workers;
drop table holidays_type;
drop table holidays;

create table workers (
    id      	integer primary key,
    name   		varchar(50)
);

create table holidays_type (
    id      	integer primary key,
    type    	varchar(50)
);

create table holidays (
    id      	integer primary key,
    worker_id   integer,
    date    	date,
    type_id    	integer
);

insert into workers values (1, 'Иванов Иван Иванович');
insert into workers values (2, 'Петров Петр Петрович');
insert into workers values (3, 'Васильев Василий Васильевич');

insert into holidays_type values (1, 'Отпуск');
insert into holidays_type values (2, 'Больничный');
insert into holidays_type values (3, 'За свой счёт');

insert into holidays
values (1, 1, '2019-12-20', 1);
insert into holidays
values (2, 1, '2019-12-21', 1);
insert into holidays
values (3, 1, '2019-12-22', 1);
insert into holidays
values (4, 1, '2019-12-23', 1);
insert into holidays
values (5, 1, '2019-12-24', 3);
insert into holidays
values (6, 1, '2019-12-25', 3);
insert into holidays
values (7, 2, '2019-12-22', 2);
insert into holidays
values (8, 2, '2019-12-23', 2);
insert into holidays
values (9, 2, '2019-12-24', 2);
insert into holidays
values (10, 2, '2019-12-25', 2);
insert into holidays
values (11, 2, '2019-12-26', 2);
insert into holidays
values (12, 3, '2019-12-24', 3);
insert into holidays
values (13, 1, '2020-01-24', 3);
insert into holidays
values (14, 1, '2020-01-25', 3);

with
tmp1 as (
    select *
    from (
        select *,
               lag(date)  over(partition by worker_id, type_id order by worker_id, date) as lag_d,
               lead(date) over(partition by worker_id, type_id order by worker_id, date) as lead_d
        from holidays
    ) x
    where (date - lag_d > 1 or lead_d - date > 1) or (lag_d is null or lead_d is null)
),
tmp2 as (
    select *
    from tmp1

    union all

    select *
    from tmp1
    where lag_d is null and lead_d is null
),
tmp3 as (
    select worker_id, date as date_start, type_id,
           lead(date) over(order by worker_id, date) as date_end,
           row_number() over(order by worker_id, date) as rn
    from tmp2
)

select row_number() over(order by date_start, name) as id, name, date_start, date_end, type
from tmp3 join workers
    on tmp3.worker_id = workers.id
          join holidays_type
    on tmp3.type_id = holidays_type.id
where rn % 2 = 1;
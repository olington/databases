CREATE EXTENSION plpythonu;

--  1) Определяемая пользователем скалярная функция
-- Кол-во пользователей, у которых подключен определенный тариф
create or replace function get_subscribers_count(tariff_name varchar)
  returns varchar
as $$
o = plpy.execute("select * from bd_labs.Subscriber_tariff")
a = plpy.execute("select * from bd_labs.Tariff_plan")
count = 0
for row_o in o:
    for row_a in a:
        if row_o['tariff_id'] == row_a['id'] and row_a['name'] == tariff_name:
            count += 1
return count
$$ language plpythonu;

-- 2) Пользовательская агрегатная функция
-- Кол-во тарифов, поключенных в заданный промежуток времени
CREATE OR REPLACE FUNCTION count_connection_range(a integer, b integer)
  RETURNS integer
AS $$
count = 0
for row in plpy.execute("select connection_date from bd_abs.Subscriber_tariff;"):
    tmp = int(row['connection_date'][:4])
    if tmp >= a and tmp <= b:
         count += 1
return count
$$ LANGUAGE plpythonu;

SELECT * FROM count_connection_range(2010, 2012);

-- 3) Определяемая пользователем табличная функция
-- Таблица с определенным тарифом
CREATE OR REPLACE FUNCTION get_table (_tf text)
  RETURNS table (name text, price money)
AS $$
rv = plpy.execute('SELECT * FROM bd_labs.Tariff_plan')
res = []
for row in rv:
    if (row['name'] == _tf):
        res.append(row)
return res
$$ LANGUAGE plpythonu;

SELECT * FROM get_table('Optimal');

-- 4) Хранимая процедура
-- Для абонента с заданным id изменить номер телефона
CREATE OR REPLACE PROCEDURE update_subscriber_phone(_id integer, _new_phone varcar(11))
LANGUAGE plpythonu
AS $$
plan = plpy.prepare("UPDATE bd_labs.Subscribers SET phone_number = _new_phone WHERE phone_num = $1", ['integer'])

rv = plpy.execute(plan, [_id])
$$;

CALL update_subscriber_phone(1, '89999999999');

SELECT * FROM bd_labs.Subscribers;

--  5) Триггер
-- Вместо удапаления абонента помечать его как "отключившегося"
alter table bd_labs.Subscribers add column disconnected boolean;
update bd_labs.Subscribers set disconnected = false;
CREATE VIEW subs_view AS SELECT * FROM bd_labs.Subscribers;

CREATE OR REPLACE FUNCTION subs_instead_delete()
RETURNS trigger 
AS $$
plan = plpy.prepare("UPDATE bd_labs.Subscribers SET disconnected = true where id = $1;", ['integer'])
rv = plpy.execute(plan, [TD['old']['id']])
return TD['new']
$$ LANGUAGE plpythonu;

CREATE TRIGGER trigger_sub
INSTEAD OF DELETE ON
subs_view FOR EACH ROW
EXECUTE PROCEDURE subs_instead_delete();

DELETE FROM subs_view WHERE id = 1;

SELECT * FROM bd_labs.Subscribers;

-- 6) Определяемый пользователем тип данных
-- Информация о пользователе: имя, номер пасспорта, номер телефона
CREATE TYPE sub_info AS (

  sub_name varchar,
  sub_passport varchar,
  sub_phone varchar
);

create or replace function get_sub_info(_id integer)
returns sub_info
as $$
f = plpy.execute("select * from bd_labs.Subscribers;")
for row in f:
    if row['id'] == _id:
        return (row['name'], row['passport_number'], row['phone_number'])
$$ language plpythonu;

SELECT * FROM get_sub_info(1);
-- Хранимая процедура без параметров или с параметрами
-- Удаляет дупликаты
drop procedure if exists bd_labs.delete_duplicate_optionals();

create procedure bd_labs.delete_duplicate_optionals()
    language sql
as
$$
delete
from bd_labs.Optionals
where id in (
    select Optionals.id
    from bd_labs.Optionals
             join (select id, row_number() over (partition by id, name, price) as rn
                   from bd_labs.Optionals) as Opt on Opt.id = Optionals.id
    where rn > 1
);
$$;

call bd_labs.delete_duplicate_optionals();

-- Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
-- Увеличивает стоимость тарифа в два раза
create or replace procedure bd_labs.recursive_proc(n integer)
    language plpgsql as
$$
begin
    if (n < 10) then
        update bd_labs.Tariff_plan set price = price * 2 where id = n;
        call recursive_proc(n + 1);
    end if;
end;
$$;

-- Хранимая процедура с курсором
-- Увеличивает стоимость смс на два
create or replace procedure bd_labs.tariff_price(name char)
    language plpgsql
as
$$
declare
    curs cursor for select *
                    from bd_labs.Tariff_plan
                    where Tariff_plan.name = name;
begin
    update bd_labs.Tariff_plan set sms_same_operator = sms_same_operator * 2 where current of curs;
    close curs;
end;
$$;


-- Хранимая процедура доступа к метаданным
-- Выводит каталог и схему
create or replace procedure bd_labs.table_info(in name text)
    language plpgsql
as
$$
declare
    c record;
begin
    select table_catalog, table_schema into c from information_schema.columns where table_name = name;
    raise notice 'Catalog: %, schema: %', c.table_catalog, c.table_schema;
end
$$;

call bd_labs.table_info('Tariff_plan');

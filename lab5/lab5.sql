-- Использование JSON с базами данных

-- 1) Из таблиц базы данных, созданной в ЛР 1,
-- извлечь данные с помощью функций создания JSON.
select row_to_json(Subscribers) from bd_labs.Subscribers;
select to_json(Subscribers) from bd_labs.Subscribers;
select json_build_array(row(Subscribers)) from bd_labs.Subscribers;

-- 2) Выполниить загрузку и сохранение данных с JSON-документом
-- Сохранение в JSON
copy (select row_to_json(Subscribers) from bd_labs.Subscribers)
to '/Users/olga/Documents/3 course/5 semester/databases/lab5/jsSub.json';

copy (select array_to_json(array_agg(row_to_json(Tariff_plan))) from bd_labs.Tariff_plan)
to '/Users/olga/Documents/3 course/5 semester/databases/lab5/jsTP.json';

-- 3) Загрузка из JSON-файла
create temp table if not exists subscriber_info (
	id                        	serial primary key,
    name                    	varchar(50) not null,
    birthday_date            	date not null,
    passport_number         	varchar(10) not null,
    phone_number             	varchar(10) not null
);

create unlogged table docSub(doc json);
copy docSub from '/Users/olga/Documents/3 course/5 semester/databases/lab5/jsSub.json';
select * from docSub;

insert into subscriber_info (
    id, name, birthday_date, passport_number, phone_number)
select r.*
from docSub,
lateral json_populate_record(null::subscriber_info, doc) r;

select * from subscriber_info;

truncate subscriber_info;

-- 3) Работа с JSON-схемой
-- 	1. Создать JSON-схему для какого-либо документа,
-- 	набрав описание вручную с помощью какого-либо текстового редактора.

-- 	2. Создать JSON-схему из документа генератором.

-- 4) Написать консольное приложение на языке Python, которое выполняет проверку
-- допустимости разработанного в текущей ЛР JSON-документа, используя JSON-схему.
-- Проведите эксперименты с XML-документом и убедитесь в том, что
-- приложение действительно обнаруживает ошибки при проверке допустимости.

create schema if not exists rk2;

drop table if exists rk2.child cascade;
drop table if exists rk2.vaccination cascade;
drop table if exists rk2.policlinic cascade;
drop table if exists rk2.CV cascade;
drop table if exists rk2.VP cascade;

create table rk2.child
(
	id 						serial primary key,
	fio 					varchar(50) not null,
	birthday 				date not null,
	adress					varchar(50) not null,
	parent_number			varchar(10) not null
);

create table rk2.vaccination
(
	id 						serial primary key,
	name 					varchar(50) not null,
	description 			varchar(50) not null
);

alter table rk2.vaccination
	add constraint name_not_empty check ( name != '' );
	
create table rk2.policlinic
(
	id 						serial primary key,
	name 					varchar(50) not null,
	establishment_date 		date not null,
	description 			varchar(50) not null
);

create table rk2.CV
(
	id 						serial primary key,
	child_id				serial not null references rk2.child(id),
	vac_id					serial not null references rk2.vaccination(id)
);

create table rk2.VP
(
	id 						serial primary key,
	vac_id					serial not null references rk2.vaccination(id),
	pol_id					serial not null references rk2.policlinic(id)
);

insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(1, 'Ivanov II', cast('2000-09-01' as date), 'ul. Abrikosovaya', '1234567890');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(2, 'Petrov PP', cast('2005-12-03' as date), 'ul. Vinogradnaya', '1234567891');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(3, 'Vasechkin VV', cast('2010-09-01' as date), 'ul. 8 Marta', '1234567892');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(4, 'Sidorov SS', cast('2009-09-09' as date), 'ul. Lenina', '1234567893');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(5, 'Ivanov AA', cast('2010-10-01' as date), 'ul. Lenina', '1234567894');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(6, 'Morz AB', cast('2005-01-10' as date), 'ul. Letchikov', '1234567895');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(7, 'Morozov HD', cast('2013-09-01' as date), 'ul. Pervaya', '1234567896');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(8, 'Zhuchkin NF', cast('2013-09-02' as date), 'ul. Abrikosovaya', '1234567897');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(9, 'Ivanov II', cast('2007-01-01' as date), 'ul. Vinogradnaya', '1234567898');
insert into rk2.child(id, fio, birthday, adress, parent_number) values
	(10, 'Polunov MN', cast('2008-02-04' as date), 'ul. Vtoraya', '1234567899');
	
insert into rk2.vaccination(id, name, description) values
	(1, 'Xxx', 'Flu');
insert into rk2.vaccination(id, name, description) values
	(2, 'Yyy', 'Flu');
insert into rk2.vaccination(id, name, description) values
	(3, 'Zzz', 'Flu');
insert into rk2.vaccination(id, name, description) values
	(4, 'Grrr', 'Flu');
insert into rk2.vaccination(id, name, description) values
	(5, 'Jjj', 'Flu');
insert into rk2.vaccination(id, name, description) values
	(6, 'Xyz', 'Sick');
insert into rk2.vaccination(id, name, description) values
	(7, 'Nnn', 'Sick');
insert into rk2.vaccination(id, name, description) values
	(8, 'Hhh', 'Sick');
insert into rk2.vaccination(id, name, description) values
	(9, 'Qqq', 'Sick');
insert into rk2.vaccination(id, name, description) values
	(10, 'Lll', 'Sick');

insert into rk2.policlinic(id, name, establishment_date, description) values
	(1, 'One', cast('1990-02-04' as date), 'Good');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(2, 'Two', cast('1999-02-04' as date), 'Very good');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(3, 'Three', cast('1947-02-04' as date), 'Best');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(4, 'Four', cast('1979-02-04' as date), 'Bad');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(5, 'Five', cast('1989-02-04' as date), 'Very bad');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(6, 'Six', cast('1988-02-04' as date),'Good');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(7, 'Seven', cast('1959-02-04' as date), 'Good');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(8, 'Eight', cast('1977-02-04' as date),'Bad');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(9, 'Nine', cast('1940-02-04' as date), 'Bad');
insert into rk2.policlinic(id, name, establishment_date, description) values
	(10, 'Ten', cast('1991-02-04' as date), 'Worst');
	

-- Инструкция SELECT, использующая предикат сравнения.
-- Дети, рожденные не раньше 2006 года
select distinct *
from rk2.child
where birthday > cast('2006-01-01' as date);

-- Инструкция, использующая оконную функцию
-- Оконная фнкция для устранения дублей
select setval('rk2.vaccination_id_seq', max(id))
from rk2.vaccination;
insert into rk2.vaccination(name, description)
select name, description
from rk2.vaccination
where id < 3;
delete from rk2.vaccination
where id in (
    select vaccination.id
    from rk2.vaccination
    join (select id, row_number() over (partition by name, description) as rn
            from rk2.vaccination) as V on V.id = vaccination.id
    where rn > 1);
	
-- Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM
-- Поликлиники, где делают прививки от гриппа
select policlinics_flu.*
from rk2.policlinic right join (
    select VP.pol_id, vaccination.name, vaccination.description
    from rk2.policlinic right join rk2.VP on VP.pol_id = policlinic.id right join rk2.vaccination on VP.vac_id = vaccination.id
    where vaccination.description = 'Flu'
) as policlinics_flu on policlinic.id = policlinics_flu.pol_id;

-- Процедура
create or replace procedure rk2.table_info(in name text)
    language plpgsql
as
$$
declare
    c record;
begin
    select constraint_catalog, constraint_schema, constraint_name, check_clause into c from information_schema.check_constraints 
	where constraint_name = 'check' and check_clause = 'like';
    raise notice 'Catalog: %, schema: %, name: %, clause: %', c.constraint_catalog, c.constraint_schema, c.constraint_name, c.check_clause;
end
$$;

call rk2.table_info('vaccination');
create table Table1
(
	id 					int not null,
	var1 				varchar(1) not null,
	valid_from_dttm 	date not null,
	valid_to_dttm 		date not null
);

create table Table2
(
	id 					int not null,
	var2 				varchar(1) not null,
	valid_from_dttm 	date not null,
	valid_to_dttm 		date not null
);

--select * from Table1 cross join Table2;

insert into Table1(id, var1, valid_from_dttm, valid_to_dttm) values
	(1, 'A', cast('2018-09-01' as date), cast('2018-09-15' as date));
insert into Table1(id, var1, valid_from_dttm, valid_to_dttm) values
	(1, 'B', cast('2018-09-16' as date), cast('5999-12-31' as date));

insert into Table2(id, var2, valid_from_dttm, valid_to_dttm) values
	(1, 'A', cast('2018-09-01' as date), cast('2018-09-18' as date));
insert into Table2(id, var2, valid_from_dttm, valid_to_dttm) values
	(1, 'B', cast('2018-09-19' as date), cast('5999-12-31' as date));
	
select distinct T1.id, var1, var2, greatest(T1.valid_from_dttm, T2.valid_from_dttm) as valid_from,
	least(T1.valid_to_dttm, T2.valid_to_dttm) as valid_to
from Table1 T1, Table2 T2 where T1.id = T2.id 
	and (T1.valid_from_dttm, T1.valid_to_dttm) overlaps (T2.valid_from_dttm, T2.valid_to_dttm)
order by T1.id;
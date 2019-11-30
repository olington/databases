-- Триггер AFTER
create or replace function show_old_and_new() returns trigger as
$show_old_and_new$
begin
    raise notice 'Old: id: %, name: %s, birthday_date: %, passport_number: %, phone_number: %', 
					old.id, old.name, old.birthday_date, old.passport_number, old.phone_number;
    raise notice 'New: id: %, name: %s, birthday_date: %, passport_number: %, phone_number: %', 
					new.id, new.name, new.birthday_date, new.passport_number, new.phone_number;
    return null;
end;
$show_old_and_new$ language plpgsql;

drop trigger show_old_and_new_trigger
    on bd_labs.Subscribers;
	
create trigger show_old_and_new_trigger
    after update
    on bd_labs.Subscribers for each row
execute procedure show_old_and_new();

update bd_labs.Subscribers
set name = 'Sam Sam'
where id = 3;


-- Триггер INSTEAD OF
drop view if exists bd_labs.Subscribers_view;
create view bd_labs.Subscribers_view as
select Subscribers.*, count(t.id)
from bd_labs.Subscribers
         join bd_labs.Payment as t on t.subscriber_id = Subscribers.id
group by Subscribers.id;

create or replace function update_sub_view() returns trigger as
$update_sub_view$
declare
    pay integer;
begin
    insert into bd_labs.Subscribers(name, birthday_date, passport_number, phone_number)
    values (initcap(name), new.birthday_date, new.passport_number, new.phone_number);

    select count(*)
    into pay
    from bd_labs.Subscribers
         join bd_labs.Payment on Payment.subscriber_id = Subscribers.id
    where subscriber_id = new.id;

    insert into bd_labs.Subscribers_view
    values (new.id, pay);

    return new;
end;
$update_sub_view$ language plpgsql;

create trigger check_number
    instead of insert
    on bd_labs.Subscribers_view for each row
execute procedure update_sub_view();

alter table bd_labs.Subscribers
    add constraint name_not_empty check ( name != '' ),
	add constraint passport_len check ( length(passport_number) = 10),
	add constraint passport_unique unique ( passport_number ),
	add constraint phone_len check ( length(phone_number) = 10),
	add constraint phone_unique unique ( phone_number );
	
alter table bd_labs.Payment
	add constraint bill_len check ( length(bill_number) = 16),
	add constraint bill_unique unique ( bill_number ),
	add constraint summa_not_neg check ( summa::numeric > 0 );

alter table bd_labs.Optionals
	add constraint name_not_empty check ( name != '' ),
	add constraint price_not_neg check ( price::numeric > 0 );

alter table bd_labs.Tariff_plan
	add constraint name_not_empty check ( name != '' ),
    add constraint price_not_neg check ( price::numeric > 0 );
	
alter table bd_labs.Subscriber_tariff
	add constraint end_after_connection check ( connection_date < end_date );
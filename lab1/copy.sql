truncate table bd_labs.Subscribers cascade;
truncate table bd_labs.Payment cascade;
truncate table bd_labs.Optionals cascade;
truncate table bd_labs.Tariff_plan cascade;
truncate table bd_labs.Subscriber_tariff cascade;

copy bd_labs.Subscribers
    from '/Users/olga/Documents/3 course/5 semester/databases/lab1/generator/subscribers.txt'   (delimiter '|');
copy bd_labs.Payment
    from '/Users/olga/Documents/3 course/5 semester/databases/lab1/generator/payment.txt' (delimiter '|');
copy bd_labs.Optionals
    from '/Users/olga/Documents/3 course/5 semester/databases/lab1/generator/optionals.txt'     (delimiter '|');
copy bd_labs.Tariff_plan
    from '/Users/olga/Documents/3 course/5 semester/databases/lab1/generator/tariff_plan.txt'    (delimiter '|');
copy bd_labs.Subscriber_tariff
    from '/Users/olga/Documents/3 course/5 semester/databases/lab1/generator/subscriber_tariff.txt'    (delimiter '|');
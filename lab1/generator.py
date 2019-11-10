import random
from random import randint
import faker as f

faker = f.Faker()

def generate_subscribers(num):
    subscribers = []
    for i in range(num):
        name = faker.name()
        birthday = faker.date_between(start_date="-70y", end_date="-10y").strftime('%Y-%m-%d')
        passport_number = ''.join([str(random.randint(0, 9)) for i in range(10)])
        phone_number = ''.join([str(random.randint(0, 9)) for i in range(10)])
        subscribers.append((i, name, birthday, passport_number, phone_number))
    return subscribers


def generate_payment(num, subs_num):
    payment = []
    for i in range(num):
        subscribers_id = random.randint(0, subs_num - 1)
        summa = randint(0, 500)
        bill_number = ''.join([str(random.randint(0, 9)) for i in range(16)])
        payment_date = faker.date_between(start_date="-1m", end_date="+1m").strftime('%Y-%m-%d')
        payment.append((i, subscribers_id, summa, bill_number, payment_date))
    return payment


def generate_optional_service(num):
    optionals = []
    for i in range(num):
        name = random.choice(
            ('Mobile bank',
             'Calling line identification presentation',
             'Location-based service',
             'Call forwarding',
             'MMS',
             'Call hold',
             'Conference call')
        )
        cost = randint(0, 10)
        optionals.append((i, name, cost))
    return optionals


def generate_tariff_plan(num):
    tariff_plan = []
    for i in range(num):
        tariff = random.choice(
            ('Profitable',
             'Optimal',
             'Best price',
             'Family',
             'Unlimited')
        )
        price = randint(20, 100)
        one_min_same_operator = randint(0, 2)
        one_min_dif_operator = randint(0, 3)
        one_sms_same_operator = randint(0, 1)
        one_sms_dif_operator = randint(0, 2)
        internet_traffic = randint(0, 100)
        tariff_plan.append((i, tariff, price, one_min_same_operator, one_min_dif_operator,
                            one_sms_same_operator, one_sms_dif_operator, internet_traffic))
    return tariff_plan


def generate_subscriber_tariff(num, optionals_num, plans_num, subs_num):
    subscriber_tariff = []
    for i in range(num):
        subscribers_id = random.randint(0, subs_num - 1)
        optionals_id = random.randint(0, optionals_num - 1)
        tariffplan_id  = random.randint(0, plans_num - 1)
        connection_date = faker.date_between(start_date="-5y", end_date="-1y").strftime('%Y-%m-%d')
        end_date = faker.date_between(start_date="+5y", end_date="+7y").strftime('%Y-%m-%d')
        subscriber_tariff.append((i, subscribers_id, tariffplan_id, optionals_id, connection_date, end_date))
    return subscriber_tariff


if __name__ == '__main__':
    number = 1000

    with open('subscribers.txt', 'w') as f:
        subscribers = generate_subscribers(number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}\n'.format(*subscribers[i]))


    with open('payment.txt', 'w') as f:
        payment = generate_payment(number, number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}\n'.format(*payment[i]))


    with open('optionals.txt', 'w') as f:
        optionals = generate_optional_service(number)
        for i in range(number):
            f.write('{}|{}|{}\n'.format(*optionals[i]))


    with open('tariff_plan.txt', 'w') as f:
        tariff_plan = generate_tariff_plan(number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}|{}|{}|{}\n'.format(*tariff_plan[i]))


    with open('subscriber_tariff.txt', 'w') as f:
        subscriber_tariff = generate_subscriber_tariff(number, number, number, number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}|{}\n'.format(*subscriber_tariff[i]))

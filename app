# TelegramBot

import telebot
from config import TOKEN, currencies
from extensions import ConvertionException, CurrencyConversion

bot = telebot.TeleBot(TOKEN)


@bot.message_handler(commands=['start'])
def start(messege: telebot.types.Message):
    text = f' Привет!!! Хотите узнать, что я могу, введите команду /help'
    bot.reply_to(messege, text)


@bot.message_handler(commands=['help'])
def help_(messege: telebot.types.Message):
    text = '''
    Конвертация валют:
    /values - показывает доступные валюты
    Сначала введите количество переводимой валюты и её название потом в какую нужно перевести.
    Чтобы начать работу введите команду в формате: 100 доллар рубль
    '''
    bot.reply_to(messege, text)


@bot.message_handler(commands=['values'])
def values(messege: telebot.types.Message):
    text = 'Доступные валюты:\n'
    for currency in currencies.keys():
        text += currency + '\n'
    bot.reply_to(messege, text)


@bot.message_handler(content_types=['text'])
def convert(messege: telebot.types.Message):
    try:
        text_values = messege.text.split()

        if len(text_values) != 3:
            bot.reply_to(messege, f'Количество параметров не равно 3.'
                                  f'Хотите узнать как вводить запрос нажмите /help')
            raise ConvertionException()
        amount, quote, base = text_values
        total_base = CurrencyConversion.get_price(amount, quote, base)
    except ConvertionException as e:
        bot.reply_to(messege, f'Неверно введен запрос.\n{e}'
                              f'\nНужна помощь нажми /help')
    except Exception as e:
        bot.reply_to(messege, f'Не удалось обработать команду.\n{e}')
    else:
        text = f'{amount} {quote} = {total_base:.2f} {base}'
        bot.send_message(messege.chat.id, text)


bot.polling()

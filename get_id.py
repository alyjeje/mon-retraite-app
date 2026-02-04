from telegram import Update
from telegram.ext import Application, MessageHandler, filters

async def show_id(update: Update, context):
    user_id = update.message.from_user.id
    await update.message.reply_text(f"Ton Telegram user ID est : {user_id}")

app = Application.builder().token("8532024412:AAEY1cqIZRu03Xt9HGXSk83bViuDS6x5wg4").build()
app.add_handler(MessageHandler(filters.TEXT, show_id))
print("Bot lancé, envoie un message sur Telegram...")
app.run_polling()
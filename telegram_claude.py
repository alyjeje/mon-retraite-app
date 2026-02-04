import subprocess
import os
from telegram import Update
from telegram.ext import Application, MessageHandler, CommandHandler, filters, ContextTypes

# Config
TELEGRAM_TOKEN = "8532024412:AAEY1cqIZRu03Xt9HGXSk83bViuDS6x5wg4"
PROJECT_DIR = r"C:\Users\PC\mon_prototype"
ALLOWED_USERS = [1818672915]

# Historique des conversations
conversations = {}

def get_context(chat_id):
    if chat_id in conversations:
        return "\n".join(conversations[chat_id][-10:])
    return "Nouvelle conversation"

def save_context(chat_id, role, message):
    if chat_id not in conversations:
        conversations[chat_id] = []
    conversations[chat_id].append(f"{role}: {message}")

def run_claude(prompt, chat_id):
    system_prompt = (
        "Si tu as besoin d'une precision, commence ta reponse par [QUESTION]. "
        "Si tu as besoin d'une autorisation pour une action risquee, commence par [AUTORISATION]. "
        "Si tu as termine avec succes, commence par [OK]. "
        "Si une erreur s'est produite, commence par [ERREUR]."
    )
    
    full_prompt = f"{system_prompt} Contexte: {get_context(chat_id)} Demande: {prompt}"
    
    # Ecrire le prompt dans un fichier temporaire
    prompt_file = os.path.join(PROJECT_DIR, ".claude_prompt.txt")
    with open(prompt_file, "w", encoding="utf-8") as f:
        f.write(full_prompt)
    
    result = subprocess.run(
        f'type "{prompt_file}" | "C:\\Users\\PC\\AppData\\Roaming\\npm\\claude.cmd" -p --output-format text --dangerously-skip-permissions',
        capture_output=True,
        text=True,
        cwd=PROJECT_DIR,
        timeout=300,
        encoding="utf-8",
        shell=True
    )
    
    print(f"STDOUT: {result.stdout[:200]}")
    print(f"STDERR: {result.stderr[:200]}")
    print(f"RETURN CODE: {result.returncode}")
    
    return result.stdout.strip()

def auto_push(commit_msg):
    try:
        subprocess.run(
            f'git add . && git commit -m "{commit_msg[:50]}" && git push',
            shell=True, cwd=PROJECT_DIR, capture_output=True, timeout=60
        )
        return True
    except:
        return False

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.message.from_user.id
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("⛔ Accès refusé")
        return
    
    prompt = update.message.text
    chat_id = str(update.message.chat_id)
    
    save_context(chat_id, "Utilisateur", prompt)
    await update.message.reply_text("⏳ Claude Code travaille...")
    
    try:
        response = run_claude(prompt, chat_id)
        save_context(chat_id, "Claude", response)
        
        if response.startswith("[QUESTION]"):
            clean = response.replace("[QUESTION]", "").strip()
            await update.message.reply_text(f"❓ {clean}")
            
        elif response.startswith("[AUTORISATION]"):
            clean = response.replace("[AUTORISATION]", "").strip()
            await update.message.reply_text(
                f"⚠️ Claude demande ton autorisation:\n\n{clean}\n\n"
                f"Réponds 'oui' pour valider ou 'non' pour annuler."
            )
            
        elif response.startswith("[OK]"):
            clean = response.replace("[OK]", "").strip()
            pushed = auto_push(prompt)
            push_msg = "\n📦 Pushé → Codemagic build en cours" if pushed else ""
            await update.message.reply_text(f"✅ {clean}{push_msg}")
            
        elif response.startswith("[ERREUR]"):
            clean = response.replace("[ERREUR]", "").strip()
            await update.message.reply_text(f"❌ {clean}")
            
        else:
            if len(response) > 4000:
                for i in range(0, len(response), 4000):
                    await context.bot.send_message(int(chat_id), response[i:i+4000])
            else:
                await update.message.reply_text(response or "✅ Terminé")
                
    except subprocess.TimeoutExpired:
        await update.message.reply_text("⏰ Timeout (5 min)")
    except Exception as e:
        await update.message.reply_text(f"❌ Erreur: {str(e)}")

async def cmd_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.from_user.id not in ALLOWED_USERS:
        return
    result = subprocess.run(
        ["git", "log", "--oneline", "-5"],
        capture_output=True, text=True, cwd=PROJECT_DIR
    )
    await update.message.reply_text(f"📋 Derniers commits:\n{result.stdout}")

async def cmd_reset(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = str(update.message.chat_id)
    conversations[chat_id] = []
    await update.message.reply_text("🔄 Conversation reset.")

async def cmd_revert(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.from_user.id not in ALLOWED_USERS:
        return
    result = subprocess.run(
        'git revert HEAD --no-edit && git push',
        shell=True, capture_output=True, text=True, cwd=PROJECT_DIR
    )
    if result.returncode == 0:
        await update.message.reply_text("⏪ Dernier commit annulé et pushé.")
    else:
        await update.message.reply_text(f"❌ Erreur revert: {result.stderr}")

def main():
    app = Application.builder().token(TELEGRAM_TOKEN).build()
    app.add_handler(CommandHandler("status", cmd_status))
    app.add_handler(CommandHandler("reset", cmd_reset))
    app.add_handler(CommandHandler("revert", cmd_revert))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    print("🤖 Bot Telegram → Claude Code actif!")
    print(f"📁 Projet: {PROJECT_DIR}")
    app.run_polling()

if __name__ == "__main__":
    main()

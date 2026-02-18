import asyncio
import subprocess
import os
import time
import traceback
import logging
from collections import deque
from telegram import Update
from telegram.ext import Application, MessageHandler, CommandHandler, filters, ContextTypes

# Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S"
)
log = logging.getLogger("TelegramBot")

# Config
TELEGRAM_TOKEN = os.environ.get("TELEGRAM_TOKEN")
if not TELEGRAM_TOKEN:
    print("ERREUR: Variable d'environnement TELEGRAM_TOKEN non definie!")
    print('Lance avec: $env:TELEGRAM_TOKEN="ton_token"; python telegram_claude.py')
    exit(1)

PROJECT_DIR = r"C:\Users\PC\mon_prototype"
ALLOWED_USERS = [1818672915]
CLAUDE_CMD = r"C:\Users\PC\AppData\Roaming\npm\claude.cmd"
TIMEOUT_SECONDS = 600  # 10 min (au lieu de 30)
HEARTBEAT_INTERVAL = 120  # Message "toujours en cours" toutes les 2 min

# Historique des conversations
conversations = {}

# File d'attente des messages (au lieu de rejeter quand busy)
message_queue: deque = deque()
is_processing = False
processing_start_time = 0
current_process: subprocess.Popen | None = None
current_chat_id: str | None = None


def get_context(chat_id):
    if chat_id in conversations:
        return "\n".join(conversations[chat_id][-10:])
    return "Nouvelle conversation"


def save_context(chat_id, role, message):
    if chat_id not in conversations:
        conversations[chat_id] = []
    conversations[chat_id].append(f"{role}: {message}")


async def run_claude_async(prompt, chat_id, bot):
    """Lance Claude CLI dans un thread separe avec heartbeat de progression."""
    global current_process

    system_prompt = (
        "Tu es un assistant de developpement. Voici tes regles OBLIGATOIRES:\n\n"

        "REPONSES:\n"
        "- Si tu as besoin d'une precision, commence ta reponse par [QUESTION].\n"
        "- Si tu as besoin d'une autorisation pour une action risquee, commence par [AUTORISATION].\n"
        "- Si tu as termine avec succes, commence par [OK].\n"
        "- Si une erreur s'est produite, commence par [ERREUR].\n\n"

        "GIT ET BUILD:\n"
        "- Avant CHAQUE git push, tu DOIS incrementer le build number dans pubspec.yaml "
        "(version: X.Y.Z+N devient X.Y.Z+N+1). Ne jamais push sans avoir incremente le build number.\n\n"

        "PYTHON ET REQUIREMENTS:\n"
        "- Dans requirements.txt, specifie TOUJOURS des versions compatibles (ex: numpy<2.0, flask>=2.0.0).\n"
        "- Evite les versions trop recentes qui peuvent avoir des incompatibilites.\n"
        "- Apres avoir cree ou modifie un backend Python, TESTE-LE en executant le fichier principal.\n"
        "- Si le test echoue, analyse l'erreur, corrige le code, et reteste jusqu'a ce que ca marche.\n"
        "- Ne push jamais du code backend sans l'avoir teste et verifie qu'il demarre sans erreur.\n\n"

        "IMPORTANT:\n"
        "- Ne lance JAMAIS de serveur (Flask, FastAPI, etc.) car ils tournent indefiniment et bloquent.\n"
        "- Pour tester un backend, utilise 'timeout 5 python app.py' ou verifie juste la syntaxe avec 'python -c \"import app\"'.\n"
        "- Si on te demande de relancer un serveur, dis que c'est impossible depuis Claude Code et qu'il faut le faire manuellement.\n\n"

        "QUALITE:\n"
        "- Teste toujours ton code avant de push.\n"
        "- Si tu detectes une erreur, corrige-la automatiquement.\n"
        "- Sois proactif: anticipe les problemes potentiels."
    )

    full_prompt = f"{system_prompt}\n\nContexte conversation:\n{get_context(chat_id)}\n\nDemande: {prompt}"

    prompt_file = os.path.join(PROJECT_DIR, ".claude_prompt.txt")
    with open(prompt_file, "w", encoding="utf-8") as f:
        f.write(full_prompt)

    cmd = f'type "{prompt_file}" | "{CLAUDE_CMD}" -p --output-format text --dangerously-skip-permissions'

    # Lancer le subprocess avec Popen pour pouvoir le tuer
    def _blocking_run():
        global current_process
        try:
            current_process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=PROJECT_DIR,
                encoding="utf-8",
                shell=True,
                errors="replace"
            )
            stdout, stderr = current_process.communicate(timeout=TIMEOUT_SECONDS)
            returncode = current_process.returncode
            current_process = None

            log.info(f"Claude STDOUT ({len(stdout)} chars): {stdout[:300]}")
            if stderr:
                log.warning(f"Claude STDERR: {stderr[:200]}")
            log.info(f"Claude return code: {returncode}")

            if returncode != 0 and not stdout.strip():
                return f"[ERREUR] Claude Code a termine avec le code {returncode}. Stderr: {stderr[:500]}"

            return stdout.strip()
        except subprocess.TimeoutExpired:
            if current_process:
                log.warning("Timeout - killing Claude process")
                current_process.kill()
                current_process.wait()
                current_process = None
            raise
        except Exception:
            current_process = None
            raise

    # Lancer le heartbeat en parallele du traitement
    heartbeat_task = asyncio.create_task(
        _heartbeat_loop(bot, int(chat_id))
    )

    try:
        result = await asyncio.to_thread(_blocking_run)
        return result
    finally:
        heartbeat_task.cancel()
        try:
            await heartbeat_task
        except asyncio.CancelledError:
            pass


async def _heartbeat_loop(bot, chat_id):
    """Envoie des messages de progression toutes les HEARTBEAT_INTERVAL secondes."""
    elapsed = 0
    try:
        while True:
            await asyncio.sleep(HEARTBEAT_INTERVAL)
            elapsed += HEARTBEAT_INTERVAL
            minutes = elapsed // 60
            remaining = (TIMEOUT_SECONDS - elapsed) // 60
            await bot.send_message(
                chat_id,
                f"Toujours en cours... ({minutes} min ecoulees, timeout dans {remaining} min)\n"
                f"Envoie /cancel pour annuler."
            )
    except asyncio.CancelledError:
        pass


async def send_response(update: Update, context: ContextTypes.DEFAULT_TYPE, chat_id: str, response: str):
    """Envoie la reponse formatee sur Telegram."""
    if response.startswith("[QUESTION]"):
        clean = response.replace("[QUESTION]", "").strip()
        await context.bot.send_message(int(chat_id), f"? {clean}")

    elif response.startswith("[AUTORISATION]"):
        clean = response.replace("[AUTORISATION]", "").strip()
        await context.bot.send_message(
            int(chat_id),
            f"Claude demande ton autorisation:\n\n{clean}\n\n"
            f"Reponds 'oui' pour valider ou 'non' pour annuler."
        )

    elif response.startswith("[OK]"):
        clean = response.replace("[OK]", "").strip()
        await context.bot.send_message(int(chat_id), f"{clean}")

    elif response.startswith("[ERREUR]"):
        clean = response.replace("[ERREUR]", "").strip()
        await context.bot.send_message(int(chat_id), f"Erreur: {clean}")

    else:
        text = response or "(Reponse vide - Claude Code n'a rien retourne)"
        # Telegram limite a 4096 chars par message
        if len(text) > 4000:
            for i in range(0, len(text), 4000):
                await context.bot.send_message(int(chat_id), text[i:i+4000])
        else:
            await context.bot.send_message(int(chat_id), text)


async def process_queue(context: ContextTypes.DEFAULT_TYPE):
    """Traite les messages en file d'attente un par un."""
    global is_processing, processing_start_time, current_chat_id

    if is_processing:
        return

    is_processing = True
    try:
        while message_queue:
            update, prompt, chat_id = message_queue.popleft()
            processing_start_time = time.time()
            current_chat_id = chat_id

            queue_size = len(message_queue)
            status_msg = "Claude Code travaille..."
            if queue_size > 0:
                status_msg += f" ({queue_size} message(s) en attente apres celui-ci)"
            status_msg += f"\nTimeout: {TIMEOUT_SECONDS // 60} min. Envoie /cancel pour annuler."
            await context.bot.send_message(int(chat_id), status_msg)

            try:
                response = await run_claude_async(prompt, chat_id, context.bot)
                elapsed = int(time.time() - processing_start_time)
                save_context(chat_id, "Claude", response)
                await send_response(update, context, chat_id, response)
                log.info(f"Request completed in {elapsed}s")

            except subprocess.TimeoutExpired:
                await context.bot.send_message(
                    int(chat_id),
                    f"Timeout ({TIMEOUT_SECONDS // 60} min) - Claude Code a ete interrompu.\n"
                    f"La tache etait trop longue. Essaie de decouper ta demande en etapes plus petites."
                )
            except Exception as e:
                await context.bot.send_message(
                    int(chat_id),
                    f"Erreur: {str(e)}"
                )
                log.error(f"Exception processing message: {traceback.format_exc()}")
    finally:
        is_processing = False
        processing_start_time = 0
        current_chat_id = None


async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.message.from_user.id
    if user_id not in ALLOWED_USERS:
        await update.message.reply_text("Acces refuse")
        return

    prompt = update.message.text
    chat_id = str(update.message.chat_id)

    save_context(chat_id, "Utilisateur", prompt)

    # Ajouter a la queue au lieu de rejeter
    position = len(message_queue) + 1
    message_queue.append((update, prompt, chat_id))

    if is_processing:
        elapsed = int(time.time() - processing_start_time)
        await update.message.reply_text(
            f"Message recu ! Position dans la file: #{position}.\n"
            f"Traitement en cours depuis {elapsed}s. Il sera traite des que Claude Code sera libre."
        )

    # Lancer le traitement de la queue (si pas deja en cours)
    asyncio.create_task(process_queue(context))


async def cmd_cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Annule le traitement en cours en tuant le subprocess Claude."""
    global current_process, is_processing

    if update.message.from_user.id not in ALLOWED_USERS:
        return

    if not is_processing or current_process is None:
        await update.message.reply_text("Rien en cours a annuler.")
        return

    try:
        elapsed = int(time.time() - processing_start_time)
        current_process.kill()
        current_process.wait(timeout=5)
        current_process = None
        # Vider la queue aussi
        cleared = len(message_queue)
        message_queue.clear()
        is_processing = False
        await update.message.reply_text(
            f"Annule ! (etait en cours depuis {elapsed}s)\n"
            f"File d'attente videe ({cleared} message(s) retires).\n"
            f"Claude Code est disponible."
        )
    except Exception as e:
        await update.message.reply_text(f"Erreur lors de l'annulation: {e}")


async def cmd_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.from_user.id not in ALLOWED_USERS:
        return

    # Utiliser asyncio.to_thread pour ne pas bloquer
    def _git_log():
        return subprocess.run(
            ["git", "log", "--oneline", "-5"],
            capture_output=True, text=True, cwd=PROJECT_DIR
        )

    result = await asyncio.to_thread(_git_log)

    queue_info = f"Messages en attente: {len(message_queue)}"
    if is_processing:
        elapsed = int(time.time() - processing_start_time)
        processing_info = f"Claude: en cours ({elapsed}s)"
    else:
        processing_info = "Claude: disponible"

    await update.message.reply_text(
        f"Derniers commits:\n{result.stdout}\n{processing_info}\n{queue_info}"
    )


async def cmd_reset(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global is_processing, current_process
    if update.message.from_user.id not in ALLOWED_USERS:
        return

    chat_id = str(update.message.chat_id)
    conversations[chat_id] = []
    message_queue.clear()

    # Tuer le process en cours si besoin
    if current_process:
        try:
            current_process.kill()
            current_process.wait(timeout=5)
        except Exception:
            pass
        current_process = None

    is_processing = False
    await update.message.reply_text("Conversation reset + file d'attente videe + verrou libere.")


async def cmd_revert(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.from_user.id not in ALLOWED_USERS:
        return

    def _git_revert():
        return subprocess.run(
            'git revert HEAD --no-edit && git push',
            shell=True, capture_output=True, text=True, cwd=PROJECT_DIR
        )

    result = await asyncio.to_thread(_git_revert)
    if result.returncode == 0:
        await update.message.reply_text("Dernier commit annule et pushe.")
    else:
        await update.message.reply_text(f"Erreur revert: {result.stderr}")


async def cmd_version(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.from_user.id not in ALLOWED_USERS:
        return
    try:
        pubspec_path = os.path.join(PROJECT_DIR, "pubspec.yaml")
        with open(pubspec_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("version:"):
                    await update.message.reply_text(f"{line.strip()}")
                    return
        await update.message.reply_text("Version non trouvee")
    except Exception as e:
        await update.message.reply_text(f"Erreur: {e}")


async def cmd_ping(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Repond instantanement meme si Claude est occupe."""
    status = "En cours de traitement" if is_processing else "Disponible"
    queue_size = len(message_queue)
    elapsed_info = ""
    if is_processing:
        elapsed = int(time.time() - processing_start_time)
        elapsed_info = f"\nEn cours depuis: {elapsed}s"
    await update.message.reply_text(
        f"Pong ! Bot actif\n"
        f"Statut: {status}{elapsed_info}\n"
        f"File d'attente: {queue_size} message(s)"
    )


async def cmd_queue(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Affiche la file d'attente."""
    if not message_queue:
        await update.message.reply_text("File d'attente vide. Claude est disponible.")
        return

    lines = []
    for i, (_, prompt, _) in enumerate(message_queue, 1):
        preview = prompt[:50] + "..." if len(prompt) > 50 else prompt
        lines.append(f"  #{i}: {preview}")

    await update.message.reply_text(
        f"File d'attente ({len(message_queue)} messages):\n" + "\n".join(lines)
    )


def main():
    app = Application.builder().token(TELEGRAM_TOKEN).job_queue(None).build()

    app.add_handler(CommandHandler("status", cmd_status))
    app.add_handler(CommandHandler("reset", cmd_reset))
    app.add_handler(CommandHandler("revert", cmd_revert))
    app.add_handler(CommandHandler("version", cmd_version))
    app.add_handler(CommandHandler("ping", cmd_ping))
    app.add_handler(CommandHandler("queue", cmd_queue))
    app.add_handler(CommandHandler("cancel", cmd_cancel))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    log.info("Bot Telegram -> Claude Code actif!")
    log.info(f"Projet: {PROJECT_DIR}")
    log.info(f"Timeout: {TIMEOUT_SECONDS}s ({TIMEOUT_SECONDS // 60} min)")
    log.info("Commandes: /status /reset /revert /version /ping /queue /cancel")

    app.run_polling(drop_pending_updates=True)


if __name__ == "__main__":
    while True:
        try:
            log.info(f"Demarrage du bot... ({time.strftime('%H:%M:%S')})")
            main()
        except KeyboardInterrupt:
            log.info("Bot arrete manuellement.")
            break
        except Exception as e:
            log.error(f"Bot crashe: {e}")
            log.error(traceback.format_exc())
            log.info("Redemarrage dans 5 secondes...")
            time.sleep(5)

"""
Backend Flask pour le chatbot épargne retraite avec RAG
Utilise ChromaDB pour la vectorisation et Ollama pour la génération
"""

import os
import glob
from flask import Flask, request, jsonify
from flask_cors import CORS
import chromadb
from chromadb.utils import embedding_functions
import requests

app = Flask(__name__)
CORS(app)

# Configuration
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "mistral")
KNOWLEDGE_BASE_PATH = os.getenv("KNOWLEDGE_BASE_PATH", "../knowledge_base")
CHROMA_PERSIST_PATH = os.getenv("CHROMA_PERSIST_PATH", "./chroma_db")

# System prompt strict pour le chatbot
SYSTEM_PROMPT = """Tu es un assistant virtuel spécialisé dans l'épargne retraite française.
Tu réponds uniquement aux questions concernant les Plans d'Épargne Retraite (PER), la fiscalité associée,
les trimestres de retraite, et les aspects réglementaires de l'épargne retraite en France.

DÉFINITIONS OBLIGATOIRES - Utilise TOUJOURS ces définitions exactes, ne jamais inventer d'autres significations :
- PERIN = PER Individuel (successeur du PERP et Madelin)
- PERO = PER Obligatoire (ex Article 83) - mis en place par l'entreprise avec adhésion obligatoire
- PERECO ou PERCOL = PER d'Entreprise Collectif (ex PERCO) - mis en place par l'entreprise avec adhésion facultative
- PERP = Plan d'Épargne Retraite Populaire (ancien produit fermé depuis 2020)
- Madelin = Contrat retraite pour Travailleurs Non-Salariés (ancien produit fermé depuis 2020)
- Rente = Versement périodique garanti à vie
- Capital = Versement en une seule fois de l'épargne accumulée
- Trimestres = Unité de mesure de la durée d'assurance pour la retraite de base

RÈGLES STRICTES À RESPECTER :

1. INTERDICTION ABSOLUE de donner des conseils de placement, d'allocation d'actifs, ou de recommander
   des fonds d'investissement spécifiques. Si on te demande dans quoi investir, où placer son argent,
   ou quel fonds choisir, tu dois refuser poliment et orienter vers un conseiller financier agréé.

2. INTERDICTION de collecter, stocker ou demander des données personnelles (numéro de sécurité sociale,
   coordonnées bancaires, adresse, etc.). Si l'utilisateur fournit spontanément des données personnelles,
   ignore-les et rappelle que tu ne peux pas traiter ces informations.

3. Tu fournis uniquement des informations générales et éducatives sur l'épargne retraite.
   Chaque situation étant unique, tu rappelles régulièrement que seul un conseiller peut
   donner un avis personnalisé.

4. Base tes réponses sur le contexte fourni. Si tu ne trouves pas l'information dans le contexte,
   dis-le clairement plutôt que d'inventer.

5. Réponds en français, de manière claire et structurée.

Contexte documentaire :
{context}

Question de l'utilisateur : {question}
"""

# Initialisation de ChromaDB avec embedding
embedding_function = embedding_functions.SentenceTransformerEmbeddingFunction(
    model_name="paraphrase-multilingual-MiniLM-L12-v2"
)

# Client ChromaDB persistant
chroma_client = chromadb.PersistentClient(path=CHROMA_PERSIST_PATH)

# Collection pour les documents
collection = None


def load_markdown_files():
    """Charge et découpe les fichiers markdown en chunks"""
    chunks = []
    metadatas = []
    ids = []

    # Chemin absolu vers la base de connaissances
    kb_path = os.path.abspath(os.path.join(os.path.dirname(__file__), KNOWLEDGE_BASE_PATH))

    # Chercher tous les fichiers markdown
    md_files = glob.glob(os.path.join(kb_path, "*.md"))

    chunk_id = 0
    for file_path in md_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        filename = os.path.basename(file_path)

        # Découper en sections basées sur les titres
        sections = content.split('\n## ')

        for i, section in enumerate(sections):
            if i == 0:
                # Première section (peut contenir le titre principal)
                section_text = section
            else:
                section_text = '## ' + section

            # Découper les sections longues en chunks plus petits
            if len(section_text) > 1500:
                # Découper par paragraphes
                paragraphs = section_text.split('\n\n')
                current_chunk = ""

                for para in paragraphs:
                    if len(current_chunk) + len(para) < 1500:
                        current_chunk += para + "\n\n"
                    else:
                        if current_chunk.strip():
                            chunks.append(current_chunk.strip())
                            metadatas.append({"source": filename, "chunk": chunk_id})
                            ids.append(f"chunk_{chunk_id}")
                            chunk_id += 1
                        current_chunk = para + "\n\n"

                if current_chunk.strip():
                    chunks.append(current_chunk.strip())
                    metadatas.append({"source": filename, "chunk": chunk_id})
                    ids.append(f"chunk_{chunk_id}")
                    chunk_id += 1
            else:
                if section_text.strip():
                    chunks.append(section_text.strip())
                    metadatas.append({"source": filename, "chunk": chunk_id})
                    ids.append(f"chunk_{chunk_id}")
                    chunk_id += 1

    return chunks, metadatas, ids


def init_vector_db():
    """Initialise ou charge la base vectorielle"""
    global collection

    # Essayer de récupérer la collection existante
    try:
        collection = chroma_client.get_collection(
            name="epargne_retraite",
            embedding_function=embedding_function
        )
        print(f"Collection existante chargée avec {collection.count()} documents")
    except:
        # Créer une nouvelle collection
        collection = chroma_client.create_collection(
            name="epargne_retraite",
            embedding_function=embedding_function
        )

        # Charger les documents
        chunks, metadatas, ids = load_markdown_files()

        if chunks:
            # Ajouter par lots de 100
            batch_size = 100
            for i in range(0, len(chunks), batch_size):
                batch_chunks = chunks[i:i+batch_size]
                batch_metadatas = metadatas[i:i+batch_size]
                batch_ids = ids[i:i+batch_size]

                collection.add(
                    documents=batch_chunks,
                    metadatas=batch_metadatas,
                    ids=batch_ids
                )

            print(f"Nouvelle collection créée avec {len(chunks)} chunks")
        else:
            print("Aucun document trouvé dans la base de connaissances")


def search_relevant_chunks(query: str, n_results: int = 5) -> str:
    """Recherche les chunks les plus pertinents pour une requête"""
    if collection is None:
        return ""

    results = collection.query(
        query_texts=[query],
        n_results=n_results
    )

    if results and results['documents'] and results['documents'][0]:
        # Combiner les chunks pertinents
        context = "\n\n---\n\n".join(results['documents'][0])
        return context

    return ""


def query_ollama(prompt: str) -> str:
    """Envoie une requête à Ollama et récupère la réponse"""
    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "num_predict": 1024
                }
            },
            timeout=120
        )

        if response.status_code == 200:
            return response.json().get("response", "Désolé, je n'ai pas pu générer de réponse.")
        else:
            return f"Erreur de communication avec le modèle de langage (code {response.status_code})."

    except requests.exceptions.ConnectionError:
        return "Le service de génération de texte n'est pas disponible. Veuillez réessayer plus tard."
    except requests.exceptions.Timeout:
        return "La requête a pris trop de temps. Veuillez réessayer avec une question plus simple."
    except Exception as e:
        return f"Une erreur inattendue s'est produite : {str(e)}"


@app.route('/health', methods=['GET'])
def health_check():
    """Endpoint de vérification de l'état du service"""
    return jsonify({
        "status": "healthy",
        "ollama_url": OLLAMA_URL,
        "model": OLLAMA_MODEL,
        "documents_count": collection.count() if collection else 0
    })


@app.route('/chat', methods=['POST'])
def chat():
    """Endpoint principal du chatbot"""
    try:
        data = request.get_json()

        if not data or 'message' not in data:
            return jsonify({
                "error": "Le champ 'message' est requis"
            }), 400

        user_message = data['message'].strip()

        if not user_message:
            return jsonify({
                "error": "Le message ne peut pas être vide"
            }), 400

        # Limiter la longueur du message
        if len(user_message) > 1000:
            return jsonify({
                "error": "Le message est trop long (maximum 1000 caractères)"
            }), 400

        # Rechercher le contexte pertinent
        context = search_relevant_chunks(user_message)

        if not context:
            context = "Aucun contexte spécifique trouvé. Réponds de manière générale sur l'épargne retraite."

        # Construire le prompt complet
        full_prompt = SYSTEM_PROMPT.format(
            context=context,
            question=user_message
        )

        # Interroger Ollama
        response = query_ollama(full_prompt)

        return jsonify({
            "response": response,
            "sources": list(set([
                r.get('source', 'inconnu')
                for r in (collection.query(query_texts=[user_message], n_results=3)['metadatas'][0] or [])
            ])) if collection else []
        })

    except Exception as e:
        return jsonify({
            "error": f"Erreur interne du serveur : {str(e)}"
        }), 500


@app.route('/reload', methods=['POST'])
def reload_knowledge_base():
    """Recharge la base de connaissances"""
    global collection

    try:
        # Supprimer l'ancienne collection
        try:
            chroma_client.delete_collection("epargne_retraite")
        except:
            pass

        # Recréer la collection
        collection = chroma_client.create_collection(
            name="epargne_retraite",
            embedding_function=embedding_function
        )

        # Charger les documents
        chunks, metadatas, ids = load_markdown_files()

        if chunks:
            batch_size = 100
            for i in range(0, len(chunks), batch_size):
                batch_chunks = chunks[i:i+batch_size]
                batch_metadatas = metadatas[i:i+batch_size]
                batch_ids = ids[i:i+batch_size]

                collection.add(
                    documents=batch_chunks,
                    metadatas=batch_metadatas,
                    ids=batch_ids
                )

        return jsonify({
            "status": "success",
            "documents_count": len(chunks)
        })

    except Exception as e:
        return jsonify({
            "error": f"Erreur lors du rechargement : {str(e)}"
        }), 500


# Initialiser la base vectorielle au démarrage
with app.app_context():
    init_vector_db()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5008, debug=True)

FROM python:3.12-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY pyproject.toml ./

# Installer uv
RUN pip install --no-cache-dir uv

# Installer les dépendances
RUN uv pip install --system --no-cache -r pyproject.toml

# Copier le code de l'application
COPY app.py ./

# Exposer le port Streamlit
EXPOSE 8501

# Variable d'environnement pour Streamlit
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0
ENV STREAMLIT_SERVER_HEADLESS=true

# Commande de démarrage
CMD ["streamlit", "run", "app.py"]
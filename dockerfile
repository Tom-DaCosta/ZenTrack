# Utiliser l'image de base officielle d'Alpine pour réduire la taille de l'image
FROM nginx:alpine

# Définir le répertoire de travail
WORKDIR /usr/share/nginx/html

# Copier un fichier HTML dans le conteneur
COPY index.html .

# Exposer le port 80 pour permettre l'accès au serveur web
EXPOSE 80

# Commande de démarrage par défaut pour Nginx
CMD ["nginx", "-g", "daemon off;"]

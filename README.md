# Backend du Site de Commerce en Ligne - Lycée Henri Wallon

Bienvenue dans le dossier du backend du site de commerce en ligne du Lycée Henri Wallon. Cette section regroupe les fichiers essentiels nécessaires au bon fonctionnement du serveur.

## INSTALLATION:
- TOUTES LES COMMANDES SONT A EXECUTER SOUT L'UTILISATEUR ROOT POUR QUE LA COMMANDE `kill` PUISSE FONCTIONNER CORRECTEMENT

- Exécuter la commande `./install.sh` sur Linux pour commencer l'installation.

- MODIFIER LE CONTENU DU FICHIER `./server/.env` EN Y METTANT TOUTES LES INFORMATIONS NECESSAIRES.

- Ensuite exécuter la commande `./start.sh` sur Linux pour allumer le serveur.

## Contenu du Dossier `src`:

1. **`server.js`**: Fichier exécutable conçu pour Bun. Pour le lancer, veuillez utiliser la commande `bun run server.js` sur Bun.

3. **`.env`**: Fichier contenant toutes les variables secrètes et la configuration du serveur. Assurez-vous de ne pas partager ces informations sensibles.

## Configuration par Défaut:

- Le serveur est accessible par défaut à l'adresse `localhost:3000`. Cependant, le port peut être modifié via les variables secrètes d'exécution.
- La modification manuelle des permissions des utilisateurs ADMIN dans la base de données est nécessaire. Les trois rôles possibles sont `ADMIN`, `EMPLOYEE`, et `REGULAR`. Par défaut, un compte avec les permissions `ADMIN` est créé:
    - Username : `admin`
    - Password : `adminpassword`
    - Email : `admin@admin.com`
    - Role : `ADMIN`
- Les tokens d'accès aux comptes se suppriment par défaut au bout de 7 jours après leur création (pourvu que le serveur soit allumé). Pour modifier ce temps, il faut modifier le fichier `.env`.
- Les tokens JWT sont configurés grâce à une chaîne de caractères secrète. Plus elle est longue et aléatoire, mieux c'est. Elle ne peut contenir que des lettres et des chiffres.

## Accès à l'Interface Utilisateur:

- Le fichier `index.html` peut être consulté en l'ouvrant directement ou en accédant à l'URL `localhost:PORT/endpoints`. Il présente une liste de tous les endpoints actuellement implémentés, signalant ceux en rouge comme non encore implémentés.

## Fonctionnalités Principales:

Le serveur gère diverses fonctionnalités pour le site de commerce en ligne du Lycée Henri Wallon, notamment:

- Gestion des produits
- Gestion des utilisateurs
- Gestion des paniers
- Gestion des commandes
- Gestion des avis

## Prérequis:

- Ce serveur peut être exécuté sur Windows avec le sous-système Windows pour Linux (WSL) avec Bun installé : [Bun](https://bun.sh/).

- Une configuration du serveur PostgreSQL est nécessaire dans le fichier `.env`. Les champs à remplir sont les premiers, et un exemple pré-configuré est déjà présent.
## Conseils:
- Pour avoir Linux sur son ordinateur Windows, vous pouvez soit installer une machine virtuelle soit configurer WSL. Dans les dernières versions de Windows 10 et 11, il suffit d'entrer la commande `wsl install` dans le cmd.

C'est tout! Vous êtes prêt à utiliser le backend du site de l'ATW Wallon.
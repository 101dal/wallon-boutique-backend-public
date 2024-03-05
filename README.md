""""
# Backend pour le site d'achat en ligne - Lycée Henri Wallon

Bienvenue dans le répertoire backend du site d'achat en ligne du Lycée Henri Wallon. Cette section contient les fichiers essentiels nécessaires au bon fonctionnement du serveur.

## INSTALLATION :
- Téléchargez le fichier `INSTALLER.tar.gz` et extrayez-le dans le dossier cible sur votre serveur.

- Pour une installation en douceur, exécutez `./MAIN.sh` et suivez les instructions. Sinon, suivez les étapes ci-dessous.

- Exécutez la commande `./install.sh` sur Linux pour commencer l'installation.

- MODIFIEZ LE CONTENU DU FICHIER `./server/.env` EN AJOUTANT TOUTES LES INFORMATIONS NÉCESSAIRES.

- Ensuite, exécutez la commande `./start.sh` sur Linux pour démarrer le serveur.

## Contenu du dossier `src` :

1. **`server.js`** : Fichier exécutable conçu pour Bun. Pour l'exécuter individuellement, veuillez utiliser la commande `bun run server.js` sur Bun.

3. **`.env`** : Fichier contenant toutes les variables secrètes et la configuration du serveur. Veillez à ne pas partager ces informations sensibles.

## Configuration par défaut :

- Le serveur est accessible par défaut à l'adresse `localhost:3000`. Cependant, le port peut être modifié via les variables d'exécution secrètes.
- La modification manuelle des autorisations utilisateur dans la base de données est nécessaire. Les trois rôles possibles sont `ADMIN`, `EMPLOYEE`, et `REGULAR`. Par défaut, un compte avec des autorisations `ADMIN` est créé :
    - Nom d'utilisateur : `admin`
    - Mot de passe : `adminpassword`
    - Email : `admin@example.com`
    - Rôle : `ADMIN`
- Les jetons d'accès aux comptes sont supprimés par défaut après 7 jours à compter de leur création (à condition que le serveur soit allumé). Pour modifier ce délai, vous devez modifier le fichier `.env`.
- Les jetons JWT sont configurés à l'aide d'une chaîne secrète de caractères. Plus elle est longue et aléatoire, mieux c'est. Elle ne peut contenir que des lettres et des chiffres.

## Accès à l'interface utilisateur :

- Le fichier `index.html` peut être visualisé en l'ouvrant directement ou en accédant à l'URL `localhost:PORT/endpoints`. Il présente une liste de tous les points de terminaison actuellement mis en œuvre, marquant ceux en rouge comme non encore mis en œuvre.

## Principales fonctionnalités :

Le serveur gère diverses fonctionnalités pour le site d'achat en ligne du Lycée Henri Wallon, notamment :

- Gestion des produits
  - Obtenir tous les produits
  - Obtenir un produit par ID
  - Rechercher des produits
  - Créer un produit (Admin)
  - Mettre à jour un produit (Admin)
  - Mettre à jour l'inventaire d'un produit (Admin)
  - Supprimer un produit (Admin)

- Gestion des utilisateurs
  - Inscrire un utilisateur
  - Vérifier l'email
  - Réinitialiser le mot de passe
  - Vérifier la réinitialisation du mot de passe
  - Se connecter
  - Se déconnecter
  - Supprimer un compte
  - Obtenir les informations de l'utilisateur
  - Mettre à jour un utilisateur
  - Obtenir les informations de tous les utilisateurs (Admin)
  - Obtenir les informations d'un utilisateur par ID (Admin)
  - Mettre à jour un utilisateur par ID (Admin)
  - Créer un utilisateur (Admin)
  - Supprimer un utilisateur (Admin)
  - Rechercher des utilisateurs (Admin)
  - Mettre à jour le rôle d'un utilisateur (Admin)

- Gestion du panier
  - Ajouter au panier
  - Obtenir le panier
  - Supprimer du panier
  - Passer la commande
  - Obtenir tous les paniers (Employee)
  - Obtenir le panier par ID utilisateur (Employee)
  - Modifier le panier (Admin)
  - Supprimer le panier (Admin)
  - Supprimer les paniers par ID utilisateur (Admin)
  - Rechercher des paniers (Admin)

- Gestion des commandes
  - Obtenir l'historique des commandes
  - Obtenir toutes les commandes (Employee)
  - Mettre à jour le statut d'une commande (Employee)
  - Obtenir une commande par ID (Employee)
  - Obtenir les commandes par ID utilisateur (Admin)
  - Supprimer une commande (Admin)
  - Mettre à jour une commande (Admin)
  - Créer une commande pour un utilisateur (Admin)

- Gestion des avis
  - Obtenir les avis par ID produit
  - Obtenir les avis par ID utilisateur
  - Créer un avis
  - Mettre à jour un avis
  - Supprimer un avis
  - Créer un avis personnalisé (Admin)
  - Mettre à jour un avis personnalisé (Admin)
  - Supprimer un avis personnalisé (Admin)
  - Rechercher des avis (Admin)

- Gestion du support
  - Créer un message de support
  - Obtenir tous les messages de support (Admin)
  - Supprimer un message de support (Admin)

- Gestion des jetons
  - Obtenir les jetons par ID utilisateur
  - Obtenir tous les jetons (Admin)
  - Révoquer un jeton (Admin)

Un système complet de logging est aussi en place dans le dossier `logs` avec une organisation très hiérarchisée pour permettre une meilleure gestion du serveur.

## Prérequis :

- Ce serveur peut être exécuté sur Windows avec le sous-système Windows pour Linux (WSL) avec Bun installé : [Bun](https://bun.sh/).

- Une configuration de serveur PostgreSQL est requise dans le fichier `.env`. Les champs à remplir sont les premiers, et un exemple préconfiguré est déjà présent.

## Astuces :
- Pour avoir Linux sur votre ordinateur Windows, vous pouvez soit installer une machine virtuelle, soit configurer WSL. Dans les dernières versions de Windows 10 et 11, il suffit d'entrer la commande `wsl install` dans le cmd.

C'est tout ! Vous êtes prêt à utiliser le backend du site web ATW Wallon
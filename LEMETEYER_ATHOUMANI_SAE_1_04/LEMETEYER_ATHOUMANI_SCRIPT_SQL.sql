-- Voici notre BDD d'un site d'hebergement conçu sur le modèle de Youtube

-- Initialisation de la base

-- Suppression des tables si elles existent déjà
DROP TABLE UTILISATEUR CASCADE CONSTRAINTS;
DROP TABLE CATEGORIE CASCADE CONSTRAINTS;
DROP TABLE VIDEO CASCADE CONSTRAINTS;
DROP TABLE TAGS CASCADE CONSTRAINTS;
DROP TABLE PLAYLIST CASCADE CONSTRAINTS;
DROP TABLE PUBLICITE CASCADE CONSTRAINTS;
DROP TABLE COMMENTAIRE CASCADE CONSTRAINTS;
DROP TABLE EVALUATION CASCADE CONSTRAINTS;
DROP TABLE NOTIFICATION CASCADE CONSTRAINTS;
DROP TABLE SIGNALEMENT CASCADE CONSTRAINTS;
DROP TABLE ACTIVITE_UTILISATEUR CASCADE CONSTRAINTS;
DROP TABLE HISTORIQUE_VIDEO CASCADE CONSTRAINTS;
DROP TABLE PUBLICITE_CIBLEE CASCADE CONSTRAINTS;
DROP TABLE VIDEO_TAGS CASCADE CONSTRAINTS;
DROP TABLE PLAYLIST_VIDEO CASCADE CONSTRAINTS;
DROP TABLE ABONNEMENT CASCADE CONSTRAINTS;
DROP TABLE ANALYTIQUE CASCADE CONSTRAINTS;
DROP TABLE MUSIQUE CASCADE CONSTRAINTS;
DROP TABLE RECOMMANDATION CASCADE CONSTRAINTS;
DROP TABLE TAGS_SHORT CASCADE CONSTRAINTS;
DROP TABLE SHORT CASCADE CONSTRAINTS;
DROP TABLE UTILISATEUR_PARAMETRE CASCADE CONSTRAINTS;


-- Création des tables

-- Table Utilisateur
CREATE TABLE utilisateur(
    login VARCHAR2(30) PRIMARY KEY,
    nom VARCHAR2(30) NOT NULL,
    prenom VARCHAR2(30) NOT NULL,
    email VARCHAR2(50) NOT NULL CHECK (email LIKE '_%@_%._%'),
    mot_de_passe VARCHAR2(20) NOT NULL,
    date_creation_compte TIMESTAMP DEFAULT SYSDATE,
    date_naissance DATE NOT NULL,
    photo_profil BLOB,
    statut VARCHAR2(10) DEFAULT 'actif' CHECK (statut IN ('actif', 'désactivé', 'suspendu')),
    role_utilisateur VARCHAR2(20) DEFAULT 'utilisateur' CHECK (role_utilisateur IN ('utilisateur', 'modérateur', 'administrateur')),
    derniere_connexion TIMESTAMP
);

-- Création de la table utilisateur_parametre
CREATE TABLE utilisateur_parametre (
    id_parametre NUMBER(6) PRIMARY KEY,  -- Identifiant unique pour chaque paramètre
    login_utilisateur VARCHAR2(30) NOT NULL, -- Référence à l'utilisateur
    theme_interface VARCHAR2(20) DEFAULT 'clair' CHECK (theme_interface IN ('clair', 'sombre')), -- Préférence de thème
    langue_preferee VARCHAR2(15) DEFAULT 'français', -- Langue préférée
    notifications NUMBER(1) DEFAULT 1, -- Paramètre pour activer/désactiver les notifications (1 = TRUE, 0 = FALSE)
    confidentialité_profil VARCHAR2(15) DEFAULT 'public' CHECK (confidentialité_profil IN ('public', 'privé', 'amis')), -- Niveau de confidentialité du profil
    date_derniere_modification TIMESTAMP DEFAULT SYSDATE -- Date de la dernière modification des paramètres
);

-- Ajouter une clé étrangère vers la table utilisateur
ALTER TABLE utilisateur_parametre
ADD CONSTRAINT fk_parametre_utilisateur FOREIGN KEY (login_utilisateur) REFERENCES utilisateur(login);


-- Table Categorie
CREATE TABLE categorie(
    id_cat NUMBER(6) PRIMARY KEY,
    nom_cat VARCHAR2(15) NOT NULL,
    description VARCHAR2(100),
    id_cat_pere NUMBER(6) -- Lien vers une catégorie parent
);

-- Ajout de la clé étrangère pour id_cat_pere après création
ALTER TABLE categorie
ADD CONSTRAINT fk_categorie_parent FOREIGN KEY (id_cat_pere) REFERENCES categorie(id_cat);

CREATE TABLE Abonnement(
    idAbo NUMBER(12) PRIMARY KEY,
    ChaineAbonnement VARCHAR(30) REFERENCES utilisateur(Login), -- Ici l'on parle de l'utilisateur auquel on s'abonne
    Abonne VARCHAR(30) REFERENCES utilisateur(Login), -- Ici l'on parle de la personne qui s'abonne
    DateAbo TIMESTAMP DEFAULT SYSDATE,
    Statut VARCHAR(10) CHECK(Statut = 'actif' OR Statut = 'annulé'),
    TypeAbo VARCHAR(10) DEFAULT 'gratuit' CHECK(TypeAbo = 'gratuit' OR TypeAbo = 'premium')
);

-- Table Video
CREATE TABLE video(
    id_video NUMBER(6) PRIMARY KEY,
    titre VARCHAR2(30) NOT NULL,
    description VARCHAR2(200) DEFAULT NULL,
    acces_fichier VARCHAR2(40) NOT NULL CHECK (acces_fichier LIKE '_%._%'),
    date_publication TIMESTAMP DEFAULT SYSDATE,
    duree VARCHAR2(8) CHECK (duree LIKE '__:__:__'),
    nombre_vues NUMBER(11) DEFAULT 0,
    statut VARCHAR2(20) DEFAULT 'public' CHECK (statut IN ('public', 'privé', 'non repertorié')),
    proprietaire VARCHAR2(30) NOT NULL,
    id_categorie NUMBER(6),
    etat VARCHAR2(20) DEFAULT 'en attente' CHECK (etat IN ('publiée', 'en attente', 'supprimée')),
    date_derniere_modif TIMESTAMP DEFAULT SYSDATE,
    langue VARCHAR2(15) DEFAULT 'français',
    restriction_age NUMBER(1) DEFAULT 0 -- 0 pour FALSE, 1 pour TRUE
);

-- Ajout des clés étrangères pour Video
ALTER TABLE video
ADD CONSTRAINT fk_video_utilisateur FOREIGN KEY (proprietaire) REFERENCES utilisateur(login);

ALTER TABLE video
ADD CONSTRAINT fk_video_categorie FOREIGN KEY (id_categorie) REFERENCES categorie(id_cat);

-- Table Tags
CREATE TABLE tags(
    id_tag NUMBER(6) PRIMARY KEY,
    nom_tag VARCHAR2(30) NOT NULL
);

-- Table Video_Tags
CREATE TABLE video_tags(
    id_video NUMBER(6),
    id_tag NUMBER(6),
    PRIMARY KEY (id_video, id_tag)
);

ALTER TABLE video_tags
ADD CONSTRAINT fk_video_tags_video FOREIGN KEY (id_video) REFERENCES video(id_video);

ALTER TABLE video_tags
ADD CONSTRAINT fk_video_tags_tag FOREIGN KEY (id_tag) REFERENCES tags(id_tag);

-- Table Playlist
CREATE TABLE playlist(
    id_playlist NUMBER(6) PRIMARY KEY,
    nom_playlist VARCHAR2(50) NOT NULL,
    description VARCHAR2(200),
    proprietaire VARCHAR2(30) NOT NULL,
    statut VARCHAR2(10) DEFAULT 'public' CHECK (statut IN ('public', 'privé'))
);

ALTER TABLE playlist
ADD CONSTRAINT fk_playlist_utilisateur FOREIGN KEY (proprietaire) REFERENCES utilisateur(login);

-- Table Playlist_Video
CREATE TABLE playlist_video(
    id_playlist NUMBER(6),
    id_video NUMBER(6),
    PRIMARY KEY (id_playlist, id_video)
);

ALTER TABLE playlist_video
ADD CONSTRAINT fk_playlist_video_playlist FOREIGN KEY (id_playlist) REFERENCES playlist(id_playlist);

ALTER TABLE playlist_video
ADD CONSTRAINT fk_playlist_video_video FOREIGN KEY (id_video) REFERENCES video(id_video);

-- Table Publicité
CREATE TABLE publicite(
    id_pub NUMBER(6) PRIMARY KEY,
    contenu VARCHAR2(200) NOT NULL,
    cible_age NUMBER(1) DEFAULT 0, -- 0 pour "aucune restriction", 1 pour "restriction"
    duree VARCHAR2(8) CHECK (duree LIKE '__:__:__')
);

-- Table Publicité_Ciblée
CREATE TABLE publicite_ciblee(
    id_pub NUMBER(6),
    id_video NUMBER(6),
    id_tag NUMBER(6),
    PRIMARY KEY (id_pub, id_video, id_tag)
);

ALTER TABLE publicite_ciblee
ADD CONSTRAINT fk_pubciblee_pub FOREIGN KEY (id_pub) REFERENCES publicite(id_pub);

ALTER TABLE publicite_ciblee
ADD CONSTRAINT fk_pubciblee_video FOREIGN KEY (id_video) REFERENCES video(id_video);

ALTER TABLE publicite_ciblee
ADD CONSTRAINT fk_pubciblee_tag FOREIGN KEY (id_tag) REFERENCES tags(id_tag);

-- Table Commentaire
CREATE TABLE commentaire(
    id_commentaire NUMBER(6) PRIMARY KEY,
    contenu_commentaire VARCHAR2(500) NOT NULL,
    date_commentaire TIMESTAMP DEFAULT SYSDATE,
    auteur VARCHAR2(30) NOT NULL,
    id_video NUMBER(6) NOT NULL
);

ALTER TABLE commentaire
ADD CONSTRAINT fk_commentaire_utilisateur FOREIGN KEY (auteur) REFERENCES utilisateur(login);

ALTER TABLE commentaire
ADD CONSTRAINT fk_commentaire_video FOREIGN KEY (id_video) REFERENCES video(id_video);

-- Table Evaluation
CREATE TABLE evaluation(
    id_evaluation NUMBER(6) PRIMARY KEY,
    type_evaluation VARCHAR2(10) NOT NULL CHECK (type_evaluation IN ('like', 'dislike')),
    date_evaluation TIMESTAMP DEFAULT SYSDATE,
    auteur VARCHAR2(30) NOT NULL,
    id_video NUMBER(6) NOT NULL
);

ALTER TABLE evaluation
ADD CONSTRAINT fk_evaluation_utilisateur FOREIGN KEY (auteur) REFERENCES utilisateur(login);

ALTER TABLE evaluation
ADD CONSTRAINT fk_evaluation_video FOREIGN KEY (id_video) REFERENCES video(id_video);

-- Table Notification
CREATE TABLE notification(
    id_notification NUMBER(6) PRIMARY KEY,
    contenu_notification VARCHAR2(200) NOT NULL,
    date_notification TIMESTAMP DEFAULT SYSDATE,
    destinataire VARCHAR2(30) NOT NULL,
    statut_notification VARCHAR2(10) DEFAULT 'non lu' CHECK (statut_notification IN ('non lu', 'lu'))
);

ALTER TABLE notification
ADD CONSTRAINT fk_notification_utilisateur FOREIGN KEY (destinataire) REFERENCES utilisateur(login);

-- Table Historique_Video
CREATE TABLE historique_video(
    id_historique NUMBER(6) PRIMARY KEY,
    login_utilisateur VARCHAR2(30) NOT NULL,
    id_video NUMBER(6) NOT NULL,
    date_visionnage TIMESTAMP DEFAULT SYSDATE
);

ALTER TABLE historique_video
ADD CONSTRAINT fk_historique_video_utilisateur FOREIGN KEY (login_utilisateur) REFERENCES utilisateur(login);

ALTER TABLE historique_video
ADD CONSTRAINT fk_historique_video_video FOREIGN KEY (id_video) REFERENCES video(id_video);

-- Table Signalement
CREATE TABLE signalement(
    id_signalement NUMBER(6) PRIMARY KEY,
    type_signalement VARCHAR2(20) NOT NULL,
    description_signalement VARCHAR2(200),
    date_signalement TIMESTAMP DEFAULT SYSDATE,
    id_video NUMBER(6),
    login_utilisateur VARCHAR2(30)
);

ALTER TABLE signalement
ADD CONSTRAINT fk_signalement_video FOREIGN KEY (id_video) REFERENCES video(id_video);

ALTER TABLE signalement
ADD CONSTRAINT fk_signalement_utilisateur FOREIGN KEY (login_utilisateur) REFERENCES utilisateur(login);

-- Table Activite_Utilisateur
CREATE TABLE activite_utilisateur(
    id_activite NUMBER(6) PRIMARY KEY,
    type_activite VARCHAR2(20) NOT NULL,
    description_activite VARCHAR2(200),
    date_activite TIMESTAMP DEFAULT SYSDATE,
    login_utilisateur VARCHAR2(30) NOT NULL
);

ALTER TABLE activite_utilisateur
ADD CONSTRAINT fk_activite_utilisateur FOREIGN KEY (login_utilisateur) REFERENCES utilisateur(login);

-- Table Analytique
CREATE TABLE analytique(
    id_analytique NUMBER(6) PRIMARY KEY,
    id_video NUMBER(6) NOT NULL,
    nombre_vues NUMBER(11) DEFAULT 0,
    nombre_likes NUMBER(11) DEFAULT 0,
    nombre_dislikes NUMBER(11) DEFAULT 0,
    duree_moyenne_visionnage VARCHAR2(8) DEFAULT '00:00:00'
   
);

ALTER TABLE analytique
ADD CONSTRAINT fk_analytique_video FOREIGN KEY (id_video) REFERENCES video(id_video);

-- Table Musique
CREATE TABLE musique(
    id_musique NUMBER(6) PRIMARY KEY,
    titre_musique VARCHAR2(50) NOT NULL,
    artiste VARCHAR2(50) NOT NULL,
    genre VARCHAR2(30),
    lien_fichier VARCHAR2(100) NOT NULL
);

-- Table Recommandation
CREATE TABLE recommandation(
    id_recommandation NUMBER(6) PRIMARY KEY,
    login_utilisateur VARCHAR2(30) NOT NULL,
    id_video NUMBER(6) NOT NULL,
    type_recommandation VARCHAR2(20) NOT NULL CHECK (type_recommandation IN ('historique', 'abonnement', 'profil'))
  
);

ALTER TABLE recommandation
ADD CONSTRAINT fk_recommandation_video FOREIGN KEY (id_video) REFERENCES video(id_video);

ALTER TABLE recommandation
ADD CONSTRAINT fk_recommandation_utilisateur FOREIGN KEY (login_utilisateur) REFERENCES utilisateur(login);


-- Table Tags_Short
CREATE TABLE tags_short(
    id_tag_short NUMBER(6) PRIMARY KEY,
    nom_tag_short VARCHAR2(30) NOT NULL
);

-- Table Short
CREATE TABLE short(
    id_short NUMBER(6) PRIMARY KEY,
    titre VARCHAR2(50) NOT NULL,
    description VARCHAR2(200),
    acces_fichier VARCHAR2(40) NOT NULL CHECK (acces_fichier LIKE '_%._%'),
    date_publication TIMESTAMP DEFAULT SYSDATE,
    duree VARCHAR2(8) NOT NULL CHECK (duree LIKE '__:__:__'),
    nombre_vues NUMBER(11) DEFAULT 0,
    proprietaire_short VARCHAR2(30) NOT NULL,
    langue VARCHAR2(15) DEFAULT 'francais',
    id_tag_short NUMBER(6)
   
);

ALTER TABLE short
ADD CONSTRAINT fk_short_utilisateur FOREIGN KEY (proprietaire_short) REFERENCES utilisateur(login);

ALTER TABLE short
ADD CONSTRAINT fk_short_tags FOREIGN KEY (id_tag_short) REFERENCES tags_short(id_tag_short);

-- PARTIE CONFIDENTIALITE

-- Ici l'utilisateur dénommé "loyer" est un administrateur, "athoumani" est un modérateur, "lemeteyer" est un utilisateur simple

-- On crée une vue pour restreindre l'accès aux données sensibles des utilisateurs
CREATE VIEW utilisateur_public AS
SELECT 
    login,
    nom,
    prenom,
    statut,
    role_utilisateur,
    date_creation_compte
FROM utilisateur;

GRANT SELECT ON utilisateur_public TO PUBLIC; -- Tout le monde pourra voir un pannel restreint d'informations sur d'autres utilisateurs

CREATE VIEW utilisateur_mod AS
SELECT 
    login,
    nom,
    prenom,
    statut,
    role_utilisateur,
    email, -- Les modérateurs peuvent voir l'email
    date_creation_compte
FROM utilisateur;

-- Permissions pour les rôles
-- L'administrateur peut tout faire, on lui donne tout les privilèges.
GRANT SELECT, INSERT, UPDATE, DELETE ON utilisateur TO loyer;

-- Les modérateurs ont accès aux attributs figurants dans utilisateur_mod.
GRANT SELECT ON utilisateur_mod TO athoumani;

-- Les utilisateurs classiques ont un accès limités à leurs propres informations.
CREATE VIEW utilisateur_own AS
SELECT 
    login,
    nom,
    prenom,
    email,
    date_naissance,
    photo_profil,
    statut
FROM utilisateur
WHERE login = USER; -- Filtrage des données pour n'afficher que celles de l'utilisateur connecté

GRANT SELECT, UPDATE(login, nom, prenom, email, photo_profil) ON utilisateur_own TO lemeteyer; -- lemeteyer peut voir et modifier toutes les informations sur lui.




-- Vue publique (exclut les vidéos privées et non répertoriées)
CREATE VIEW video_public AS
SELECT 
    id_video,
    titre,
    description,
    date_publication,
    nombre_vues,
    proprietaire
FROM video
WHERE statut = 'public';

-- Permissions pour les vidéos publiques
GRANT SELECT ON video_public TO lemeteyer, athoumani;

-- Permissions administratives sur toutes les vidéos
GRANT SELECT, INSERT, UPDATE, DELETE ON video TO loyer;
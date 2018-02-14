## Answer

# 1
createdb bd_l3info005

# 2
CREATE SCHEMA u_l3info005;
CREATE SCHEMA TP1_jeu;

# 3
SET search_path TO TP1_jeu,u_l3info005;

# 4
DROP SCHEMA public;

# 5
DROP TABLE IF EXISTS jeu;
DROP TABLE IF EXISTS partie;
DROP TABLE IF EXISTS save;
#On precise le format pour la date
SET datestyle = dmy;


CREATE TABLE jeu (
	id_jeu serial PRIMARY KEY,
	nom_jeu varchar(20) NOT NULL,
	type varchar(20) NOT NULL,
	nb_joueur integer,
	CONSTRAINT chk_nom CHECK (type IN ('role', 'plateau', 'tower defense', 'MMORPG','Autre'))
);

CREATE TABLE partie (
	id_avatar bigint REFERENCES avatar (id_avatar),
	id_jeu bigint REFERENCES jeu (id_jeu),
	role varchar(20) NOT NULL,
	highscore integer NOT NULL,
	PRIMARY KEY (id_avatar, id_jeu)
);

CREATE TABLE save (
	id_avatar bigint REFERENCES avatar (id_avatar),
	id_jeu bigint REFERENCES jeu (id_jeu),
	date_s date NOT NULL,
	nb_pv integer NOT NULL,
	fichier varchar(50) UNIQUE NOT NULL,
	PRIMARY KEY (id_avatar, id_jeu, date_s)
);

# 6

CREATE TABLE visiteur (
	id_visiteur serial PRIMARY KEY,
	login varchar(10) NOT NULL,
	mdp varchar(10) NOT NULL,
	mail varchar(50),
	ville varchar(50),
	CONSTRAINT check_mail CHECK ( mail ~* '^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

# 7
CREATE TABLE ville (
	id_ville serial PRIMARY KEY,
	nom_ville varchar(50) NOT NULL,
	code_postal integer
);

# 8
INSERT INTO ville VALUES (DEFAULT, 'Aix en Provence', 13100);
INSERT INTO ville VALUES (DEFAULT, 'Brette les Pins', 72250);
INSERT INTO ville VALUES (DEFAULT, 'Foix',09000);
INSERT INTO ville VALUES (DEFAULT, 'Nancy',54000);
INSERT INTO ville VALUES (DEFAULT, 'Dunkerque',59640);
INSERT INTO ville VALUES (DEFAULT, 'Grenoble',38000);
INSERT INTO ville VALUES (DEFAULT, 'Annecy',74000);

#10
CREATE FUNCTION TP1_jeu.convert(varchar(50))
	RETURNS integer AS
	 'SELECT id_ville FROM TP1_jeu.ville WHERE ($1 LIKE TP1_jeu.ville.nom_ville);'
	LANGUAGE SQL;

	ALTER TABLE TP1_jeu.visiteur ALTER COLUMN ville TYPE bigint USING (convert(ville));


# 11
UPDATE TP1_jeu.visiteur SET ville = (SELECT id_ville FROM TP1_jeu.ville WHERE nom_ville LIKE 'Aix en Provence') WHERE login LIKE 'Ian';
UPDATE TP1_jeu.visiteur SET ville = (SELECT id_ville FROM TP1_jeu.ville WHERE nom_ville LIKE 'Brette les Pins') WHERE login LIKE 'Sean';

# 12
ALTER TABLE TP1_jeu.jeu RENAME COLUMN nb_joueur TO nb_joueur_max;

# 13
SELECT COUNT(id_visiteur) FROM TP1_jeu.visiteur;

# 14
SELECT id_avatar FROM TP1_jeu.partie WHERE id_jeu = (SELECT(id_jeu) FROM TP1_jeu.jeu WHERE (nom_jeu LIKE 'League of Angels')) ;

# 15
SELECT id_visiteur AS id_visiteur, COUNT(id_avatar) AS TOTAL FROM TP1_jeu.avatar WHER GROUP BY id_visiteur;

# 16
SELECT COUNT(id_objet) AS TOTAL FROM TP1_jeu.stock WHERE id_visiteur = (SELECT id_visiteur FROM TP1_jeu.visiteur WHERE login LIKE 'Elijah');

# 17 On suppose que c est aussi pour Elijah
SELECT nom_objet FROM TP1_jeu.objet JOIN TP1_jeu.stock ON ( TP1_jeu.objet.id_objet = TP1_jeu.stock.id_objet) WHERE id_visiteur = (SELECT id_visiteur FROM TP1_jeu.visiteur WHERE login LIKE 'Elijah');

# 18
SELECT DISTINCT id_visiteur FROM TP1_jeu.avatar WHERE (code_dsc - 300) >= 0 ORDER BY id_visiteur;

# 19
SELECT SUM(prix) AS Depense FROM TP1_jeu.objet JOIN TP1_jeu.stock ON ( TP1_jeu.objet.id_objet = TP1_jeu.stock.id_objet) WHERE id_visiteur = (SELECT id_visiteur FROM TP1_jeu.visiteur WHERE login LIKE 'Elijah');

# 20
(SELECT nom_avatar, race, sexe FROM TP1_jeu.avatar WHERE xp = MAX(xp)) JOIN TP1_jeu.objet ON (TP1_jeu.avatar.id_race = TP1_jeu.race.avatar);

SELECT (nom_avatar, nom_race, sexe) FROM TP1_jeu.avatar JOIN TP1_jeu.race ON (TP1_jeu.avatar.id_race = TP1_jeu.race.id_race) WHERE xp = (SELECT max(xp) FROM TP1_jeu.avatar) ;

# 21
CREATE VIEW TP1_jeu.test AS
	(SELECT TP1_jeu.visiteur.login AS login, TP1_jeu.visiteur.id_visiteur AS visiteur,TP1_jeu.avatar.nom_avatar AS avatar, TP1_jeu.race.nom_race AS race, TP1_jeu.jeu.nom_jeu AS jeu, TP1_jeu.partie.highscore AS highscore
		FROM TP1_jeu.visiteur
		JOIN TP1_jeu.avatar ON (TP1_jeu.visiteur.id_visiteur = TP1_jeu.avatar.id_visiteur)
		JOIN TP1_jeu.race ON (TP1_jeu.race.id_race = TP1_jeu.avatar.id_race)
		JOIN TP1_jeu.partie ON (TP1_jeu.partie.id_avatar = TP1_jeu.avatar.id_avatar)
		JOIN TP1_jeu.jeu ON (TP1_jeu.jeu.id_jeu = TP1_jeu.partie.id_jeu)
	);

# 22
SELECT TP1_jeu.visiteur.id_visiteur as joueur ,AVG(highscore) AS moyenne FROM TP1_jeu.partie
	JOIN TP1_jeu.avatar ON(TP1_jeu.avatar.id_avatar = TP1_jeu.partie.id_avatar)
	JOIN TP1_jeu.visiteur ON(TP1_jeu.visiteur.id_visiteur = TP1_jeu.avatar.id_visiteur)
	GROUP BY TP1_jeu.visiteur.id_visiteur
	ORDER BY moyenne;

# La jointure avec la table jeu n'est pas obligatoire pour le calcul de la moyenne
# Ici on l'utilise pour afficher le nom du jeu associer au highscore
# Si on veut supprimer cette jointure alors remplacer le GROUP BY avec :
# GROUP BY TP1_jeu.partie.id_jeu

SELECT TP1_jeu.jeu.nom_jeu, AVG(highscore) AS moyenne FROM TP1_jeu.partie
	JOIN TP1_jeu.avatar ON(TP1_jeu.avatar.id_avatar = TP1_jeu.partie.id_avatar)
	JOIN TP1_jeu.visiteur ON(TP1_jeu.visiteur.id_visiteur = TP1_jeu.avatar.id_visiteur)
	JOIN TP1_jeu.jeu ON(TP1_jeu.jeu.id_jeu = TP1_jeu.partie.id_jeu)
	GROUP BY TP1_jeu.jeu.id_jeu
	ORDER BY moyenne;

# 23
SELECT nom_race FROM TP1_jeu.race WHERE id_race = (
	SELECT id_race FROM TP1_jeu.avatar WHERE id_avatar = (
		SELECT id_avatar FROM TP1_jeu.partie WHERE highscore = (
			SELECT MAX(highscore) FROM TP1_jeu.partie WHERE	id_jeu =(
				SELECT id_jeu FROM TP1_jeu.jeu WHERE (nom_jeu LIKE 'Plants vs Zombies')
			)
		)
	)
);

# 24
SELECT role FROM TP1_jeu.partie WHERE highscore = (
	SELECT MAX(highscore) FROM TP1_jeu.partie WHERE	id_jeu =(
		SELECT id_jeu FROM TP1_jeu.jeu WHERE (nom_jeu LIKE 'Plants vs Zombies')
	)
);

# 25
SELECT nom_objet,SUM(nb_achat) as total FROM TP1_jeu.stock
JOIN TP1_jeu.objet ON (TP1_jeu.stock.id_objet = TP1_jeu.objet.id_objet )
GROUP BY TP1_jeu.objet.id_objet
ORDER BY total;

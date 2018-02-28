# 1
CREATE SCHEMA TP3_videoclub;
SET search_path TO TP3_videoclub,u_l3info005;

# 2
ALTER TABLE client
	ADD statut VARCHAR DEFAULT 'ok',
	ADD CONSTRAINT chk_statut CHECK (statut IN ('ok', 'banni', 'sursis'));

# 3
ALTER TABLE emprunt
	ADD CONSTRAINT change_id
	FOREIGN KEY (id_dvd)
	REFERENCES dvd(id_dvd)
	ON DELETE CASCADE
	ON UPDATE CASCADE;

# 4

	SELECT count(id_pers) FROM film where
		id_pers IN (select id_pers FROM acteur WHERE
			id_film = (SELECT id_film FROM film WHERE
				id_genre = (SELECT id_genre FROM genre WHERE nom_genre LIKE 'Drame')));

# 5
CREATE VIEW vue1 AS
	(SELECT dvd.id_dvd as id_dvd, film.titre as titre, personne.nom_pers as nom_realisateur, genre.nom_genre as nom_genre, magasin.id_magasin as id_magasin FROM dvd
	JOIN film ON (film.id_film = dvd.id_film)
	JOIN personne ON (personne.id_pers = film.id_pers )
	JOIN genre ON (genre.id_genre = film.id_genre)
	JOIN magasin ON (magasin.id_magasin = dvd.id_magasin)
);

# 6
CREATE FUNCTION nb_emprunt(film1 TEXT) RETURNS BIGINT AS
	'SELECT COUNT(*) FROM emprunt WHERE id_dvd IN (SELECT id_dvd FROM dvd WHERE id_film IN (SELECT id_film FROM film WHERE titre LIKE film1));'
LANGUAGE SQL;

# 7
SELECT id_film,count(id_film) AS nb FROM emprunt
	JOIN dvd ON(emprunt.id_dvd = dvd.id_dvd) GROUP BY id_film HAVING count(id_film)
		>= ALL (SELECT count(id_film) FROM emprunt
			JOIN dvd ON(emprunt.id_dvd = dvd.id_dvd) GROUP BY id_film) ;

# 8
CREATE FUNCTION nb_emprunt_max(id_cli BIGINT) RETURNS BIGINT AS $$
	DECLARE
		nb BIGINT;
	BEGIN
		nb = (SELECT caution FROM client WHERE id_client = id_cli) / 10;
		RETURN nb;
	END; $$ LANGUAGE PLPGSQL;

	SELECT nb_emprunt_max(1);

# 9
CREATE FUNCTION dispo(nomGenre TEXT, idMagasin BIGINT) RETURNS SETOF RECORD AS $$
	BEGIN
		return SELECT titre FROM vue1 WHERE nom_genre LIKE nomGenre AND id_magasin=idMagasin;
	END; $$ LANGUAGE PLPGSQL;

	SELECT * FROM dispo('Drame',1) AS (titre VARCHAR);

# 10
CREATE FUNCTION updateStatut() RETURNS VOID AS $$
	DECLARE
		cli BIGINT;
		nb BIGINT;
	BEGIN
	FOR cli IN SELECT id_client FROM client
	LOOP
		nb = (SELECT COUNT(*) FROM emprunt WHERE id_client=cli);
		IF nb >= (SELECT nb_emprunt_max(cli)) OR
		CURRENT_DATE + 3 > ALL (SELECT date_deb FROM emprunt WHERE id_client=cli AND date_fin=NULL) THEN
			UPDATE client SET statut = 'sursis' WHERE id_client=cli;
		ELSE
			UPDATE client SET statut = 'ok' WHERE id_client=cli;
		END IF;
	END LOOP;
END; $$ LANGUAGE PLPGSQL;

# 11

CREATE OR REPLACE FUNCTION checkBan() RETURNS TRIGGER AS $$
	DECLARE
		nb BIGINT;
	BEGIN
		IF (OLD.date_deb + INTERVAL '3 days' < NEW.date_fin) THEN
			nb = (SELECT COUNT(*) FROM emprunt WHERE id_client=OLD.id_client AND date_deb + INTERVAL '3 months' > CURRENT_DATE AND date_deb + 3 < date_fin);
			IF nb >= 9 THEN
				UPDATE client SET statut = 'banni' where id_client=OLD.id_client;
			END IF;
		END IF;
		RETURN NEW;
	END; $$ LANGUAGE PLPGSQL;

	CREATE TRIGGER seraTuBanni
		AFTER UPDATE OF date_fin ON emprunt
		FOR EACH ROW EXECUTE PROCEDURE checkBan();

# 12

CREATE FUNCTION deban() RETURNS VOID AS $$
DECLARE
	cli BIGINT;
BEGIN
	FOR cli IN SELECT id_client FROM client
	LOOP
		IF CURRENT_DATE - INTERVAL '3 months' >= ALL (SELECT date_debut FROM emprunt WHERE id_client=cli ) THEN
			UPDATE client SET statut = 'sursis' WHERE id_client=cli;
		END IF;
	END LOOP;
END; $$ LANGUAGE PLPGSQL;

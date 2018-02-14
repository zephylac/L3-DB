# 1
DROP ROLE l3info005_011;
CREATE ROLE l3info005_011;
GRANT l3info005_011 TO u_l3info005;
GRANT l3info005_011 TO u_l3info011;

# 2
	CREATE SCHEMA u_l3info005;
	CREATE SCHEMA u_l3info011;



################
################

# 1
CREATE FUNCTION bonjour()
		RETURNS varchar(50)
		AS
		$BODY$
		BEGIN
			RETURN 'Bonjour '|| current_user || ',quelle belle journee n''est ce pas?';
		END;
		$BODY$ LANGUAGE PLPGSQL;

# 2

CREATE FUNCTION compar(n INT, m INT) RETURNS RECORD AS $$
	DECLARE
			ret RECORD;
		BEGIN
		IF n < m THEN
			SELECT ('min=' || n) , ('max=' || m) INTO ret;
		ELSE
			IF m < n THEN
				SELECT ('min=' || m ), ('max=' || n) INTO ret;
			ELSE
				SELECT ('equal=' || n) INTO ret;
			END IF;
		END IF;
		RETURN ret;
	END; $$ LANGUAGE PLPGSQL;

	CREATE FUNCTION comparbonus(n INT, m INT) RETURNS RECORD AS $$
		DECLARE
				ret RECORD;
			BEGIN
			IF n < m THEN
				ret := (n::INTEGER , m::INTEGER, NULL::INTEGER);
			ELSE
				IF m < n THEN
					ret := (m::INTEGER , n::INTEGER, NULL::INTEGER);
				ELSE
					ret := (NULL::INTEGER, NULL::INTEGER,n::INTEGER);
				END IF;
			END IF;
			RETURN ret;
		END; $$ LANGUAGE PLPGSQL;

	SELECT * FROM compar(2,3) AS (min INTEGER,max INTEGER, equal INTEGER);

# 3

ALTER TABLE visiteur ADD nom VARCHAR(50);
ALTER TABLE visiteur ADD prenom VARCHAR(50);

# 4

CREATE FUNCTION maj_nom_prenom(login1 TEXT, nom1 TEXT,prenom1 TEXT) RETURNS VOID AS
'UPDATE visiteur SET nom = nom1, prenom=prenom1 WHERE login LIKE login1;'
LANGUAGE SQL;

SELECT maj_nom_prenom('Billy','Bil','lly');

# 5
CREATE VIEW TP1_jeu.test AS
	(SELECT TP1_jeu.visiteur.login AS login, TP1_jeu.visiteur.id_visiteur AS visiteur,TP1_jeu.avatar.nom_avatar AS avatar, TP1_jeu.race.nom_race AS race, TP1_jeu.jeu.nom_jeu AS jeu, TP1_jeu.partie.highscore AS highscore
		FROM TP1_jeu.visiteur
		JOIN TP1_jeu.avatar ON (TP1_jeu.visiteur.id_visiteur = TP1_jeu.avatar.id_visiteur)
		JOIN TP1_jeu.race ON (TP1_jeu.race.id_race = TP1_jeu.avatar.id_race)
		JOIN TP1_jeu.partie ON (TP1_jeu.partie.id_avatar = TP1_jeu.avatar.id_avatar)
		JOIN TP1_jeu.jeu ON (TP1_jeu.jeu.id_jeu = TP1_jeu.partie.id_jeu)
	);

	CREATE FUNCTION listing(jeu1 TEXT, login1 TEXT) RETURNS SETOF RECORD AS $$
	DECLARE
			ret RECORD;
			BEGIN
			FOR ret IN SELECT avatar , race FROM test WHERE login LIKE login1
			AND jeu LIKE jeu1
			ORDER BY highscore
			LOOP
			RETURN NEXT ret;
			END LOOP;
			RETURN;
		END; $$ LANGUAGE PLPGSQL;

		SELECT * FROM listing('Forge of Empire','Elijah')AS (a VARCHAR,b VARCHAR);

		# 6

		CREATE FUNCTION maj_all_np_visiteur() RETURNS VOID AS $$
			BEGIN
				 maj_nom_prenom($1, substring($1 FROM 1 FOR 3), upper(substring(FROM 2 FOR 1)) || substring($1 FROM 2 FOR 2) );
			END; $$ LANGUAGE PLPGSQL;

# 1
SELECT nom_jeu, COUNT(id_avatar) FROM jeu JOIN partie ON (partie.id_jeu = jeu.id_jeu) GROUP BY nom_jeu;

# 2
CREATE FUNCTION fct2(nb INT, jeu1 TEXT) RETURNS VOID AS
'UPDATE jeu SET nb_joueur = nb WHERE nom_jeu LIKE jeu1;'
LANGUAGE SQL;

# 2b
SELECT fct2(5,'Plants vs Zombies');

# 3
CREATE FUNCTION fct3() RETURNS TEXT AS $$
	DECLARE
		a VARCHAR;
	BEGIN
 		a = nom_jeu FROM jeu JOIN partie ON (partie.id_jeu = jeu.id_jeu) GROUP BY nom_jeu HAVING COUNT(id_avatar) >= ALL ( SELECT COUNT(id_avatar) FROM partie GROUP BY id_jeu);
		IF a LIKE '%a%' THEN
			RAISE NOTICE 'waouh';
		ELSE
			RAISE NOTICE 'Bof';
		END IF;
		 RETURN a;
	END; $$ LANGUAGE PLPGSQL;

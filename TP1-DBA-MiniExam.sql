# Start time : 09/02/2018 14h30
# End time : 09/02/2018 15h35
# Etudiant : unknown

# 1
ALTER TABLE TP1_jeu.save ADD COLUMN id_visiteur integer;

# 2
UPDATE TP1_jeu.save SET id_visiteur = (SELECT id_visiteur FROM TP1_jeu.avatar WHERE (TP1_jeu.save.id_avatar = TP1_jeu.avatar.id_avatar));

# 3
ALTER TABLE TP1_jeu.save DROP CONSTRAINT TP1_jeu.save_pkey;
ALTER TABLE TP1_jeu.save ADD PRIMARY KEY (id_jeu, id_visiteur);

# 4
INSERT INTO TP1_jeu.save VALUES ((SELECT id_avatar FROM TP1_jeu.avatar WHERE nom_avatar LIKE 'Wajdi'), (SELECT id_jeu FROM TP1_jeu.jeu WHERE nom_jeu LIKE 'Forge of Empire'), '09/02/18', 106, '/Save/Part001_FoE.txt');

# 5
SELECT nom_avatar FROM TP1_jeu.save JOIN TP1_jeu.avatar ON (TP1_jeu.save.id_avatar = TP1_jeu.avatar.id_avatar) WHERE nb_pv > 80;

# 6
SELECT nom_jeu, highscore, login
	FROM TP1_jeu.partie
	JOIN TP1_jeu.jeu ON (TP1_jeu.jeu.id_jeu = TP1_jeu.partie.id_jeu)
	JOIN TP1_jeu.avatar ON (TP1_jeu.avatar.id_avatar = TP1_jeu.partie.id_avatar)
	JOIN TP1_jeu.visiteur ON (TP1_jeu.visiteur.id_visiteur = TP1_jeu.avatar.id_visiteur)
	WHERE highscore = (SELECT MAX(highscore) FROM TP1_jeu.partie WHERE id_jeu = TP1_jeu.jeu.id_jeu );

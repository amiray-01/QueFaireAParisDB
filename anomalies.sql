-- Détecter des valeurs nulles ou vides dans des champs critiques
-- Requête pour détecter les événements sans URL ou titre, ou avec des dates de début manquantes
\prompt 'Requête pour détecter les événements sans URL ou titre, ou avec des dates de début manquantes\n' s
SELECT COUNT(*) AS nombre_d_evenements
FROM temp_evenements
WHERE URL IS NULL OR URL = ''
OR Titre IS NULL OR Titre = ''
OR Date_de_debut IS NULL
OR Date_de_fin IS NULL;


\prompt 'Requête pour trouver des événements dont la date de fin est antérieure à la date de début (on affiche uniquement 5 max)\n' s
-- Requête pour trouver des événements dont la date de fin est antérieure à la date de début
SELECT ID, Titre, Date_de_debut, Date_de_fin
FROM temp_evenements
WHERE Date_de_debut >= Date_de_fin
LIMIT 5;

\prompt 'Requête pour trouver des événements sans information de contact valide (on affiche uniquement 5 max)\n' s
-- Requête pour trouver des événements sans information de contact valide
SELECT ID, Titre, Url_de_contact, Telephone_de_contact, Email_de_contact
FROM temp_evenements
WHERE Url_de_contact IS NULL OR Url_de_contact = ''
AND (Telephone_de_contact IS NULL OR Telephone_de_contact = '')
AND (Email_de_contact IS NULL OR Email_de_contact = '')
AND ( url_facebook_associe IS NULL OR url_facebook_associe = '')
AND ( url_twitter_associe IS NULL OR url_twitter_associe = '')
LIMIT 5;

\prompt 'Requête pour trouver des occurences qui sont mal triés (on affiche uniquement 5 max)\n' s
-- Requête pour trouver des occurences qui sont mal triés 
SELECT 
    SUBSTRING(split_part(occurrence, '_', 1) FROM 1 FOR 19)::TIMESTAMP as date_de_debut,
    SUBSTRING(split_part(occurrence, '_', 2) FROM 1 FOR 19)::TIMESTAMP as date_de_fin,
    e.id
FROM temp_evenements t
JOIN Evenements e ON t.ID = e.id
CROSS JOIN LATERAL unnest(string_to_array(t.Occurrences, ';')) AS occurrence
WHERE t.Occurrences IS NOT NULL 
AND (SUBSTRING(split_part(occurrence, '_', 1) FROM 1 FOR 19)::TIMESTAMP) >= (SUBSTRING(split_part(occurrence, '_', 2) FROM 1 FOR 19)::TIMESTAMP)
LIMIT 5;

\prompt 'Requête pour trouver les lignes avec des codes postaux invalides\n' s
-- Requête pour trouver les lignes avec des codes postaux invalides
SELECT id,code_postal FROM temp_evenements WHERE code_postal !~ '^[0-9]{5}$';

\prompt 'Test de la df adresse_du_lieu, code_postal → nom_du_lieu, ville, coordonnées géographiques, acces_pmr, acces_mal_voyant, acces_mal_entendant\n' s
-- pour la df adresse_du_lieu, code_postal → nom_du_lieu, ville, coordonnées géographiques, acces_pmr, acces_mal_voyant, acces_mal_entendant
SELECT 
    adresse_du_lieu, 
    code_postal, 
    COUNT(DISTINCT nom_du_lieu) AS distinct_names, 
    COUNT(DISTINCT ville) AS distinct_villes,
    COUNT(DISTINCT coordonnees_geographiques) AS distinct_coords,
    COUNT(DISTINCT acces_pmr) AS distinct_acces_pmr,
    COUNT(DISTINCT acces_mal_voyant) AS distinct_acces_mal_voyant,
    COUNT(DISTINCT acces_mal_entendant) AS distinct_acces_mal_entendant
FROM temp_evenements
GROUP BY adresse_du_lieu, code_postal
HAVING COUNT(DISTINCT nom_du_lieu) > 1 OR 
       COUNT(DISTINCT ville) > 1 OR 
       COUNT(DISTINCT coordonnees_geographiques) > 1 OR 
       COUNT(DISTINCT acces_pmr) > 1 OR 
       COUNT(DISTINCT acces_mal_voyant) > 1 OR 
       COUNT(DISTINCT acces_mal_entendant) > 1
LIMIT 5;

\prompt 'Test de la df url_de_contact → email_de_contact, url_facebook_associe,url_twitter_associe\n' s
-- pour la df url_de_contact → email_de_contact, url_facebook_associe,url_twitter_associe
SELECT url_de_contact, COUNT(DISTINCT url_facebook_associe) AS distinct_fb, COUNT(DISTINCT url_twitter_associe) as distinct_tw, COUNT(DISTINCT email_de_contact) AS distinct_emails
FROM temp_evenements
GROUP BY url_de_contact
HAVING COUNT(DISTINCT url_facebook_associe) > 1 OR COUNT(DISTINCT url_twitter_associe) > 1 OR COUNT(DISTINCT email_de_contact) > 1
LIMIT 5;

\prompt 'Test de la df url_de_reservation → url_de_reservation_texte\n' s
-- pour la df url_de_contact → url_de_reservation_texte
SELECT url_de_reservation, COUNT(DISTINCT url_de_reservation_texte) AS distinct_texts
FROM temp_evenements
GROUP BY url_de_reservation
HAVING COUNT(DISTINCT url_de_reservation_texte) > 1
LIMIT 5;
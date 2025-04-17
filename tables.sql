DROP TABLE IF EXISTS Evenements CASCADE;
DROP TABLE IF EXISTS Lieux CASCADE;
DROP TABLE IF EXISTS Transport CASCADE;
DROP TABLE IF EXISTS MotsCles CASCADE;
DROP TABLE IF EXISTS EvenementsMotsCles CASCADE;
DROP TABLE IF EXISTS Occurrence CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Contact CASCADE;
DROP TABLE IF EXISTS lieux_transport CASCADE;
DROP TABLE IF EXISTS temp_evenements CASCADE;

-------------------------------------- CREATION DES TABLES  --------------------------------------

CREATE TABLE Lieux (
    nom_du_lieu VARCHAR(255),
    adresse_du_lieu VARCHAR(255),
    code_postal VARCHAR(20) CHECK (code_postal ~ '^[0-9]{5}$'),
    ville VARCHAR(100),
    longitude FLOAT,
    latitude FLOAT,
    acces_pmr BOOLEAN,
    acces_mal_voyant BOOLEAN,
    acces_mal_entendant BOOLEAN,
    CONSTRAINT pk_lieu PRIMARY KEY (adresse_du_lieu, code_postal)
);

CREATE TABLE Evenements (
    id SERIAL PRIMARY KEY,
    url VARCHAR(255) NOT NULL UNIQUE,
    titre TEXT NOT NULL,
    chapeau TEXT,
    description TEXT,
    url_de_l_image TEXT,
    texte_alternatif_de_l_image TEXT,
    date_de_debut TIMESTAMP NOT NULL,
    date_de_fin TIMESTAMP NOT NULL CHECK (date_de_debut < date_de_fin),
    type_de_prix VARCHAR(255),
    detail_du_prix TEXT,
    type_d_acces VARCHAR(50),
    date_de_mise_a_jour TIMESTAMP,
    programmes TEXT,
    en_ligne_address_url TEXT,
    en_ligne_address_url_text TEXT,
    en_ligne_address_text TEXT,
    audience TEXT,
    childrens TEXT,
    groupe VARCHAR(255),
    adresse_du_lieu VARCHAR(255),
    code_postal VARCHAR(5),
    CONSTRAINT fk_lieu FOREIGN KEY (adresse_du_lieu, code_postal) REFERENCES Lieux(adresse_du_lieu, code_postal)
);

CREATE TABLE Transport (
    type_transport VARCHAR(50),
    ligne VARCHAR(50),
    station VARCHAR(100), 
    distance VARCHAR(100),
    lien VARCHAR(255),
    adresse_du_lieu VARCHAR(255),
    code_postal VARCHAR(5),
    PRIMARY KEY (type_transport,distance),
    CONSTRAINT fk_lieu FOREIGN KEY (adresse_du_lieu, code_postal) REFERENCES Lieux(adresse_du_lieu, code_postal)
);

CREATE TABLE MotsCles (
    motcle VARCHAR(100) PRIMARY KEY
);

CREATE TABLE EvenementsMotsCles (
    id_evenement INTEGER REFERENCES Evenements(id),
    motcle VARCHAR(100) REFERENCES MotsCles(motcle),
    PRIMARY KEY (id_evenement, motcle)
);

CREATE TABLE Occurrence (
    date_heure_debut TIMESTAMP,
    date_heure_fin TIMESTAMP,
    id_evenement INTEGER REFERENCES Evenements(id),
    PRIMARY KEY (id_evenement, date_heure_debut, date_heure_fin),
    CONSTRAINT date_heure CHECK (date_heure_debut <= date_heure_fin)
);

CREATE TABLE Reservation (
    url_de_reservation TEXT,
    url_de_reservation_texte TEXT,
    id_evenement INTEGER REFERENCES Evenements(id),
    PRIMARY KEY (id_evenement, url_de_reservation)
);

CREATE TABLE Contact (
    url_de_contact TEXT,
    telephone_de_contact VARCHAR(20),
    email_de_contact VARCHAR(255),
    url_facebook_associe TEXT,
    url_twitter_associe TEXT,
    id_evenement INTEGER UNIQUE REFERENCES Evenements(id),
    PRIMARY KEY (id_evenement, url_de_contact),
    CONSTRAINT check_contact_info CHECK (
        telephone_de_contact IS NOT NULL 
        OR email_de_contact IS NOT NULL 
        OR url_facebook_associe IS NOT NULL 
        OR url_twitter_associe IS NOT NULL
    )
);

CREATE TABLE lieux_transport (
    adresse_du_lieu VARCHAR(255),
    code_postal VARCHAR(5),
    type_transport VARCHAR(50),
    distance VARCHAR(100),
    CONSTRAINT pk_lieux_transport PRIMARY KEY (adresse_du_lieu, code_postal, type_transport, distance),
    CONSTRAINT fk_lieux FOREIGN KEY (adresse_du_lieu, code_postal) REFERENCES Lieux(adresse_du_lieu, code_postal),
    CONSTRAINT fk_transport FOREIGN KEY (type_transport, distance) REFERENCES Transport(type_transport, distance)
);


-------------------------------------- CREATION DES INDEXS  --------------------------------------

-- Index pour une recherche rapide des événements par lieu
CREATE INDEX idx_lieu ON Evenements(adresse_du_lieu, code_postal);

-- Index pour optimiser les recherches par URL dans la table Evenements
CREATE INDEX idx_evenements_url ON Evenements(url);

-- Index composite pour optimiser les recherches et jointures par adresse du lieu et code postal
CREATE INDEX idx_lieux_adresse_du_lieu_code_postal ON Lieux(adresse_du_lieu, code_postal);

--Index pour une recherche rapide des mots-clés
CREATE INDEX idx_mots_cles_motcle ON MotsCles(motcle);

-- Index pour optimiser les requêtes par code postal dans Lieux
CREATE INDEX idx_code_postal ON Lieux(code_postal);

-- Index pour optimiser les recherches par ville dans Lieux
CREATE INDEX idx_ville ON Lieux(ville);

-- Index pour les requêtes filtrant les événements par date de début
CREATE INDEX idx_date_de_debut ON Evenements(date_de_debut);

-- Index pour les requêtes filtrant les événements par date de mise à jour
CREATE INDEX idx_date_de_mise_a_jour ON Evenements(date_de_mise_a_jour);

-- Index pour une recherche rapide d'occurrences par événement
CREATE INDEX idx_occurrence_evenement ON Occurrence(id_evenement);

-- Index pour une recherche rapide des mots-clés, utile pour les recherches et filtrages
CREATE INDEX idx_motcle ON MotsCles(motcle);

-- Index pour une recherche rapide des réservations par événement
CREATE INDEX idx_reservation_evenement ON Reservation(id_evenement);

-- Index pour améliorer l'efficacité des jointures entre Evenements et Contact
CREATE INDEX idx_contact_evenement ON Contact(id_evenement);

-- Index pour les recherches de transport par type
CREATE INDEX idx_type_transport ON Transport(type_transport);

-- Index pour les recherches de transport par station
CREATE INDEX idx_station_transport ON Transport(station);




-- TABLE SOURCE --

CREATE TEMP TABLE temp_evenements (
    ID INTEGER,
    URL VARCHAR(255),
    Titre TEXT,
    Chapeau TEXT,
    Description TEXT,
    Date_de_debut TIMESTAMP,
    Date_de_fin TIMESTAMP,
    Occurrences TEXT,
    Description_de_la_date TEXT,
    URL_de_l_image TEXT,
    Texte_alternatif_de_l_image TEXT,
    Credit_de_l_image TEXT,
    Mots_cles TEXT,
    Nom_du_lieu VARCHAR(255),
    Adresse_du_lieu TEXT,
    Code_postal VARCHAR(20),
    Ville VARCHAR(100),
    Coordonnees_geographiques TEXT,
    Acces_pmr BOOLEAN,
    Acces_mal_voyant BOOLEAN,
    Acces_mal_entendant BOOLEAN,
    Transport TEXT,
    Url_de_contact TEXT,
    Telephone_de_contact VARCHAR(20),
    Email_de_contact VARCHAR(255),
    URL_Facebook_associe TEXT,
    URL_Twitter_associe TEXT,
    Type_de_prix TEXT,
    Detail_du_prix TEXT,
    Type_d_acces TEXT,
    URL_de_reservation TEXT,
    URL_de_reservation_Texte TEXT,
    Date_de_mise_a_jour TIMESTAMP,
    Image_de_couverture TEXT,
    Programmes TEXT,
    En_ligne_address_url TEXT,
    En_ligne_address_url_text TEXT,
    En_ligne_address_text TEXT,
    Title_event TEXT,
    Audience TEXT,
    Childrens TEXT,
    Groupe TEXT
);

\COPY temp_evenements FROM 'que-faire-a-paris-.csv' DELIMITER ';' CSV HEADER;



-------------------------------------- PEUPLEMENT DES TABLES --------------------------------------

-- LIEUX --

INSERT INTO Lieux (nom_du_lieu, adresse_du_lieu, code_postal, ville, longitude, latitude, acces_pmr, acces_mal_voyant, acces_mal_entendant)
SELECT Nom_du_lieu, Adresse_du_lieu, Code_postal, Ville,
       SPLIT_PART(Coordonnees_geographiques, ',', 1)::FLOAT AS longitude,
       SPLIT_PART(Coordonnees_geographiques, ',', 2)::FLOAT AS latitude,
       Acces_pmr, Acces_mal_voyant, Acces_mal_entendant
FROM temp_evenements WHERE adresse_du_lieu IS NOT NULL AND code_postal IS NOT NULL AND code_postal ~ '^[0-9]{5}$'
ON CONFLICT (adresse_du_lieu, code_postal) DO NOTHING;

-- EVENEMENTS --

INSERT INTO Evenements (
    id,
    url, 
    titre, 
    chapeau, 
    description, 
    url_de_l_image, 
    texte_alternatif_de_l_image, 
    date_de_debut, 
    date_de_fin, 
    type_de_prix, 
    detail_du_prix, 
    type_d_acces, 
    date_de_mise_a_jour, 
    programmes, 
    en_ligne_address_url, 
    en_ligne_address_url_text, 
    en_ligne_address_text, 
    audience, 
    childrens, 
    groupe, 
    adresse_du_lieu,
    code_postal
)
SELECT 
    te.ID,
    te.URL, 
    te.Titre, 
    te.Chapeau, 
    te.Description, 
    te.URL_de_l_image, 
    te.Texte_alternatif_de_l_image, 
    te.Date_de_debut, 
    te.Date_de_fin, 
    te.Type_de_prix, 
    te.Detail_du_prix, 
    te.Type_d_acces, 
    te.Date_de_mise_a_jour, 
    te.Programmes, 
    te.En_ligne_address_url, 
    te.En_ligne_address_url_text, 
    te.En_ligne_address_text, 
    te.Audience, 
    te.Childrens, 
    te.Groupe,
    l.adresse_du_lieu,
    l.code_postal
FROM temp_evenements te
JOIN Lieux l ON te.adresse_du_lieu = l.adresse_du_lieu AND te.code_postal = l.code_postal
WHERE NOT EXISTS (
    SELECT 1 FROM Evenements e WHERE e.url = te.URL
)
AND te.date_de_debut IS NOT NULL
AND te.date_de_fin IS NOT NULL
AND te.date_de_debut < te.date_de_fin;

-- MOTS CLES --

WITH split_motscles AS (
  SELECT DISTINCT ON (trim(lower(mot_cle))) trim(lower(mot_cle)) AS mot_cle
  FROM temp_evenements,
       unnest(string_to_array(mots_cles, ',')) AS mot_cle
)
INSERT INTO MotsCles (motcle)
SELECT mot_cle
FROM split_motscles
WHERE mot_cle IS NOT NULL AND mot_cle != ''
ON CONFLICT (motcle) DO NOTHING; 

-- EVENEMENTS MOTS CLES --

INSERT INTO EvenementsMotsCles (id_evenement, motcle)
SELECT e.id AS id_evenement, m.motcle AS motcle
FROM temp_evenements t
JOIN Evenements e ON t.URL = e.url
CROSS JOIN unnest(string_to_array(t.mots_cles, ',')) AS mot_cle
JOIN MotsCles m ON TRIM(LOWER(m.motcle)) = TRIM(LOWER(mot_cle))
ON CONFLICT (id_evenement, motcle) DO NOTHING;

-- TRANSPORT --


INSERT INTO Transport (type_transport, ligne, station, distance, lien, adresse_du_lieu,code_postal)
SELECT
  type_transport,
  ligne,
  station,
  distance || 'm',
  CASE 
    WHEN type_transport = 'Vélib' THEN (regexp_match(Transport, '<a href="([^"]+)">'))[1]
    ELSE NULL 
  END AS lien,
  adresse_du_lieu,
  code_postal
FROM (
  SELECT
    (regexp_matches(Transport, '(Métro|Bus|Vélib) ->', 'g'))[1] AS type_transport,
    (regexp_matches(Transport, '-> (\d+|[^\s]+) :', 'g'))[1] AS ligne,
    (regexp_matches(Transport, ': (.*?) \((\d+\.?\d*)m\)', 'g'))[1] AS station,
    (regexp_matches(Transport, '\((\d+\.?\d*)m\)', 'g'))[1] AS distance,
    Transport,
    l.adresse_du_lieu,
    l.code_postal
  FROM temp_evenements
  JOIN Lieux l ON temp_evenements.adresse_du_lieu = l.adresse_du_lieu AND temp_evenements.code_postal = l.code_postal
) AS tmp_transport
ON CONFLICT(type_transport,distance) DO NOTHING;

-- RESERVATION --


INSERT INTO Reservation (url_de_reservation, url_de_reservation_texte, id_evenement)
SELECT 
    URL_de_reservation, 
    URL_de_reservation_Texte, 
    e.id
FROM temp_evenements t
JOIN Evenements e ON t.ID = e.id
WHERE URL_de_reservation IS NOT NULL;


-- CONTACT --

INSERT INTO Contact (url_de_contact, telephone_de_contact, email_de_contact, url_facebook_associe, url_twitter_associe, id_evenement)
SELECT 
    URL_de_contact, 
    Telephone_de_contact, 
    Email_de_contact, 
    URL_Facebook_associe, 
    URL_Twitter_associe, 
    e.id
FROM temp_evenements t
JOIN Evenements e ON t.ID = e.id
WHERE URL_de_contact IS NOT NULL AND(Telephone_de_contact IS NOT NULL OR Email_de_contact IS NOT NULL OR URL_Facebook_associe IS NOT NULL OR URL_Twitter_associe IS NOT NULL);


-- OCCURRENCE --

INSERT INTO Occurrence (date_heure_debut, date_heure_fin, id_evenement)
SELECT 
    SUBSTRING(split_part(occurrence, '_', 1) FROM 1 FOR 19)::TIMESTAMP,  -- Date de début
    SUBSTRING(split_part(occurrence, '_', 2) FROM 1 FOR 19)::TIMESTAMP,  -- Date de fin
    e.id
FROM temp_evenements t
JOIN Evenements e ON t.ID = e.id
CROSS JOIN LATERAL unnest(string_to_array(t.Occurrences, ';')) AS occurrence
WHERE t.Occurrences IS NOT NULL 
AND (SUBSTRING(split_part(occurrence, '_', 1) FROM 1 FOR 19)::TIMESTAMP) < (SUBSTRING(split_part(occurrence, '_', 2) FROM 1 FOR 19)::TIMESTAMP)
ON CONFLICT (id_evenement, date_heure_debut, date_heure_fin) DO NOTHING;

-- LIEUX TRANSPORT --

INSERT INTO lieux_transport (adresse_du_lieu, code_postal, type_transport, distance)
SELECT DISTINCT
    l.adresse_du_lieu,
    l.code_postal,
    t.type_transport,
    t.distance
FROM 
    Lieux l
JOIN 
    Transport t ON l.adresse_du_lieu = t.adresse_du_lieu AND l.code_postal = t.code_postal
WHERE 
    EXISTS (
        SELECT 1 FROM temp_evenements te 
        WHERE te.adresse_du_lieu = l.adresse_du_lieu AND te.code_postal = l.code_postal
    )
ON CONFLICT (adresse_du_lieu, code_postal, type_transport, distance) DO NOTHING;

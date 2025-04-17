
\echo 'Veuillez entrer un mot clé pour rechercher des événements associés :'
\prompt 'Mot clé : ' motcle

PREPARE EventsAvecMotsCles(text) AS
SELECT e.id, e.titre FROM Evenements e
JOIN EvenementsMotsCles emc ON e.id = emc.id_evenement
JOIN MotsCles mk ON emc.motcle = mk.motcle
WHERE mk.motcle = $1;

EXECUTE EventsAvecMotsCles(:motcle);

\echo 'Requete qui permet de trouver les informations d un lieu donné\n'
\prompt 'Entrez l adresse du lieu : ' adresse
\prompt 'Entrez le code postal : ' postal

PREPARE find_lieu (varchar, varchar) AS
SELECT * FROM Lieux WHERE adresse_du_lieu = $1 AND code_postal = $2;


EXECUTE find_lieu(:adresse, :postal);

\echo 'Requete qui compte le nombre d evenements par type de prix\n'
\prompt 'Entrez le type de prix : ' type_prix

PREPARE count_events_by_type_prix (varchar) AS
SELECT type_de_prix, COUNT(*) AS total_events
FROM Evenements
WHERE type_de_prix = $1
GROUP BY type_de_prix;

EXECUTE count_events_by_type_prix(:type_prix);

\echo 'Requete qui trouve les evenements d une ville selon le type de prix saisi\n'
\prompt 'Entrez le type de prix : ' type_prix
\prompt 'Entrez le nom de la ville : ' ville


PREPARE events_by_type_prix_and_city (varchar, varchar) AS
SELECT titre, date_de_debut, date_de_fin
FROM Evenements
JOIN Lieux ON Evenements.adresse_du_lieu = Lieux.adresse_du_lieu AND Evenements.code_postal = Lieux.code_postal
WHERE type_de_prix = $1 AND Lieux.ville = $2;

EXECUTE events_by_type_prix_and_city(:type_prix, :ville);

\echo 'Requête pour compter les types de transport par ville\n'
\prompt 'Entrez la ville pour laquelle vous voulez compter les types de transport : ' city

PREPARE count_transport_types_by_city (varchar) AS
SELECT ville, type_transport, COUNT(*) AS count
FROM Transport
JOIN Lieux ON Transport.adresse_du_lieu = Lieux.adresse_du_lieu AND Transport.code_postal = Lieux.code_postal
WHERE ville = $1
GROUP BY ville, type_transport;

EXECUTE count_transport_types_by_city(:city);



\echo 'Requête pour trouver les détails de contact d un événement\n'
\prompt 'Entrez l ID de l événement pour lequel vous voulez les détails de contact : ' event_id

PREPARE contact_details_by_event_id (int) AS
SELECT url_de_contact, telephone_de_contact, email_de_contact, url_facebook_associe, url_twitter_associe
FROM Contact
WHERE id_evenement = $1;

EXECUTE contact_details_by_event_id(:event_id);

\echo 'Requête pour trouver les détails des occurrences d un événement\n'
\prompt 'Entrez l ID de l événement pour lequel vous voulez voir les occurrences : ' event_id

PREPARE occurrence_details_by_event_id (int) AS
SELECT date_heure_debut, date_heure_fin
FROM Occurrence
WHERE id_evenement = $1;

EXECUTE occurrence_details_by_event_id(:event_id);







DEALLOCATE EventsAvecMotsCles;
DEALLOCATE find_lieu;
DEALLOCATE count_events_by_type_prix;
DEALLOCATE events_by_type_prix_and_city;
DEALLOCATE count_transport_types_by_city;
DEALLOCATE contact_details_by_event_id;
DEALLOCATE occurrence_details_by_event_id;
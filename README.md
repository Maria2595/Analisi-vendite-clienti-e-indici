# Analisi-vendite-clienti-e-indici

ANALISI VENDITE CLIENTI CON INDICE HERFINDAHL E SHANNON'S ENTROPY (open data azienda ingrosso Deluxe Kaggle)

Descrizione del progetto (Progetto novembre 2026):

L'azienda Deluxe effettua vendite in 15 paesi europei per prodotti di 10 categorie diverse. 
Ho calcolato con SQL l'indice di Herfindahl per analizzare se nel biennio 2019/2020 vi sono pochi clienti che incrementano le vendite e ho completato l'analisi con l'indice Shannon's Entropy per quantificare se nel trend degli acquisti dei clienti si è registrato un incremento della diversificazione oppure più clienti hanno una percentuale equa sulle vendite totali registrate in un paese.


Anteprima dashboard





https://github.com/user-attachments/assets/6746a7be-32c8-47b9-8944-ce5cd1ab7cd5










📁 Contenuto repository

```
Analisi-vendite-clienti-indice-herfindahl-entropy/
├── Dashboard/
│   └── DEL_DASHBOARD.pbix                                      # Dashboard Power BI
├── AnalisiSQL/
│   └── analisi vendite clienti e indici.sql                    # Query: calcolo trend annuale, calcolo KPIs, classficazione clienti, calcolo indici business
├── KaggleDataset/
│   └── deluxe.csv                                              # Dataset originale (Kaggle)
└── README.md



Dati principali del database:

L'azienda Deluxe effettua vendite in 15 paesi europei per prodotti di 10 categorie diverse con ordini effettuati da 80+ clienti.



Tecniche utilizzate:

Window functions per analisi approfondite dei trend

CASE WHEN STATEMENTS per classificare i clienti in base a 5 quantili con utilizzo funzione NTILE per eseguire la classificazione dei clienti in Tier 1 Client, Tier 2 Clienti, Tier 3 Client, Tier 4 Client, Tier 5 Client che rappresentano rispettivamente i clienti con maggiori vendite per nazione



Applicazione delle formule per calcolare Indice di Herfindahl e Indice Entropia con  SQL (antemprima codice):


-- BUSINESS INDEX
WITH n AS( 
SELECT year,
       country,
       COUNT(DISTINCT customer_name) AS customers
FROM sales
GROUP BY 1, 2
ORDER BY 1, 2
),
businessindex AS ( 
SELECT DISTINCT year,
       country,
       customer_name,
       order_value,
       ROUND(SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year),4) AS pi,
       ROUND((SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year))**2,4) as pi_2,
       ROUND((SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year))*(-LN(SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year))),2) AS pi_ln
FROM sales
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3
) 
SELECT n.year,
       n.country,
       n.customers,
       ROUND(SUM(businessindex.pi_2),2) AS HHI,
       ROUND(SUM(businessindex.pi_ln)/LN(n.customers),2) AS ES
FROM n LEFT JOIN businessindex ON n.country = businessindex.country 
GROUP BY 1, 2, 3
ORDER BY 1, 2;















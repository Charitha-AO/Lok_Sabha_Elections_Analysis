# Loksabha Elections Data Analysis Using SQL & Power Bi - Codebasics Resume Project Challenge : 11

## Problem Statement
AtliQ Media is a private media company and they wanted to telecast a show on Lok Sabha elections 2024 in India. Unlike other channels they do not want to have a debate on who is going to win this election, they rather wanted to present insights from 2014 and 2019 elections without any bias and discuss less explored themes like voter turnout percentage in India. Peter is a data analyst in the company, and he is handed over this task of generating meaningful insights from data. Since this is a sensitive topic, he seeked help from his manager Tony Sharma who provided the list of primary and secondary questions.

## Task
Task is to Imagine myself and answer the Primary and Secondary Questions

## Tools Used:
* Excel - Data Extraction, Data Cleaning
* SQL - Data Cleaning, Data Analysis.
* Power Bi - Data Visualization
* Canva - Presentation

## Data Cleaning and Data Validation
📂First, Import the datasets into any SQL Database Server. I have used MYSQL Workbench.

Go to Server, Select Data Import and  Select the Datasets and Import them.

Now, Let's Start Querying...!

### Data Exploration:
1. Unique States from 2014 Dataset
```sql
SELECT count(distinct state) from cons_2014;
```
Result💡: There are 33 Unique States in 2014 Dataset

2. Unique States from 2019 Dataset
```sql
SELECT count(distinct state) from cons_2019;
```
Result💡: There are 36 Unique States in 2014 Dataset

3. States that are present in 2019 but not in 2014 dataset
```sql
SELECT DISTINCT c19.state FROM cons_2019 c19
LEFT JOIN cons_2014 c14 ON c19.state = c14.state
WHERE c14.state IS NULL
ORDER BY c19.state
LIMIT 1000;
```
Result💡: Chhattisgarh, Odisha, Telangana.

Observation🔍: In 2014, Andhra Pradesh underwent bifurcation. For simplicity, all constituencies from that year should be attributed to Telangana state.

4. Updating pc_names of Telangana from 2019 dataset to 2014 dataset as it was bifurcated from Andhra Pradesh to Telangana
```sql 
UPDATE cons_2014 AS cr14
JOIN (
    SELECT DISTINCT pc_name
    FROM cons_2019
    WHERE state = 'Telangana'
) AS cr19_telangana ON cr14.pc_name = cr19_telangana.pc_name
SET cr14.state = 'Telangana'
WHERE cr14.state = 'Andhra Pradesh';
```
After Updating Check the pc_name for Telangana and Andhra Pradesh

5. Distinct pc_name in Telangana State
```sql
SELECT DISTINCT pc_name,state
FROM cons_2019
WHERE state = 'Telangana';
```
Result💡: adilabad, peddapalle, karimnagar, nizamabad, zahirabad, medak, malkajgiri,secundrabad, hyderabad, chevella, mahbubnagar, nagarkurnool,
nalgonda, bhongir, warangal, mahabubabad, khammam.

6. Distinct pc_name in Andhra State
```sql
SELECT DISTINCT pc_name,state
FROM cons_2014
WHERE state = 'Andhra Pradesh';
```
Result💡: aruku, srikakulam, vizianagaram, visakhapatnam, anakapalli, kakinada, amalapuram, rajahmundry, narsapuram, eluru, machilipatnam, vijayawada,
guntur, narasaraopet, bapatla, ongole, nandyal, kurnool, anantapur, hindupur, kadapa, nellore, tirupati, rajampet, chittoor.

7. Unique pc_name from 2014 dataset
```sql
SELECT DISTINCT pc_name FROM cons_2014;
```
Result💡: 508 Unique pc names

8. Unique pc_name from 2019 dataset
```sql
SELECT DISTINCT pc_name FROM cons_2019;
```
Result💡: 540 Unique pc names

Observation🔍: Since, Chhattisgarh and Odisha States are missing in 2014 dataset, we have less number of Constituency names.

9. Check if there is any data where MP Applicant age is less than 25.

Rule to be an MP applicant🔑: As per Article 84 of the constitution, individuals are eligible to become members of Parliament(MP) if; They are citizens of India Fall under the age limit of 25 years in the case of Lok Sabha.
```sql 
SELECT * FROM cons_2014 WHERE age < 25;
```
```sql
SELECT * FROM cons_2019 WHERE age < 25;
```
Observation🔍: There is 1 MP Applicant from 2019  Dataset whose age is less than 25.

 ![min-age_rc11](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/490e61b6-3823-48a7-abab-a269c6d17ab3)

### Data Cleaning:
1. Trimmming the pc_name for both datasets as some pc_name has spaces.
```sql
UPDATE cons_2019
SET pc_name = TRIM(pc_name);
```
```sql
UPDATE cons_2014
SET pc_name = TRIM(pc_name);
```
2. Converting the pc_name to LOWER CASE as some pc_name is in UPPER CASE.
```sql
UPDATE cons_2019
SET pc_name = LOWER(pc_name);
```
```sql
UPDATE cons_2014
SET pc_name = LOWER(pc_name);
```
3. Replacing the pc_name to ' ' as some pc_name has ' (sc)','-',' - ' at the end of the pc_name. 
```sql
UPDATE cons_2019
SET pc_name = REPLACE(REPLACE(REPLACE(pc_name, ' (sc)', ''), ' - ', ' '), '-', ' ');
```
```sql
UPDATE cons_2014
SET pc_name = REPLACE(REPLACE(REPLACE(pc_name, ' (sc)', ''), ' - ', ' '), '-', ' ');
```

* Check if all pc_name from 2014 are present in 2019.
```sql
SELECT distinct c14.pc_name
FROM cons_2014 AS c14
LEFT JOIN cons_2019 AS c19 ON c14.pc_name = c19.pc_name
WHERE c19.pc_name IS NULL;
```
Observation🔍: There are Some Misspelled pc_name and it must be updated.

4. Updating Misspelled pc_names in 2014 Dataset
```sql
UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'chelvella', 'chevella')
WHERE pc_name = 'chelvella';
```
```sql
UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'joynagar', 'jaynagar')
WHERE pc_name = 'joynagar';
```
```sql
UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'burdwan durgapur', 'bardhaman durgapur')
WHERE pc_name = 'burdwan durgapur';
```
```sql
UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'dadar & nagar haveli', 'dadra and nagar haveli')
WHERE pc_name = 'dadar & nagar haveli';
```
## Insights from the dataset 
1. Total Turnout ratio 2014
```sql
 WITH electors_per_pc_2014 AS (
    SELECT pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2014
    GROUP BY pc_name
),
votes_2014 AS (
    SELECT SUM(general_votes) AS total_general_votes,
           SUM(postal_votes) AS total_postal_votes
    FROM cons_2014
),
electors_2014 AS (
    SELECT SUM(total_electors_per_pc) AS total_electors
    FROM electors_per_pc_2014
)
SELECT
    (v.total_general_votes + v.total_postal_votes) * 100.0 / e.total_electors AS turnout_ratio
FROM votes_2014 v, electors_2014 e;
```
Result💡: 66.43088

2. Total Turnout ratio 2019
 ```sql
 WITH electors_per_pc_2019 AS (
    SELECT pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2019
    GROUP BY pc_name
),
votes_2019 AS (
    SELECT SUM(general_votes) AS total_general_votes,
           SUM(postal_votes) AS total_postal_votes
    FROM cons_2019
),
electors_2019 AS (
    SELECT SUM(total_electors_per_pc) AS total_electors
    FROM electors_per_pc_2019
)
SELECT
    (v.total_general_votes + v.total_postal_votes) * 100.0 / e.total_electors AS turnout_ratio
FROM votes_2019 v, electors_2019 e;
```
Result💡: 67.71193
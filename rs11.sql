-- Distinct States in cons_2014 dataset
SELECT count(distinct state) from cons_2014;

-- Distinct States in cons_2019 dataset
SELECT count(distinct state) from cons_2019;

-- Increasing Session timeout
SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;
SET SESSION wait_timeout = 600;

-- States that are present in 2019 but not in 2014 dataset
SELECT DISTINCT c19.state FROM cons_2019 c19
LEFT JOIN cons_2014 c14 ON c19.state = c14.state
WHERE c14.state IS NULL
ORDER BY c19.state
LIMIT 1000;

-- Distinct pc_name in Telangana State
SELECT DISTINCT pc_name,state
FROM cons_2019
WHERE state = 'Telangana';

-- Distinct pc_name in Andhra State
SELECT DISTINCT pc_name,state
FROM cons_2014
WHERE state = 'Andhra Pradesh';

-- Updating pc_names of Telangana from 2019 dataset to 2014 dataset as it was bifurcated from andhra to telangana
UPDATE cons_2014 AS cr14
JOIN (
    SELECT DISTINCT pc_name
    FROM cons_2019
    WHERE state = 'Telangana'
) AS cr19_telangana ON cr14.pc_name = cr19_telangana.pc_name
SET cr14.state = 'Telangana'
WHERE cr14.state = 'Andhra Pradesh';

-- Distinct pc_name from 2014 dataset
SELECT DISTINCT pc_name FROM cons_2014;

-- Distinct pc_name from 2019 dataset
SELECT DISTINCT pc_name FROM cons_2019;

-- Data Cleaning
-- Trimmming the pc_name for both datasets
UPDATE cons_2019
SET pc_name = TRIM(pc_name);
UPDATE cons_2014
SET pc_name = TRIM(pc_name);

-- Converting to lower case 
UPDATE cons_2019
SET pc_name = LOWER(pc_name);
UPDATE cons_2014
SET pc_name = LOWER(pc_name);

-- Some pc_name has ' (sc)','-',' - ', so trim it. 
UPDATE cons_2019
SET pc_name = REPLACE(REPLACE(REPLACE(pc_name, ' (sc)', ''), ' - ', ' '), '-', ' ');
UPDATE cons_2014
SET pc_name = REPLACE(REPLACE(REPLACE(pc_name, ' (sc)', ''), ' - ', ' '), '-', ' ');

-- Check if all pc_name from 2014 are present in 2019
SELECT distinct c14.pc_name
FROM cons_2014 AS c14
LEFT JOIN cons_2019 AS c19 ON c14.pc_name = c19.pc_name
WHERE c19.pc_name IS NULL;

-- Updating misspelled pc_names
UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'chelvella', 'chevella')
WHERE pc_name = 'chelvella';

UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'joynagar', 'jaynagar')
WHERE pc_name = 'joynagar';

UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'burdwan durgapur', 'bardhaman durgapur')
WHERE pc_name = 'burdwan durgapur';

UPDATE cons_2014
SET pc_name = REPLACE(pc_name, 'dadar & nagar haveli', 'dadra and nagar haveli')
WHERE pc_name = 'dadar & nagar haveli';

/* age less than 25 */
SELECT * FROM cons_2014 WHERE age < 25;
SELECT * FROM cons_2019 WHERE age < 25;


-- some analysis constituency and state wise voter turnout ratio
-- Total Turnout ratio 2014
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

-- Total Turnout ratio 2019
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


/* constituency wise turnout ratio 2014 */
SELECT state,pc_name,
    SUM(total_votes) AS total_votes,
    MAX(total_electors) AS total_electors,
    ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2014
GROUP BY state,pc_name;

/*constituency wise turnout ratio 2019*/
SELECT state,pc_name,
    SUM(total_votes) AS total_votes,
    MAX(total_electors) AS total_electors,
    ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2019
GROUP BY state,pc_name;

/*state wise turnout ratio 2014*/
WITH electors_per_pc AS (
    SELECT state, pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2014
    GROUP BY state, pc_name
),
votes_per_state AS (
    SELECT state,
           SUM(general_votes) AS total_general_votes,
           SUM(postal_votes) AS total_postal_votes
    FROM cons_2014
    GROUP BY state
),
electors_per_state AS (
    SELECT state,
           SUM(total_electors_per_pc) AS total_electors
    FROM electors_per_pc
    GROUP BY state
)
SELECT v.state,
       v.total_general_votes + v.total_postal_votes AS total_votes,
       e.total_electors,
       (v.total_general_votes + v.total_postal_votes) * 100.0 / e.total_electors AS turnout_ratio
FROM votes_per_state v
JOIN electors_per_state e ON v.state = e.state;

/*state wise turnout ratio 2019*/
WITH electors_per_pc AS (
    SELECT state, pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2019
    GROUP BY state, pc_name
),
votes_per_state AS (
    SELECT state,
           SUM(general_votes) AS total_general_votes,
           SUM(postal_votes) AS total_postal_votes
    FROM cons_2019
    GROUP BY state
),
electors_per_state AS (
    SELECT state,
           SUM(total_electors_per_pc) AS total_electors
    FROM electors_per_pc
    GROUP BY state
)
SELECT v.state,
       v.total_general_votes + v.total_postal_votes AS total_votes,
       e.total_electors,
       (v.total_general_votes + v.total_postal_votes) * 100.0 / e.total_electors AS turnout_ratio
FROM votes_per_state v
JOIN electors_per_state e ON v.state = e.state;


-- q1
-- Top 5 constituencies of 2014
SELECT state,pc_name,
    ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2014
GROUP BY state,pc_name
ORDER BY turnout_ratio DESC
LIMIT 5;

-- Bottom 5 constituencies of 2014
SELECT state,pc_name,
    ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2014
GROUP BY state,pc_name
ORDER BY turnout_ratio ASC
LIMIT 5;

-- Top 5 constituencies of 2019
SELECT state,pc_name,
    ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2019
GROUP BY state,pc_name
ORDER BY turnout_ratio DESC
LIMIT 5;

-- Bottom 5 constituencies of 2019
SELECT state,pc_name,
    ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2019
GROUP BY
    state,pc_name
ORDER BY turnout_ratio ASC
LIMIT 5;

-- q2 
-- top 5 states  and bottom 5 states 2014
WITH electors_per_pc_2014 AS (
    SELECT state, pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2014
    GROUP BY state, pc_name
),
votes_per_state_2014 AS (
    SELECT state,
           SUM(general_votes) AS total_general_votes,
           SUM(postal_votes) AS total_postal_votes
    FROM cons_2014
    GROUP BY state
),
electors_per_state_2014 AS (
    SELECT state,
           SUM(total_electors_per_pc) AS total_electors
    FROM electors_per_pc_2014
    GROUP BY state
),
turnout_ratio_2014 AS (
    SELECT v.state,
           (v.total_general_votes + v.total_postal_votes) * 100.0 / e.total_electors AS turnout_ratio
    FROM votes_per_state_2014 v
    JOIN electors_per_state_2014 e ON v.state = e.state
)
SELECT * FROM turnout_ratio_2014
ORDER BY turnout_ratio DESC
LIMIT 5;

SELECT * FROM turnout_ratio_2014
ORDER BY turnout_ratio ASC
LIMIT 5;

-- top 5 states  and bottom 5 states 2019
WITH electors_per_pc_2019 AS (
    SELECT state, pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2019
    GROUP BY state, pc_name
),
votes_per_state_2019 AS (
    SELECT state,
           SUM(general_votes) AS total_general_votes,
           SUM(postal_votes) AS total_postal_votes
    FROM cons_2019
    GROUP BY state
),
electors_per_state_2019 AS (
    SELECT state,
           SUM(total_electors_per_pc) AS total_electors
    FROM electors_per_pc_2019
    GROUP BY state
),
turnout_ratio_2019 AS (
    SELECT v.state,
           (v.total_general_votes + v.total_postal_votes) * 100.0 / e.total_electors AS turnout_ratio
    FROM votes_per_state_2019 v
    JOIN electors_per_state_2019 e ON v.state = e.state
)
SELECT * FROM turnout_ratio_2019
ORDER BY turnout_ratio DESC
LIMIT 5;

SELECT * FROM turnout_ratio_2019
ORDER BY turnout_ratio ASC
LIMIT 5;

-- q3
-- Determine the winner for each constituency in 2014
WITH winners_2014 AS (
    SELECT state,pc_name,party AS winner_party_2014,total_votes AS winner_votes_2014,
        ROW_NUMBER() OVER (PARTITION BY state, pc_name ORDER BY total_votes DESC) AS rank_2014
    FROM cons_2014
),
-- Filter only the winners in 2014
filtered_winners_2014 AS (
    SELECT state,pc_name,winner_party_2014,winner_votes_2014
    FROM winners_2014
    WHERE rank_2014 = 1
),

-- Determine the winner for each constituency in 2019
winners_2019 AS (
    SELECT state,pc_name,party AS winner_party_2019,total_votes AS winner_votes_2019,
        (total_votes * 100.0 / SUM(total_votes) OVER (PARTITION BY state, pc_name)) AS winner_vote_pct_2019,
        ROW_NUMBER() OVER (PARTITION BY state, pc_name ORDER BY total_votes DESC) AS rank_2019
    FROM cons_2019
),
-- Filter only the winners in 2019
filtered_winners_2019 AS (
    SELECT state,pc_name,winner_party_2019,winner_votes_2019,winner_vote_pct_2019
    FROM winners_2019
    WHERE rank_2019 = 1
),

-- Identify constituencies that elected the same party in both elections
same_party_constituencies AS (
    SELECT w19.state,w19.pc_name,w19.winner_party_2019,w19.winner_vote_pct_2019
    FROM filtered_winners_2014 w14
    JOIN filtered_winners_2019 w19 
    ON w14.state = w19.state 
    AND w14.pc_name = w19.pc_name
    WHERE w14.winner_party_2014 = w19.winner_party_2019
)

-- Select and rank the constituencies by the percentage of votes to the winning party in 2019
SELECT pc_name,
    winner_party_2019 AS party,
    winner_vote_pct_2019 AS vote_percentage
FROM same_party_constituencies
ORDER BY vote_percentage DESC;




-- q4
-- Determine the winner for each constituency in 2014
WITH winners_2014 AS (
    SELECT state,pc_name,candidate AS winner_2014,party AS winner_party_2014,
        total_votes AS winner_votes_2014,
        (total_votes * 100.0 / SUM(total_votes) OVER (PARTITION BY state, pc_name)) AS winner_vote_pct_2014,
        ROW_NUMBER() OVER (PARTITION BY state, pc_name ORDER BY total_votes DESC) AS rank_2014
    FROM cons_2014
),
-- Filter only the winners
filtered_winners_2014 AS (
    SELECT state,pc_name,winner_party_2014,winner_votes_2014,winner_vote_pct_2014
    FROM winners_2014
    WHERE rank_2014 = 1
),

-- Determine the winner for each constituency in 2019
winners_2019 AS (
    SELECT state,pc_name,candidate AS winner_2019,party AS winner_party_2019,
        total_votes AS winner_votes_2019,
        (total_votes * 100.0 / SUM(total_votes) OVER (PARTITION BY state, pc_name)) AS winner_vote_pct_2019,
        ROW_NUMBER() OVER (PARTITION BY state, pc_name ORDER BY total_votes DESC) AS rank_2019
    FROM cons_2019
),
-- Filter only the winners
filtered_winners_2019 AS (
    SELECT state,pc_name,
        winner_party_2019,winner_votes_2019,winner_vote_pct_2019
    FROM winners_2019
    WHERE rank_2019 = 1
),

--  Identify constituencies that changed parties and calculate vote percentage difference
changed_constituencies AS (
    SELECT w14.pc_name,
        w14.winner_party_2014,w14.winner_vote_pct_2014,
        w19.winner_party_2019,w19.winner_vote_pct_2019,
        (w19.winner_vote_pct_2019 - w14.winner_vote_pct_2014) AS vote_pct_difference
    FROM filtered_winners_2014 w14
    JOIN filtered_winners_2019 w19 
    ON w14.state = w19.state 
    AND w14.pc_name = w19.pc_name
    WHERE w14.winner_party_2014 <> w19.winner_party_2019
)

-- Select the top 10 constituencies based on vote percentage difference
SELECT pc_name,winner_party_2014,winner_vote_pct_2014,
    winner_party_2019,winner_vote_pct_2019,vote_pct_difference
FROM changed_constituencies
ORDER BY vote_pct_difference DESC
LIMIT 10;

-- q5
-- 2014 dataset 
WITH ranked_candidates_2014 AS (
    SELECT pc_name,candidate,party,total_votes,
        ROW_NUMBER() OVER (PARTITION BY state, pc_name ORDER BY total_votes DESC) AS rank_no
    FROM cons_2014
),
margin_difference_2014 AS (
    SELECT rc1.pc_name,rc1.candidate AS winner,rc1.party AS winner_party,rc1.total_votes AS winner_votes, 
    rc2.candidate AS runner_up,rc2.party AS runner_up_party,rc2.total_votes AS runner_up_votes,
        (rc1.total_votes - rc2.total_votes) AS margin_difference
    FROM ranked_candidates_2014 rc1
    JOIN ranked_candidates_2014 rc2
    ON rc1.pc_name = rc2.pc_name
    WHERE rc1.rank_no = 1
    AND rc2.rank_no = 2
)
SELECT pc_name,winner,winner_party,winner_votes,runner_up,runner_up_party,runner_up_votes,margin_difference
FROM margin_difference_2014
ORDER BY margin_difference DESC
LIMIT 5;

-- 2019 dataset
WITH ranked_candidates_2019 AS (
    SELECT pc_name,candidate,party,total_votes,
        ROW_NUMBER() OVER (PARTITION BY state, pc_name ORDER BY total_votes DESC) AS rank_no
    FROM cons_2019
),
margin_difference_2019 AS (
    SELECT rc1.pc_name,rc1.candidate AS winner,rc1.party AS winner_party,rc1.total_votes AS winner_votes, 
    rc2.candidate AS runner_up,rc2.party AS runner_up_party,rc2.total_votes AS runner_up_votes,
        (rc1.total_votes - rc2.total_votes) AS margin_difference
    FROM ranked_candidates_2019 rc1
    JOIN ranked_candidates_2019 rc2
    ON rc1.pc_name = rc2.pc_name
    WHERE rc1.rank_no = 1
    AND rc2.rank_no = 2
)
SELECT pc_name,winner,winner_party,winner_votes,runner_up,runner_up_party,runner_up_votes,margin_difference
FROM margin_difference_2019
ORDER BY margin_difference DESC
LIMIT 5;


-- q6
-- Total votes for each party in 2014
WITH party_total_2014 AS (
    SELECT party, SUM(total_votes) AS total_votes_2014
    FROM cons_2014
    GROUP BY party
),
-- Total votes for each party in 2019
party_total_2019 AS (
    SELECT party, SUM(total_votes) AS total_votes_2019
    FROM cons_2019
    GROUP BY party
),
-- Merge the results for both years
merged AS (
    SELECT t14.party, total_votes_2014, total_votes_2019
    FROM party_total_2014 t14
    LEFT JOIN party_total_2019 t19 ON t14.party = t19.party
)
-- Calculate % share for each party in 2014 and 2019
SELECT party, total_votes_2014, total_votes_2019,
    ROUND((total_votes_2014 * 100.0) / SUM(total_votes_2014) OVER(), 2) AS share_2014,
    ROUND((total_votes_2019 * 100.0) / SUM(total_votes_2019) OVER(), 2) AS share_2019
FROM merged
ORDER BY total_votes_2014 DESC
LIMIT 10;


-- q7
-- Calculate vote percentage for each party in each state for 2014
WITH total_votes_per_state_2014 AS (
    SELECT state,SUM(total_votes) AS state_total_votes
    FROM cons_2014
    GROUP BY state
),
votes_per_party_2014 AS (
    SELECT state,party,SUM(total_votes) AS party_total_votes
    FROM cons_2014
    GROUP BY state,party
)
SELECT vps.state, vps.party,
    ROUND(vps.party_total_votes * 100.0 / tvs.state_total_votes, 2) AS vote_percentage
FROM votes_per_party_2014 vps
JOIN total_votes_per_state_2014 tvs
ON vps.state = tvs.state
ORDER BY vote_percentage DESC
LIMIT 5;


-- Calculate vote percentage for each party in each state for 2019
WITH total_votes_per_state_2019 AS (
    SELECT state,SUM(total_votes) AS state_total_votes
    FROM cons_2019
    GROUP BY state
),
votes_per_party_2019 AS (
    SELECT state,party,SUM(total_votes) AS party_total_votes
    FROM cons_2019
    GROUP BY state,party
)
SELECT vps.state,vps.party,
    ROUND(vps.party_total_votes * 100.0 / tvs.state_total_votes, 2) AS vote_percentage
FROM votes_per_party_2019 vps
JOIN total_votes_per_state_2019 tvs
ON vps.state = tvs.state
ORDER BY vote_percentage DESC
LIMIT 5;

-- q8 
-- Calculate vote shares for 2014
WITH vote_shares_2014 AS (
    SELECT state,pc_name,party,
        SUM(total_votes) AS total_votes_2014,
        SUM(total_votes) * 100.0 / SUM(SUM(total_votes)) OVER (PARTITION BY state, pc_name) AS vote_share_2014
    FROM cons_2014
    GROUP BY state,pc_name,party
),

-- Calculate vote shares for 2019
vote_shares_2019 AS (
    SELECT state,pc_name,party,SUM(total_votes) AS total_votes_2019,
        SUM(total_votes) * 100.0 / SUM(SUM(total_votes)) OVER (PARTITION BY state, pc_name) AS vote_share_2019
    FROM cons_2019
    GROUP BY state,pc_name,party
),

-- Calculate the change in vote share between 2014 and 2019
vote_share_changes AS (
    SELECT v14.state,v14.pc_name,v14.party,v14.vote_share_2014,v19.vote_share_2019,
    v19.vote_share_2019 - v14.vote_share_2014 AS vote_share_change
    FROM vote_shares_2014 v14
    JOIN vote_shares_2019 v19
    ON v14.state = v19.state AND v14.pc_name = v19.pc_name AND v14.party = v19.party
)

-- Select the top 5 constituencies with the highest gains in vote share for BJP
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'BJP'
ORDER BY vote_share_change DESC
LIMIT 5;


-- Select the top 5 constituencies with the highest gains in vote share for INC
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'INC'
ORDER BY vote_share_change DESC
LIMIT 5;

-- q9
-- same cte as above just finding least vote share which means ordering by asc
-- Select the top 5 constituencies where they lost vote share for BJP in 2019
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'BJP'
ORDER BY vote_share_change ASC
LIMIT 5;

-- Select the top 5 constituencies where they lost vote share for INC in 2019
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'INC'
ORDER BY vote_share_change ASC
LIMIT 5;

-- q10
-- 2014 highest nota Constituency 
-- Create a CTE to filter NOTA votes
WITH nota_votes AS (
    SELECT state, pc_name, total_votes AS nota_votes
    FROM cons_2014
    WHERE party = 'NOTA'
),
-- Create a CTE to calculate the total votes per constituency
total_votes_per_pc AS (
    SELECT state, pc_name, SUM(total_votes) AS total_votes
    FROM cons_2014
    GROUP BY state, pc_name
),
-- Calculate the NOTA vote share percentage
nota_vote_share AS (
    SELECT n.state,n.pc_name,n.nota_votes * 100.0 / t.total_votes AS nota_vote_percent
    FROM nota_votes n
    JOIN total_votes_per_pc t 
    ON n.state = t.state AND n.pc_name = t.pc_name
)
-- Select the top 1 constituencies with the highest NOTA vote share percentage
SELECT state,pc_name,ROUND(nota_vote_percent, 2) AS nota_vote_percent
FROM nota_vote_share
ORDER BY nota_vote_percent DESC
LIMIT 1;


-- 2019 highest nota Constituency
-- Create a CTE to filter NOTA votes
WITH nota_votes AS (
    SELECT state, pc_name, total_votes AS nota_votes
    FROM cons_2019
    WHERE party = 'NOTA'
),
-- Create a CTE to calculate the total votes per constituency
total_votes_per_pc AS (
    SELECT state, pc_name, SUM(total_votes) AS total_votes
    FROM cons_2019
    GROUP BY state, pc_name
),
-- Calculate the NOTA vote share percentage
nota_vote_share AS (
    SELECT n.state,n.pc_name,n.nota_votes * 100.0 / t.total_votes AS nota_vote_percent
    FROM nota_votes n
    JOIN total_votes_per_pc t 
    ON n.state = t.state AND n.pc_name = t.pc_name
)
-- Select the top 1 constituencies with the highest NOTA vote share percentage
SELECT state,pc_name,ROUND(nota_vote_percent, 2) AS nota_vote_percent
FROM nota_vote_share
ORDER BY nota_vote_percent DESC
LIMIT 1;


-- q11
-- Calculate total votes by state and party, and total votes per state
WITH state_party_total AS (
    SELECT r.state,r.party,SUM(r.total_votes) AS party_total_votes,
        SUM(SUM(r.total_votes)) OVER (PARTITION BY r.state) AS state_total_votes
    FROM cons_2019 r
    GROUP BY r.state, r.party
),

-- Calculate party's vote share percentage in each state
party_state_share AS (
    SELECT state,party,party_total_votes,state_total_votes,
        ROUND(party_total_votes * 100.0 / state_total_votes, 2) AS party_state_percent
    FROM state_party_total
),

-- Merge party share percentage with constituency-wise result and identify the winning candidates
winning_candidates AS (
    SELECT r.state,r.pc_name,r.candidate,r.party,pss.party_state_percent,
        ROW_NUMBER() OVER (PARTITION BY r.pc_name ORDER BY r.total_votes DESC) AS rank_no
    FROM cons_2019 r
    JOIN party_state_share pss ON r.state = pss.state AND r.party = pss.party
)

-- Select winning candidates with party's state-level vote share less than 10%
SELECT state,pc_name,candidate,party,party_state_percent
FROM winning_candidates
WHERE rank_no = 1 AND party_state_percent < 10
ORDER BY party_state_percent;
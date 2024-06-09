## Primary Questions
### Q1. List top 5/ bottom 5 constituencies of 2014 and 2019 in terms of voter turnout ratio.
* Top 5 constituencies of 2014
```sql
SELECT state,pc_name,
ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2014
GROUP BY state,pc_name
ORDER BY turnout_ratio DESC
LIMIT 5;
```
Result💡:

![q1-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/ab5c0309-e675-4fc6-9895-dccb57b93332)

* Bottom 5 constituencies of 2014
```sql
SELECT state,pc_name,
ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2014
GROUP BY state,pc_name
ORDER BY turnout_ratio ASC
LIMIT 5;
```
Result💡:

![q1-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/3b160e25-7d60-40f5-8f2f-4c0d6ab075de)

* Top 5 constituencies of 2019
```sql
SELECT state,pc_name,
ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2019
GROUP BY state,pc_name
ORDER BY turnout_ratio DESC
LIMIT 5;
```
Result💡:

![q1-3](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/592c6ace-9618-4bea-8f75-17802381510e)

* Bottom 5 constituencies of 2019
```sql
SELECT state,pc_name,
ROUND(SUM(total_votes) * 100.0 / MAX(total_electors), 2) AS turnout_ratio
FROM cons_2019
GROUP BY state,pc_name
ORDER BY turnout_ratio ASC
LIMIT 5;
```
Result💡:

![q1-4](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/f0c1fa7e-31eb-46d1-8091-8d27410964b2)

### Q2. List top 5/ bottom 5 states of 2014 and 2019 in terms of voter turnout ratio.
* Top 5 states for 2014
```sql
WITH electors_per_pc_2014 AS (
    SELECT state, pc_name, MAX(total_electors) AS total_electors_per_pc
    FROM cons_2014
    GROUP BY state, pc_name
),
votes_per_state_2014 AS (
    SELECT state,SUM(general_votes) AS total_general_votes,
    SUM(postal_votes) AS total_postal_votes
    FROM cons_2014
    GROUP BY state
),
electors_per_state_2014 AS (
    SELECT state,SUM(total_electors_per_pc) AS total_electors
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
```
Result💡:

![q2-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/6560df1f-d8c1-4b84-978e-9cabd240c2c6)

* Bottom 5 States for 2014.

Note : Select the same cte from above Query and order by ASC to find the Bottom 5 States for 2014.
```sql
SELECT * FROM turnout_ratio_2014
ORDER BY turnout_ratio ASC
LIMIT 5;
```
Result💡:

![q2-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/3bd04069-440d-4bf6-8e71-37fe2b321a88)


* Top 5 states for 2019
```sql
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
```
Result💡:

![q2-3](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/9fd0eec3-4d56-436b-841d-b3a36ee7ef72)

*  Bottom 5 States for 2019.

Note : Select the same cte from above Query and order by ASC to find the Bottom 5 States for 2019.
```sql
SELECT * FROM turnout_ratio_2019
ORDER BY turnout_ratio ASC
LIMIT 5;
```
Result💡:

![q2-4](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/30707b35-6aac-4d34-84de-ea1bb2fbd899)

### Q3. Which constituencies have elected the same party for 2 consecutive elections, rank them by % of votes to that winning party in 2019.
```sql
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
```
Result💡: There are a total of 336 Constituencies.

![q3-0](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/a3267f70-fdb6-4de8-b1c8-2802ee3b88cf)

### Q4. Which constituencies have voted for different parties in two elections (list top 10 based on difference (2019-2014) in winner vote percentage in two elections).
```sql
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
    SELECT state,pc_name,winner_party_2019,winner_votes_2019,winner_vote_pct_2019
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
```
Result💡:

![q4-0](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/90c9fdac-a2b5-4396-bfd3-865c4dfe9ec8)


### Q5. Top 5 candidates based on margin difference with runners in 2014 and 2019
```sql
-- Top 5 Candidates for 2014 dataset 
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
``` 
Result💡:

![q5-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/64da79bb-3ff8-4a1f-9638-25c761074004)


```sql
-- Top 5 Candidates for 2019 dataset
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
```
Result💡:

![q5-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/1cda91f7-be7e-430b-87fb-b8d392d97d13)

### Q6. % split of votes of parties between 2014 vs 2019 at national level
```sql
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
```
Result💡:

![q6-0](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/3a6da319-30dd-4c07-8bad-ce04d8be36dc)

### Q7. % split of votes of parties between 2014 vs 2019 at state level
```sql
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
```
Result💡:

![q7-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/58b97210-3d61-479f-845b-74211c100f06)

```sql
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
```
Result💡:

![q7-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/2e93bab4-8ebe-4eb9-8b0a-4cd68313ba58)


### Q8. List top 5 constituencies for two major national parties where they have gained vote share in 2019 as compared to 2014
* Note : From Question 6, We observed that BJP and INC are two major National Parties. So, let's Consider them for analysis.
```sql
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
```
Result💡:

![q8-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/32514004-da88-450c-922c-aede37cb3910)

* Note : Select the same cte from above Query and Change the Party name to INC 
```sql
-- Select the top 5 constituencies with the highest gains in vote share for INC
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'INC'
ORDER BY vote_share_change DESC
LIMIT 5;
```
Result💡:

![q8-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/2b2e4c5f-9e68-4e05-aaf7-0aeb9efc238e)

### Q9. List top 5 constituencies for two major national parties where they have lost vote share in 2019 as compared to 2014
* Note : Same cte as above just finding least vote share which means Order by ASC
```sql
-- Select the top 5 constituencies where they lost vote share for BJP in 2019
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'BJP'
ORDER BY vote_share_change ASC
LIMIT 5;
```
Result :

![q9-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/1a650701-e664-4a8b-b87b-c3b71fc794bd)

```sql
-- Select the top 5 constituencies where they lost vote share for INC in 2019
SELECT state,pc_name,vote_share_2014,vote_share_2019,vote_share_change
FROM vote_share_changes
WHERE party = 'INC'
ORDER BY vote_share_change ASC
LIMIT 5;
```
Result💡:

![q9-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/74deb82e-8e7a-45aa-bc11-86772e8b4695)

### Q10. Which constituency has voted the most for nota?
* 2014 Highest Nota Constituency 
```sql
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
```
Result💡:

![q10-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/6bbf3e71-dacd-493a-8dea-fbc263d868ab)

* 2019 Highest Nota Constituency
```sql
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
```
Result💡:

![q10-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/935109fb-c270-4395-90d8-1003eb5cb3f0)

### Q11. Which constituencies have elected candidates whose party has less than 10% vote share at state level in 2019.
```sql
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
```
Result💡:

![q11-0](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/034b81da-d65f-4937-9943-f7baac67cc65)

## Secondary Questions
### Q1. Is there a correlation between postal votes % and voter turnout %?
![rcq2-1](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/0db7a74b-abc9-4a74-877b-81f84a8caa24)

Observation🔍: There is no Correlation since the scatter plot does not produce a lower-left-to-upper-right pattern(lowest point of x-axis to highest point of y-axis)

![rcq2-2](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/ef9477a2-4db8-4e8a-933b-aa244cf514c0)

Observation🔍: There is no Correlation since the scatter plot does not produce a lower-left-to-upper-right pattern(lowest point of x-axis to highest point of y-axis)

### Q2. Is there any correlation between literacy % of a state and voter turnout %?
* Extracted the Literacy % from : 
https://en.wikipedia.org/wiki/List_of_Indian_states_and_union_territories_by_literacy_rate

![rcq3](https://github.com/Charitha-AO/Lok_Sabha_Elections_Analysis/assets/86000133/9fcadef3-3a9b-4515-acd1-9e6ae0da971f)

Observation🔍: There is a weak Correlation between literacy rate and voter turnout ratio

### Q3. Provide 3 recommendations on what the election commission/ government can do to increase the voter turnout %
1. ***Increase Voter Awareness and Participation***

**Low Turnout Areas**: Focus on constituencies with consistently low voter turnout to understand the reasons and implement targeted voter awareness campaigns.

**Postal Voting**: Encourage postal voting in regions where it has shown significant uptake, potentially simplifying the process or providing more information about its availability and benefits.

2. ***Engage Youth and First-Time Voters***

**Youth Engagement**: Develop programs and initiatives to engage young voters and first-time voters. Use social media and digital platforms to reach and educate them about the importance of voting.

**Educational Campaigns**: Conduct educational campaigns in schools, colleges, and universities to foster a culture of voting and civic participation among the youth.

3. ***Improve Electoral Process and Experience***

**Electoral Process Improvements**: Based on feedback and data, consider improving the voting process, such as reducing waiting times, increasing the number of polling stations, or enhancing accessibility for disabled and elderly voters.

**Voter Experience**: Enhance voter experience by providing better information about candidates and their policies, ensuring transparency and fairness in the electoral process.

4. ***Address Regions with High NOTA Votes***

**Constituencies with High NOTA Votes**: Investigate the reasons behind high NOTA votes in certain constituencies. This might indicate voter dissatisfaction with the available candidates or parties. Conduct surveys or focus groups to understand the underlying issues and address them.








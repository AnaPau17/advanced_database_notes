-- ============================================================
-- Lesson 03 — Indexes: Class Exercises
-- Work through these before looking at the hints
-- ============================================================

-- ============================================================
-- Exercise 1 — Find the slow query
--
-- Run this query. Look at the execution plan.
-- Is Oracle using an index? Should it?
-- ============================================================

SELECT * FROM patient_visits WHERE site_id = 3;

-- Questions:
-- a) What scan type do you see? Why?
-- The scan type is a TABLE FULL SCAN, because Oracle reads the whole table instead of using an index, because site_id has very few possible values, so many rows match the condition.

-- b) site_id has values 1–5. Is this high or low cardinality?
-- Is low cardinality, because there are only 5 possible values, each value appears many times in the table.

-- c) Would adding an index on site_id help? Why or why not?
-- No, an index would not help much because too many rows match, and Oracle still has to read most of the table, so a full scan is faster.

-- ============================================================
-- Exercise 2 — Create an index and see if it helps
--
-- Create an index on visit_date.
-- Then run the range query below and check the plan.
-- ============================================================

-- Step 1: Create it
-- (write the CREATE INDEX statement here)
CREATE INDEX idx_pv_visit_date ON patient_visits(visit_date);


-- Step 2: Gather stats
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

-- Step 3: Run the range query and check the plan
SELECT * FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

-- Questions:
-- a) Does Oracle use the index for this range? 
-- Yes, Oracle uses the index because the range is small and returns few rows.

-- b) Change the range to the last 7 days. Does the plan change?
-- Yes, the index is used even more because fewer rows are returned.

-- c) Change to the last 700 days. What happens?
-- Oracle reads most of the table, so it may use a full table scan instead of the index because too many rows match the range.

-- d) Why does the range size affect whether Oracle uses the index?
-- Because small ranges return few rows so index is faster, but big ranges return many rows so full scan is faster.

-- ============================================================
-- Exercise 3 — Composite index
--
-- You often query by both patient_id AND visit_date together:
--   WHERE patient_id = 1234 AND visit_date > SYSDATE - 90
--
-- Two options:
--   Option A: Two separate indexes (one per column)
--   Option B: One composite index (patient_id, visit_date)
--
-- Create the composite index and test the query.
-- ============================================================

CREATE INDEX idx_pv_patient_date ON patient_visits(patient_id, visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

SELECT * FROM patient_visits
WHERE patient_id = 1234
  AND visit_date > SYSDATE - 90;

-- Questions:
-- a) Does the plan use the composite index?
-- Yes, Oracle uses the composite index because the query uses patient_id and visit_date together.

-- b) Now try querying ONLY on visit_date (no patient_id).
--    Does the composite index get used? Why not?
-- No, it is not used because the index starts with patient_id, and the query only uses visit_date, and Oracle cannot use the index without the first column.

-- c) What's the rule about column order in composite indexes?
-- The index only works well if you start with the first column (left to right rule).

SELECT * FROM patient_visits WHERE patient_id = 1234;

-- Trailing column only (index cannot be used from the middle):
SELECT * FROM patient_visits WHERE visit_date > SYSDATE - 90;

-- ============================================================
-- Exercise 4 — Function that breaks an index
--
-- There IS an index on patient_id (from lesson 03).
-- Predict what happens when you wrap the column in a function.
-- ============================================================

-- This query CAN use the index:
SELECT * FROM patient_visits WHERE patient_id = 5432;
-- This one cannot — why?
SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';

-- Questions:
-- a) What scan type did the second query use?
-- It uses a TABLE FULL SCAN because Oracle cannot use the index when a function is applied to the column, so it must read every row in the table to find matching values.

-- b) Why does wrapping a column in a function break index use?
-- Because the function changes the column value, so Oracle cannot use the original index on patient_id.

-- c) How would you rewrite the second query to allow index use?
-- I could remove the function and write it directly: WHERE patient_id = 5432.

-- ============================================================
-- Exercise 5 — Discussion: real-world scenarios
--
-- For each scenario below, decide:
--   a) Would you add an index?
--   b) On which column(s)?
--   c) Any concerns?
-- ============================================================

-- Scenario A:
-- A reporting table gets loaded once per night (batch ETL).
-- During the day, analysts run SELECT queries by date range.
-- The table has 50 million rows.
-- → Index on date? Yes/No, why? Yes, because queries filter by date ranges and an index on the date column helps find rows faster in a large table.
--   a) Would you add an index? Yes, I would add an index.
--   b) On which column(s)? On the date column.
--   c) Any concerns? inserts and updates may become slower because the table is very large.


-- Scenario B:
-- An OLTP orders table gets 10,000 inserts per minute.
-- Support staff look up orders by customer_id or order_status.
-- order_status has 4 values: pending, processing, shipped, cancelled.
-- → What indexes would you add? On customer_id, and maybe a composite index on customer_id and order_status.
--   a) Would you add an index? Yes, I would add indexes.
--   b) On which column(s)? On customer_id, and maybe a composite index on customer_id and order_status.
--   c) Any concerns? many inserts (10,000 per minute) can become slower because indexes must be updated every time.


-- Scenario C:
-- A patient table has an email column (unique per patient).
-- There are 5 million patients.
-- The app frequently does: WHERE email = 'user@example.com'
-- → What kind of index would be best here? A unique index on the email column because each email is different and the query searches for exact matches.
--   a) Would you add an index? Yes, I would add an index.
--   b) On which column(s)? On the email column.
--   c) Any concerns? inserts and updates may be slightly slower because of the index.

-- ============================================================
-- Cleanup — remove indexes created in these exercises
-- ============================================================
DROP INDEX idx_pv_patient_date;
-- If you created an index on visit_date in Exercise 2, drop it here:
-- DROP INDEX idx_pv_visit_date;
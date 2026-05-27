# Lesson 08: Exercise — Assignment History

A support ticketing system. Tickets get reassigned between agents. You need
to track who was assigned when the ticket was created vs when it was resolved.

---

## Step 1 — Source Tables (OLTP)

Create two tables:

**`tickets`** — current state of each ticket. Needs:
- ticket_id, title, status, priority, created_at, resolved_at, assigned_to

**`ticket_assignments`** — history of who was assigned when. Needs:
- assignment_id, ticket_id, assigned_to, assigned_by, valid_from, valid_to

```sql
-- Clean up
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ticket_assignments'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tickets'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- tickets
CREATE TABLE tickets (
    ticket_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title         VARCHAR2(200) NOT NULL,
    status        VARCHAR2(20) NOT NULL,
    priority      VARCHAR2(10) NOT NULL,
    created_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    resolved_at   TIMESTAMP,
    assigned_to   NUMBER
);

-- ticket_assignments
CREATE TABLE ticket_assignments (
    assignment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     NUMBER NOT NULL,
    assigned_to   NUMBER NOT NULL,
    assigned_by   NUMBER,
    valid_from    TIMESTAMP NOT NULL,
    valid_to      TIMESTAMP
);
```

---

## Step 2 — Sample Data

Insert at least 5 tickets. Make sure at least one gets reassigned (different
person in `ticket_assignments` than the current `assigned_to` in `tickets`).

```sql
-- Insert tickets
INSERT INTO tickets
(title, status, priority, created_at, resolved_at, assigned_to)
VALUES
('Login issue', 'completed', 'high',
 TIMESTAMP '2026-05-01 09:00:00',
 TIMESTAMP '2026-05-02 15:00:00',
 1);

INSERT INTO tickets
(title, status, priority, created_at, resolved_at, assigned_to)
VALUES
('Email not working', 'completed', 'medium',
 TIMESTAMP '2026-05-03 10:00:00',
 TIMESTAMP '2026-05-04 14:00:00',
 2);

INSERT INTO tickets
(title, status, priority, created_at, resolved_at, assigned_to)
VALUES
('Slow dashboard', 'in_progress', 'high',
 TIMESTAMP '2026-05-05 11:00:00',
 NULL,
 3);

INSERT INTO tickets
(title, status, priority, created_at, resolved_at, assigned_to)
VALUES
('Password reset bug', 'completed', 'critical',
 TIMESTAMP '2026-05-06 09:00:00',
 TIMESTAMP '2026-05-07 13:00:00',
 1);

INSERT INTO tickets
(title, status, priority, created_at, resolved_at, assigned_to)
VALUES
('Mobile layout issue', 'open', 'low',
 TIMESTAMP '2026-05-07 10:00:00',
 NULL,
 2);

COMMIT;
```

---

## Step 3 — Trigger

Write a trigger on `tickets` that:
- On INSERT or UPDATE of `assigned_to`, logs the change to `ticket_assignments`
- Closes the previous active assignment (sets its `valid_to`)
- Inserts a new row with `valid_from = now()` and `valid_to = NULL`

```sql
CREATE OR REPLACE TRIGGER trg_ticket_assignment
AFTER INSERT OR UPDATE OF assigned_to ON tickets
FOR EACH ROW
BEGIN

    -- INSERT
    IF INSERTING THEN

        INSERT INTO ticket_assignments
        (ticket_id, assigned_to, assigned_by, valid_from)
        VALUES
        (:NEW.ticket_id,
         :NEW.assigned_to,
         NULL,
         :NEW.created_at);

    -- UPDATE
    ELSIF UPDATING THEN

        -- close old assignment
        UPDATE ticket_assignments
        SET valid_to = SYSTIMESTAMP
        WHERE ticket_id = :OLD.ticket_id
          AND valid_to IS NULL;

        -- insert new assignment
        INSERT INTO ticket_assignments
        (ticket_id, assigned_to, assigned_by, valid_from)
        VALUES
        (:NEW.ticket_id,
         :NEW.assigned_to,
         NULL,
         SYSTIMESTAMP);

    END IF;

END;
/
```

**Test it:** Reassign a ticket, then query `ticket_assignments` to confirm
both the old and new assignment are recorded.

```sql
-- reassign ticket 2 from agent 2 to agent 3
UPDATE tickets
SET assigned_to = 3
WHERE ticket_id = 2;

COMMIT;

-- check the assignment history
SELECT *
FROM ticket_assignments
WHERE ticket_id = 2
ORDER BY valid_from;
```
---

## Step 4 — Data Warehouse Tables (Star Schema)

Create two tables:

**`dim_agent`** — agent details. Needs: agent_key, agent_name, team

**`fact_ticket_daily`** — daily counts per agent/status/priority. Needs:
date_key, agent_key, status, priority, tickets_created, tickets_resolved

```sql
-- Clean up
BEGIN EXECUTE IMMEDIATE 'DROP TABLE fact_ticket_daily'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dim_agent'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- dim_agent
CREATE TABLE dim_agent (
    agent_key    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_name   VARCHAR2(100),
    team         VARCHAR2(50)
);

-- fact_ticket_daily
CREATE TABLE fact_ticket_daily (
    fact_key            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_key            NUMBER,
    agent_key           NUMBER,
    status              VARCHAR2(20),
    priority            VARCHAR2(10),
    tickets_created     NUMBER,
    tickets_resolved    NUMBER
);
```

---

## Step 5 — Populate dim_agent

Insert 3-4 agents with their teams.

```sql
INSERT INTO dim_agent (agent_name, team)
VALUES ('Nacho', 'Support');

INSERT INTO dim_agent (agent_name, team)
VALUES ('Ana', 'Support');

INSERT INTO dim_agent (agent_name, team)
VALUES ('Balta', 'Technical');

INSERT INTO dim_agent (agent_name, team)
VALUES ('Jozef', 'Technical');

COMMIT;
```

---

## Step 6 — ETL Logic (Colab)

In your Colab notebook, write pandas code that:
1. Extracts `tickets` and `ticket_assignments` from FreeSQL
2. For each ticket, finds who was assigned at `created_at` using:
   `valid_from <= created_at AND (valid_to IS NULL OR valid_to > created_at)`
3. Same for `resolved_at`
4. Groups by date, agent, status, priority and counts
5. Inserts into `fact_ticket_daily`

---

## Step 7 — Verify

Write a query joining `fact_ticket_daily` and `dim_agent` to show tickets
created and resolved per agent per day. The reassigned ticket should show
the original agent for creation and the new agent for resolution.

```sql
SELECT
    f.date_key,
    d.agent_name,
    d.team,
    f.status,
    f.priority,
    f.tickets_created,
    f.tickets_resolved
FROM fact_ticket_daily f
JOIN dim_agent d
    ON f.agent_key = d.agent_key
ORDER BY f.date_key, d.agent_name;
```
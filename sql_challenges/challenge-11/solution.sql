---

# Lesson Exercises

---

# Exercise 1 — Model Design (10 min)

## Scenario

Your task system needs a `comments` table.

Each comment belongs to:
- one task
- one user

---

## Task

Create a new Colab cell and write the `Comment` model.

### Required Fields

- `id`
- `task_id`
- `user_id`
- `content`
- `created_at`


from sqlalchemy import Column, Integer, ForeignKey, Text, DateTime, func
from sqlalchemy.orm import relationship
from base import Base  # your declarative base

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(Integer, ForeignKey("tasks.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now())

    # relationships
    task = relationship("Task", back_populates="comments")
    user = relationship("User", back_populates="comments")


---


## Questions

1. What relationships should `Comment` have?
A Comment is connected to one Task and one User, this means each comment belongs to a task and a user, but a task and a user can have 
many comments.

2. Should `Task` have a `comments` relationship?
Yes, Task should have a comments relationship so it can see all its comments.

3. What should happen to comments when a task is deleted?
If a task is deleted, its comments should also be deleted so nothing is left without a task.

---

# Exercise 2 — Migration Creation (10 min)

## Scenario

You added the `Comment` model.

Now generate a migration programmatically.

---

## Task

Run:

```python
command.revision(
    alembic_cfg,
    autogenerate=True,
    message="add comments table"
)
```

---

## Then Inspect the Migration

```python
import glob

migration_files = sorted(
    glob.glob('/content/project/alembic/versions/*.py')
)

for f in migration_files:
    print(f)
```

---

## Open the Generated Migration

```python
latest = migration_files[-1]

with open(latest) as f:
    print(f.read())
```

---

## Questions

1. What does `upgrade()` do?
upgrade() means adding changes to the database, like new tables or columns.

2. What does `downgrade()` do?
downgrade() means removing those changes.

3. What happens if you downgrade this migration?
The new table or column is removed and the data is lost.


---

## Bonus

Add a CHECK constraint so `content != ''`

op.create_check_constraint(
    "ck_comments_content_not_empty",
    "comments",
    "content <> ''"
)

This makes sure that the content field cannot be empty, so users must write something.

---

# Exercise 3 — CRUD Challenge (10 min)

## Scenario

Write a script that:

1. Creates a team called `"DevOps"`
2. Creates a user `"diana_ops"`
3. Creates 3 tasks with different priorities
4. Prints task count
5. Closes one task
6. Deletes the lowest priority task

---

## Requirements

- Use ORM only
- Use relationships
- Print output clearly
---
from sqlalchemy.orm import Session

session = Session(engine)


# 1. Create team
devops = Team(name="DevOps", description="DevOps team")
session.add(devops)
session.commit()

print("Team created:", devops.name)

# 2. Create user
diana = User(
    username="diana_ops",
    email="diana@example.com",
    full_name="Diana Ops",
    team_id=devops.id
)

session.add(diana)
session.commit()

print("User created:", diana.username)

# 3. Create 3 tasks (different priorities using status as example)
t1 = Task(title="High priority task", status="high", assigned_to=diana.id)
t2 = Task(title="Medium priority task", status="medium", assigned_to=diana.id)
t3 = Task(title="Low priority task", status="low", assigned_to=diana.id)

session.add_all([t1, t2, t3])
session.commit()

print("3 tasks created")

# 4. Print task count
task_count = session.query(Task).count()
print("Total tasks:", task_count)

# 5. Close one task
task_to_close = session.query(Task).filter_by(title="High priority task").first()
task_to_close.status = "closed"
session.commit()

print("Task closed:", task_to_close.title)

# 6. Delete lowest priority task
low_task = session.query(Task).filter_by(status="low").first()

session.delete(low_task)
session.commit()

print("Deleted lowest priority task:", low_task.title)



---


# Exercise 4 — Migration Rollback (5 min)

## Scenario

You added a bad column:
`estimated_hours`

The migration has already been applied.

---

## Task

Rollback the migration programmatically.

### Example

```python
command.downgrade(alembic_cfg, "-1")
```

---

## Questions

1. What happens to the column?
Collback removes the new column estimated_hours.

2. What happens to the data?
The database goes back to the old version, and the data in that column is also deleted.

---

# Exercise 5 — Concept Check (5 min)

Answer briefly:

1. Why use ORM instead of raw SQL?
ORM is easier to use, we write Python code instead of SQL, and it also reduces mistakes and makes code cleaner.

2. Why use migrations?
Migrations help us track changes in our database over time, they also let teams work together safely without breaking the database.

3. When would you rollback?
When something is wrong, like a bug or a bad change that breaks the database.

4. Difference between `add()` and `commit()`?
add() puts data into the session (prepares it), commit() saves the data into the database permanently.

5. Why are relationships useful?
Relationships connect tables together, they make it easy to get related data without writing complex SQL queries.

---

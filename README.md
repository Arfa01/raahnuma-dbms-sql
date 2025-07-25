# Raahnuma – University & Program Guidance System

Raahnuma is a full-stack university admission guidance platform designed to help students explore, filter, and compare degree programs offered across Pakistani universities. It combines SQL Server backend complete with views, triggers, and stored procedures with a dynamic, interactive frontend built in Python using Streamlit.

---

## Tech Stack

| Layer     | Technologies |
|-----------|--------------|
| Frontend  | Python, Streamlit, Plotly, Pandas |
| Backend   | Microsoft SQL Server, T-SQL |
| Connector | pyodbc / mysql-connector |
| DB Concepts | Normalization (3NF), Indexing, Views, Stored Procedures, Triggers, History Tables |

---

## Key Features

### Backend – SQL Server & T-SQL
- **14+ normalized tables** for universities, programs, eligibility, fees, deadlines, favorites, chat logs, and audit history
- **10+ stored procedures** for: Searching and filtering programs, Saving favorites, Calculating fee structures, Admin workflows etc.
- **4 custom triggers** for: Archiving deleted programs, Logging fee changes, Tracking user activity, Notifying users of program updates
- **Materialized view simulation** for analytics (e.g., program counts by university)
- **Indexes** for faster filtering and lookup
- **Sample data** for testing and evaluation

### Frontend – Python + Streamlit
- **Sidebar navigation**: Dashboard, Program Search, Fee Calculator, Eligibility Criteria, Chat Groups, Analytics
- **Live filters** for degree type, city, tuition, field, etc.
- **Pandas-backed dynamic tables and queries**
- **Plotly-based charts**: bar graphs, pie charts, and KPI summaries
- **Session-state storage & Notifications** for saved favorites and messages
- **UI screens** for public browsing


## Folder Structure

raahnuma-dbms/
├── raahnuma.py # Python frontend
├── database/
├── assets/
│ └── screenshots.png

---

## Academic Context

This project was built as a final evaluation for the **Database Systems** course at COMSATS University Lahore, with an emphasis on integrating relational modeling, database programming, and real-time UI interaction.

---


## Future Enhancements

- User authentication (login/registration)
- Admin interface for university staff and alumni
- Backend migration to PostgreSQL
- Deployment as a hosted web app via Streamlit Cloud or Heroku

## Copyright & Usage

This project and its concept are original work by **Arfa Riaz**.  
Please do not copy, redistribute, or adapt without explicit permission.  
For educational use only.


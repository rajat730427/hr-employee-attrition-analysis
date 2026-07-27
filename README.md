# HR Employee Attrition Analysis

## 📌 Project Overview
This project analyzes employee attrition data for 1,470 employees to understand which
departments, roles, and work conditions are driving people to leave the company. The
dataset was explored and cleaned in Python before building analytical queries in SQL
and an interactive dashboard in Power BI.

## 🛠️ Tools Used
- **Python (Pandas, Matplotlib, Seaborn)** – Exploratory data analysis and visualization
- **SQL (MySQL)** – Business insight queries and window functions
- **Power BI** – Interactive dashboard for attrition trend and driver analysis

## 📂 Project Files
- `HR_Employee_Attrition_Analysis.ipynb` → Python notebook (EDA & visualizations)
- `HR_Employee_Attrition.csv` → Dataset (1,470 records)
- `hr_attrition_queries.sql` → 10 SQL queries (MySQL)
- `HR-attrition.pbix` → Power BI dashboard

## 📊 Exploratory Analysis (Python)
Explored the dataset across key dimensions, including:
- Employee demographics (age, gender, marital status)
- Department and job role breakdowns
- Salary distribution
- Attrition patterns by department, role, and satisfaction level

## 🗄️ SQL Analysis
10 queries covering:
- Department and overtime breakdowns
- Average salary company-wide and by department
- Top 10 highest-paid employees
- Long-tenured employees (10+ years)
- Salary ranking within each department (`RANK()` window function)
- Department-wise attrition rate

## 📉 Power BI Dashboard
Built an interactive dashboard with KPI cards (total employees, attrition count,
attrition rate, average age, average salary) and attrition rate breakdowns by
department, job role, education field, overtime, and job satisfaction.

## 🔑 Key Findings
- Overall attrition rate: **14.69%**
- **Human Resources** department has the highest attrition rate (~21%)
- Employees who work **overtime** leave at a much higher rate
- **Lower job satisfaction** is directly linked to higher attrition

## 📁 Data Source
[IBM HR Analytics Employee Attrition Dataset](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)

## 👤 Author
Rajat Yadav

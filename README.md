# HR Employee Attrition Analysis & AI Assistant

## 📌 Project Overview
This project analyzes employee attrition data for 1,470 employees to understand which
departments, roles, and work conditions are driving people to leave the company. The
dataset was explored and cleaned in Python before building analytical queries in SQL
and an interactive dashboard in Power BI. An AI assistant (RAG) was then added so HR
questions can be asked in plain English and answered from the dataset.

## 🛠️ Tools Used
- **Python (Pandas, Matplotlib, Seaborn)** – Exploratory data analysis and visualization
- **SQL (MySQL)** – Business insight queries and window functions
- **Power BI** – Interactive dashboard for attrition trend and driver analysis
- **FAISS, Sentence-Transformers, Ollama (Qwen 2.5), Streamlit** – RAG-based AI assistant

## 📂 Project Files
- `HR_Employee_Attrition_Analysis.ipynb` → Python notebook (EDA & visualizations)
- `HR_Employee_Attrition.csv` → Dataset (1,470 records)
- `hr_attrition_queries.sql` → 10 SQL queries (MySQL)
- `HR-attrition.pbix` → Power BI dashboard
- `app.py` → Streamlit AI assistant (RAG)
- `requirements.txt` → Python packages needed for the assistant

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

## 🤖 AI Assistant (RAG)
A chatbot that answers HR questions such as *"Which department has the lowest attrition?"*
or *"Does overtime affect attrition?"* using the dataset.

**How it works**
1. Each employee record is converted into text and then into embeddings
   (Sentence-Transformers, `all-MiniLM-L6-v2`).
2. FAISS finds the records most relevant to the question.
3. A local LLM (Qwen 2.5 via Ollama) writes the answer from the retrieved records
   and a dataset summary.
4. Counts, percentages, and highest/lowest comparisons are calculated directly in
   **Pandas**, not by the LLM.

**Why Pandas for the numbers?** In testing, the small LLM sometimes mixed up names and
values (for example, naming the wrong department as lowest). Moving exact calculations
to Pandas fixed this.

**How to run**
```bash
pip install streamlit pandas numpy faiss-cpu sentence-transformers ollama
ollama pull qwen2.5:3b
streamlit run app.py
```
Set the dataset path in `app.py` (`CSV_PATH`) before running. Ollama must be running
in the background.

## 🔑 Key Findings
- Overall attrition rate: **14.69%**
- **Human Resources** department has the highest attrition rate (~21%)
- Employees who work **overtime** leave at nearly 2x the rate of others (23.0% vs 11.4%)
- **Lower job satisfaction** is associated with higher attrition

## ⚠️ Limitations
- A small local model (3B) can still make mistakes on open-ended questions
- The dataset is a single CSV with 1,470 rows

## 📁 Data Source
[IBM HR Analytics Employee Attrition Dataset](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)

## 👤 Author
Rajat Yadav

import re
import numpy as np
import pandas as pd
import faiss
import ollama
import streamlit as st
from sentence_transformers import SentenceTransformer

CSV_PATH = r"C:\Users\RAJAT YADAV\Downloads\hr employee attribution.csv"
LLM_MODEL = "qwen2.5:3b"
EMB_MODEL = "all-MiniLM-L6-v2"
TOP_K = 8

COLUMN_ALIASES = {
    "Department": ["department", "dept"],
    "JobRole": ["job role", "jobrole", "role", "position"],
    "Gender": ["gender", "male", "female"],
    "OverTime": ["overtime", "over time"],
    "MaritalStatus": ["marital status", "marital", "married", "single", "divorced"],
    "BusinessTravel": ["business travel", "travel"],
    "EducationField": ["education field", "field of education"],
}


@st.cache_data
def load_data(path):
    return pd.read_csv(path)


@st.cache_resource
def load_embedder():
    return SentenceTransformer(EMB_MODEL)


@st.cache_resource
def build_index(path):
    df = load_data(path)
    docs = [", ".join(f"{c}: {row[c]}" for c in df.columns) for _, row in df.iterrows()]
    emb = load_embedder().encode(docs, normalize_embeddings=True, show_progress_bar=False).astype("float32")
    index = faiss.IndexFlatIP(emb.shape[1])
    index.add(emb)
    return docs, index


@st.cache_data
def build_summary(path):
    df = load_data(path)
    lines = [f"Total employees (rows): {len(df)}"]
    att_col = next((c for c in df.columns if "attrition" in c.lower()), None)
    cat_cols = [c for c in df.columns if df[c].dtype == "object" and 1 < df[c].nunique() <= 15]
    num_cols = [c for c in df.select_dtypes("number").columns if df[c].nunique() > 1]

    left = None
    if att_col:
        left = df[att_col].astype(str).str.strip().str.lower().isin(["yes", "1", "true", "y"])
        lines.append(f"Employees who left (attrition): {int(left.sum())} of {len(df)} = {left.mean()*100:.1f}% attrition rate")

    for c in cat_cols:
        vc = df[c].value_counts()
        lines.append(f"Count by {c}: " + ", ".join(f"{k}={v}" for k, v in vc.items()))
        if left is not None and c != att_col:
            rate = left.groupby(df[c]).mean() * 100
            lines.append(f"Attrition rate by {c}: " + ", ".join(f"{k}={v:.1f}%" for k, v in rate.items()))
            lines.append(f"HIGHEST attrition by {c}: {rate.idxmax()} ({rate.max():.1f}%)")
            lines.append(f"LOWEST attrition by {c}: {rate.idxmin()} ({rate.min():.1f}%)")
            lines.append(
                f"Comparison for {c}: {rate.idxmax()} has HIGHER attrition than {rate.idxmin()} "
                f"by {rate.max() - rate.min():.1f} percentage points"
            )

    for c in num_cols:
        s = f"{c}: avg={df[c].mean():.1f}, min={df[c].min()}, max={df[c].max()}"
        if left is not None:
            s += f" | avg for employees who left={df.loc[left, c].mean():.1f}, stayed={df.loc[~left, c].mean():.1f}"
        lines.append(s)
    return "\n".join(lines)


def _has(words, text):
    return any(re.search(rf"\b{re.escape(w)}\b", text) for w in words)


def direct_answer(question, df):
    ql = question.lower()
    att_col = next((c for c in df.columns if "attrition" in c.lower()), None)
    if att_col is None or "attrition" not in ql:
        return None

    best_col, best_len = None, 0
    for col, aliases in COLUMN_ALIASES.items():
        if col not in df.columns:
            continue
        for a in aliases:
            if re.search(rf"\b{re.escape(a)}\b", ql) and len(a) > best_len:
                best_col, best_len = col, len(a)
    if best_col is None:
        return None

    left = df[att_col].astype(str).str.strip().str.lower().isin(["yes", "1", "true", "y"])
    rate = left.groupby(df[best_col]).mean() * 100
    sizes = df[best_col].value_counts()
    rates_text = ", ".join(f"{k}={v:.1f}%" for k, v in rate.sort_values(ascending=False).items())

    lowest_words = ["lowest", "least", "minimum", "min", "fewest", "smallest", "best", "kam"]
    highest_words = ["highest", "most", "maximum", "max", "top", "worst", "biggest", "largest", "zyada", "jyada"]
    effect_words = ["affect", "affects", "impact", "influence", "effect", "relationship", "matter", "matters", "difference"]

    if _has(lowest_words, ql) or _has(highest_words, ql):
        is_low = _has(lowest_words, ql) and not _has(["highest", "maximum", "max", "top", "worst"], ql)
        name = rate.idxmin() if is_low else rate.idxmax()
        n_left = int(left[df[best_col] == name].sum())
        n_all = int(sizes[name])
        return (
            f"{name} has the {'lowest' if is_low else 'highest'} attrition rate by {best_col}: "
            f"{rate[name]:.1f}% ({n_left} of {n_all} employees left).\n\n"
            f"All groups: {rates_text}."
        )

    if _has(effect_words, ql):
        hi, lo = rate.idxmax(), rate.idxmin()
        return (
            f"Yes, {best_col} makes a difference. Attrition by {best_col}: {rates_text}. "
            f"{hi} has higher attrition than {lo} by {rate.max() - rate.min():.1f} percentage points."
        )
    return None


def ask_hr(question, docs, index, summary):
    q = load_embedder().encode([question], normalize_embeddings=True).astype("float32")
    _, idx = index.search(q, TOP_K)
    records = [docs[i] for i in idx[0]]

    context = (
        "DATASET SUMMARY (exact statistics of the full dataset):\n" + summary +
        "\n\nSAMPLE EMPLOYEE RECORDS (most relevant to the question):\n" +
        "\n".join(f"- {r}" for r in records)
    )

    system_prompt = (
        "You are an HR data assistant for ONE specific employee dataset.\n"
        "Rules:\n"
        "- Answer ONLY using the DATA given by the user. Never use outside knowledge.\n"
        "- For counts, percentages, averages and comparisons, use the DATASET SUMMARY numbers exactly.\n"
        "- Use the SAMPLE EMPLOYEE RECORDS only for questions about specific employees or examples.\n"
        "- If the summary has relevant numbers, answer from them. Do not invent numbers.\n"
        "- ALWAYS answer in English only, even if the question is in Hindi or Hinglish. Use 2-4 short sentences."
    )

    resp = ollama.chat(
        model=LLM_MODEL,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"DATA:\n{context}\n\nQUESTION: {question}"},
        ],
        options={"temperature": 0, "num_ctx": 6144},
    )
    return resp["message"]["content"], records


st.title("HR Attrition AI Assistant (RAG)")

df_main = load_data(CSV_PATH)
docs, index = build_index(CSV_PATH)
summary = build_summary(CSV_PATH)

question = st.text_input("Ask your HR question:")

if question:
    direct = direct_answer(question, df_main)
    if direct:
        st.write(direct)
        st.caption("Calculated directly from the dataset.")
        records = []
    else:
        with st.spinner("Thinking..."):
            answer, records = ask_hr(question, docs, index, summary)
        st.write(answer)

    with st.expander("RAG debug: what context did the model get?"):
        st.text(summary)
        for r in records:
            st.text(r)

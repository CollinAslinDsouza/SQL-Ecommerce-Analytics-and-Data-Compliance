# SQL-Ecommerce-Analytics-and-Data-Compliance
Global E-Commerce Analytics &amp; GDPR Compliance Case Study.  An end-to-end SQL project demonstrating database design, business analytics, customer insights, and GDPR-compliant data governance for a multinational e-commerce company.



> [!IMPORTANT]
> ### 💡 Executive Summary
> This project simulates an end-to-end consulting engagement for a multinational e-commerce retailer. The solution covers the complete data lifecycle: designing a normalized relational database, generating executive business insights to track revenue and customer behavior, and implementing a robust, GDPR-compliant data governance architecture. 

---

## 📑 Table of Contents
1. [Part 1: Dataset and Table Creations](#%EF%B8%8F-part-1-dataset-and-table-creations)
2. [Part 2: Analysis and Business Case Solutions](#-part-2-analysis-and-business-case-solutions)
3. [Part 3: GDPR & Data Governance Compliance](#-part-3-gdpr--data-governance-compliance)
4. [Project Structure & How to Run](#-project-structure--how-to-run)
5. [Author & Contact](#-author--contact)

---

## 🗄️ Part 1: Dataset and Table Creations
**🔗 SQL Script:** [`01_dataset_table_creations.sql`](./scripts/01_dataset_table_creations.sql)

Managing a global storefront requires a scalable and normalized relational database to ensure data integrity and query efficiency. This database (`project_ecommerce`) is structured into five core tables:

* **`Regions`**: Tracks geographical segments and countries (e.g., North America, Oceania, Europe West) for localized reporting.
* **`Customers`**: Stores user profiles, contact information, and region associations.
* **`Products`**: Manages product catalogs, categories (Electronics, Clothing, Footwear, etc.), and pricing.
* **`Orders`**: The core fact table logging transaction dates, customer IDs, and binary return statuses.
* **`OrderDetails`**: The line-item bridge table connecting orders to products and quantities.

---

## 📈 Part 2: Analysis and Business Case Solutions
**🔗 SQL Script:** [`02_analysis_business_cases.sql`](./scripts/02_analysis_business_cases.sql)

To solve the strategic challenges of the business, advanced SQL querying (CTEs, Window Functions, Aggregations) was deployed. Below are 5 critical, data-driven insights reported to executive management based on the database outputs:

<details>
<summary><b>1. General Sales & AOV Optimization (Click to Expand)</b></summary>
<br>

* **Analysis Performed:** Calculated gross revenue versus realized revenue (excluding returned items) and tracked Average Order Value (AOV) across rolling months.
* **Management Insight:** By isolating net realized revenue, the data reveals that the **Electronics and Home** categories drive the vast majority of our profit margins. Furthermore, the Average Order Value (AOV) spikes consistently in Q4 across all regions. We recommend bundling lower-margin **Accessories** during these peak months to proactively maximize cart sizes and offset shipping logistics costs.
</details>

<details>
<summary><b>2. Customer Lifetime Value (CLV) & Segmentation (Click to Expand)</b></summary>
<br>

* **Analysis Performed:** Segmented the customer base into Platinum (> $1500), Gold, Silver, and Bronze (< $500) tiers based on cumulative historical spend.
* **Management Insight:** Applying our dynamic CTE grouping logic, we uncovered that while only a small fraction of our user base qualifies for the **Platinum** tier, they are responsible for a disproportionate share of aggregate CLV. Marketing must pivot from broad acquisition to VIP retention, deploying white-glove support and early-access catalogs exclusively for Platinum and Gold members to actively prevent high-value churn.
</details>

<details>
<summary><b>3. Product Quality & Return Rate Mitigation (Click to Expand)</b></summary>
<br>

* **Analysis Performed:** Aggregated return rates by product category and cross-referenced with total quantities sold.
* **Management Insight:** The `Return Rate by Category` queries exposed a critical operational flaw: **Footwear and Clothing** exhibit abnormally high return rates compared to hard goods. To protect net revenue and reduce expensive reverse-logistics overhead, we must immediately implement localized sizing guides, high-fidelity 3D product viewing, and stricter return window policies for all apparel categories.
</details>

<details>
<summary><b>4. Regional Market Penetration (Click to Expand)</b></summary>
<br>

* **Analysis Performed:** Mapped order volume and total revenue across 10 global regions.
* **Management Insight:** When comparing transaction counts to total revenue, **North America (USA)** and **Europe West (UK)** lead in raw volume. However, regions like **Oceania (Australia)** demonstrate a significantly higher Average Order Size. We recommend shifting 15% of our top-of-funnel ad budget toward Oceania to aggressively scale this highly lucrative demographic.
</details>

<details>
<summary><b>5. Retention & Order Frequency Trajectories (Click to Expand)</b></summary>
<br>

* **Analysis Performed:** Deployed Window Functions (`LEAD/LAG`) to calculate the exact days elapsed between consecutive orders for returning customers, grouped by region.
* **Management Insight:** The time-between-orders tracking indicates that reorder windows are widening in emerging markets like **Asia South (India)** and **Africa North (Egypt)**. To combat this stalling frequency, we must integrate our database with the CRM to trigger localized, automated email workflows offering targeted discounts exactly 14 days before a customer's historically established reorder date.
</details>

---

## 🔒 Part 3: GDPR & Data Governance Compliance
**🔗 SQL Script:** [`03_gdpr_data_governance.sql`](./scripts/03_gdpr_data_governance.sql)

As global data privacy regulations tighten, organizations must safely handle the "Right to be Forgotten" without breaking historical financial records. This project implements an enterprise-grade compliance protocol directly in the database.

* **Customer Anonymization (`AnonymizeCustomer` Procedure):** Created a stored procedure to mask personally identifiable information (PII) with generic placeholders (`GDPR_ANONYMOUS_USER`, `deleted@compliant.com`), ensuring historical sales and AOV metrics remain perfectly intact for finance teams.
* **Litigation Archiving (AES Encryption):** Before masking, the original PII is packaged into a secure string, encrypted using `AES_ENCRYPT()`, and pushed into an isolated `CustomerLitigationArchive` table stored as a `LONGBLOB`. This satisfies legal, tax, and audit requirements.
* **Hard-Delete Prevention (Triggers):** Deployed a `BEFORE DELETE` trigger (`trg_BlockCustomerDelete`) that strictly intercepts and blocks hard-deletes (`DELETE FROM Customers`), throwing an SQL exception to force backend engineers to use the compliant Anonymization procedure instead.

---

## 📁 Project Structure & How to Run

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/CollinAslinDsouza/global-ecommerce-analytics.git](https://github.com/CollinAslinDsouza/global-ecommerce-analytics.git)
   ```

---


## 👨‍💻 Author & Contact
**Collin Aslin Dsouza** *Business Analytics & CIMA Qualified Management Accounting*

* 📧 **Email:** [dszcollin@gmail.com](mailto:dszcollin@gmail.com)
* 💼 **LinkedIn:** [Connect with me on LinkedIn](https://www.linkedin.com/in/collindsouza30)
* 🐙 **GitHub:** [Explore my projects](https://github.com/CollinAslinDsouza)

--- 

# Senior Analytics Engineer Take-Home Assessment

## Goal & Focus Areas
Evaluate abilities in the following core areas:
- **Exploratory Analysis**: Investigate, analyze, and comprehend source Pipedrive CRM data.
- **Data Modeling**: Structure and organize data meaningfully (building reusable data layers).
- **SQL Code Efficiency**: Optimize SQL queries for performance.
- **Project Organization and Clarity**: Structure and document code and data flow for readability/collaboration.

---

## Setup & Credentials

### Local Database Setup
1. Download & launch **Docker Desktop**.
2. Run `docker compose up` to start a local Postgres database with the raw data loaded.
3. Database credentials:
   - **Host**: `localhost`
   - **User**: `admin`
   - **Password**: `admin`
   - **Port**: `5432`
   - **Database**: (Typically configured in `docker-compose.yml` / `profiles.yml`)

### DBT Configuration
- Use `dbt-core` and `dbt-postgres`.
- Test model outputs will write to the `public_pipedrive_analytics` schema.

---

## Project Requirements

1. **Remove Test Model**: Once setup and running are verified, delete `test_model.sql`.
2. **Explore Pipedrive CRM Source Data**: Gain a thorough understanding of the source tables, stages, deal changes, etc.
3. **Define DBT Sources**: Set up source definitions and build staging/intermediate/marts layers for a clean, modular, and maintainable data flow.
4. **Build the Reporting Mart (`rep_sales_funnel_monthly`)**:
   - Aggregate data at monthly intervals.
   - Show how many clients (deals) entered each funnel step/KPI during that month.
   - **Funnel Steps / KPIs**:
     - **Step 1**: Lead Generation
     - **Step 2**: Qualified Lead
       - **Step 2.1**: Sales Call 1
     - **Step 3**: Needs Assessment
       - **Step 3.1**: Sales Call 2
     - **Step 4**: Proposal/Quote Preparation
     - **Step 5**: Negotiation
     - **Step 6**: Closing
     - **Step 7**: Implementation/Onboarding
     - **Step 8**: Follow-up/Customer Success
     - **Step 9**: Renewal/Expansion
5. **Output Schema Specifications**:
   - `month` (DATE or VARCHAR representation of the month start)
   - `kpi_name` (Name of the funnel step/KPI, e.g., 'Lead Generation', 'Sales Call 1', etc.)
   - `funnel_step` (String representation, e.g., '1', '2', '2.1', '3', etc.)
   - `deals_count` (Count of unique deals that reached/entered this funnel step during the month)

### CRITICAL MODELING GUIDELINE
> [!IMPORTANT]
> The data layers created must not only serve this single funnel report. They should be built modularly (staging, intermediate, mart) to easily support future analytical requests and KPIs. The focus is on the modeling approach and data flow quality, not just the final query results.

---

## Submission Checklist
- Git commit all changes.
- Create a PR in your **forked** repository.
- Compress the project folder into a `.zip` file.
- Send the PR/repo link and the zip file via email.
- Time limit: **5 working days**.

# Frostbyte Ski Supply — Cortex Code Masterclass (Snowsight Edition)

Build autonomous data workflows and AI agents using Cortex Code in Snowsight, Skills, and dbt.

---

## Getting Started

### Setup — Create a Git Workspace

Complete these steps before starting Part 1.

### Prerequisites

- A Snowflake account with Cortex Code enabled in Snowsight
- A role with `CREATE DATABASE`, `CREATE WAREHOUSE`, and `CREATE ROLE` privileges
- Access to the lab Git repository

### 0. Create the Git Workspace (~2 min)

1. Log into your Snowflake account
2. Navigate to **Workspaces**
3. At the top, next to Workspaces / Databases, select the **+** icon and create a new Git Workspace
4. Add `https://github.com/sfc-gh-abarron/coco-masterclass` as the link to the Git repository
5. Click **Create API Integration**, name it `GITHUB`
6. Add `https://github.com/sfc-gh-abarron/` for allowed prefixes
7. Allow all authentication secrets
8. Click **Create**
9. Select **Public Repository** from the Create Workspace page
10. Click **Create**

This will give you the lab materials in a workspace.

In the workspace, browse to `.snowflake/cortex/skills/naming-convention/SKILL.md`. Look at the file and you can see how a Cortex Skill is structured — it is simple to read and describes how you want things to be set up.

Open **Cortex Code** from the icon on the right side of Snowsight.

---

## Part 1 — Accelerating Data Engineering with Cortex Code

Build a production-grade inventory analytics pipeline using natural language prompts, Skills, and dbt.

### 1. Setup Infrastructure (10 min)

#### Key Concept — Skills

Skills are markdown files (and optional scripts) that live in `.snowflake/cortex/skills/` in your workspace. They teach CoCo domain-specific knowledge — naming conventions, code patterns, organisational policies — so it applies them automatically whenever relevant. Think of them as persistent prompt instructions that activate contextually.

- Skills are triggered automatically when CoCo detects a relevant task
- They encode institutional knowledge that would otherwise live in someone's head or a wiki
- Any team member who opens this workspace gets the same guardrails

> **Note:** In Cortex Code CLI and Desktop, skills are triggered automatically. In Snowsight, that capability is limited today. It is best to invoke a skill manually using `/skill-name` in the console.

Call the **Naming Convention** skill by using `/naming-convention` then use the following prompt:

```
Create the Snowflake infrastructure for the Frostbyte ski supply inventory project — database, schemas, warehouse, and roles. Follow the naming convention skill.
```

Follow the console prompts — you will see it requires confirmation before it can execute commands. You can choose to allow each one individually or select "always allow COMMAND in this chat".

You can keep the commands if they are useful. Ask CoCo to:

```
Create this as a SQL worksheet so I can repeat if necessary in the future.
```

You will see a new SQL file created. Browse the file and select **Keep All** to save the changes.

**Expected result:** You should see `FROSTBYTE_DB` with schemas RAW, STAGING, MARTS, a warehouse `FROSTBYTE_XS_WH`, and two roles created.

---

### 2. Generate & Load Synthetic Data (20 min)

#### Key Concept — Skills with Scripts

Skills aren't limited to markdown instructions — they can include executable scripts (Python, SQL, bash) that CoCo runs on your behalf. The `generate-synthetic-data` skill contains both a `.md` file (instructions for CoCo) and a `generate_data.py` script (the actual generator). This pattern is powerful for:

- Repeatable workflows — anyone can generate consistent test data
- Guided execution — CoCo asks the right questions before running the script
- End-to-end automation — generation + loading in a single conversation

#### 2.1 — Generate CSVs

Call the skill first: `/generate-synthetic-data`, then add:

```
Generate synthetic data for the Frostbyte ski supply inventory project using the generate-synthetic-data skill. Do not load the data yet.
```

CoCo will ask you how many records to generate. The Small (5 stores, 50 products, 10 suppliers, 1000 stock records, 200 purchase orders) works well.

#### 2.2 — Load into Snowflake

Call the naming convention skill again (`/naming-convention`), then:

```
Load all the generated CSV files into Snowflake tables in the FROSTBYTE_DB.RAW schema. Create the tables, stage, and file format as needed following the naming convention.
```

You may see it fails with sandbox connectivity errors, but CoCo recovers and uses INSERT statements to create the data. This is a current limitation of the internal sandbox for the CoCo Snowsight option.

Ask CoCo to validate the data import by comparing the tables to the CSV files. This will validate counts and basic data entry.

**Expected result:** 5 tables in `FROSTBYTE_DB.RAW` — STORES, PRODUCTS, SUPPLIERS, STOCK_LEVELS, PURCHASE_ORDERS.

---

### 3. Build DBT Models (20 min)

#### Key Concept — Bundled Skills + Skill Composition

CoCo has bundled skills for common frameworks like dbt — it already knows how to scaffold projects, write models, and deploy. By combining the bundled dbt skill with your custom `naming-convention` skill and the `data_contract.json`, CoCo produces models that are both technically correct and aligned with your organisation's standards.

- **Data contracts as input** — the JSON contract acts as a machine-readable spec for what models should look like
- **Skill stacking** — multiple skills compose together (naming + dbt + data modelling)
- **Creating skills from sessions** — Step 3.2 captures decisions you made during this session as a new reusable skill

#### 3.1 — Build Staging Models

Remember: in Snowsight, we want to specify the skills we will use first. Call `/generate-synthetic-data` and `/naming-convention`. In addition we will call the `/dbt-projects-on-snowflake` skill. We can also use `@` to give context to the prompt — use `@data_contract.json` to add this to the prompt. Then use the following text:

```
Create a new dbt project for the Frostbyte inventory analytics platform. Using the data contract in data_contract.json, build the staging models. Follow the naming convention skill for all Snowflake object references. Do not use any external dependencies.
```

> **Hint:** If this step seems to be taking a while, check it's not waiting for any confirmation and expand out the command using the dropdown arrow.

#### 3.2 — Create a Data-Modelling Skill

Once something has been done the way you want it, you can take that information and build this into a reusable skill. This simplifies repeating tasks for yourself and for other users. You can generate these using CoCo and keep them updated as well in the same manner. We'll create one now using the below prompt:  

```
Create a new CoCo skill called "data-modelling" that captures the dbt patterns, conventions, and decisions we've used so far in this session — project structure, model naming, materialisation choices, and the Frostbyte naming convention.
```

Browse the skill folder and you can see what has been created. Have a look at some of the layouts and choices it has put in there.  

#### 3.3 — Build Marts & Deploy

We will now use the skill we just created to repeat the process, along with going ahead and deploying the project. 

```
Using the data contract in data_contract.json and the data-modelling skill, build the marts models (fct_inventory_health and fct_procurement_summary) in the dbt project. Then deploy the full project to Snowflake.
```

Remember to call skills where needed and add the context from files with `@`.

**Expected result:** Views in `FROSTBYTE_DB.STAGING` and tables in `FROSTBYTE_DB.MARTS` visible in Snowsight.

---

### 4. dbt Tests (10 min)

#### Key Concept — Contract-Driven Testing

Rather than writing tests by hand, you use the data contract as the single source of truth for what quality rules should exist. CoCo reads the contract and generates the correct dbt YAML tests — not_null, unique, accepted_values, relationships, and range checks. This means:

- **Zero manual test authoring** — the contract defines it, CoCo implements it
- **Self-healing pipelines** — when tests fail, CoCo's auto-fix loop diagnoses and repairs the issue
- **Living documentation** — your contract is always in sync with your actual test suite

It's likely that CoCo has already created and run all tests, but let's confirm by asking it to test the dbt models.

#### 4.1 — Generate Tests

```
Using the data contract in data_contract.json, add dbt tests for all staging and marts models. Include not_null, unique, accepted_values, relationships, and accepted_range tests as defined in the contract.
```

Reference the context using `@`:

```
@data_contract.json /dbt-projects-on-snowflake /naming-convention
```

#### 4.2 — Run Tests

```
Run all dbt tests and fix any failures.
```

**Expected result:** All tests passing. CoCo will auto-fix any issues it finds.

---

## Part 2 — Team-Based Rapid Prototyping and Building AI Agents

Use custom skills to build a sandbox prototyping environment for natural language querying of your data.

### Prerequisites for Part 2

- Completion of Part 1
- `FROSTBYTE_DB.MARTS` schema present with two tables populated
- `sandbox-frostbyte` skill available in the workspace
- Supplier contract document PDFs in the `supplier_contracts` directory under the `/answers` directory

> **Hint:** Refresh your browser and start a new chat session before beginning Part 2. This refreshes the authentication token for your chat session.  

---

### 1. Provision your Prototyping Sandbox Environment (10 min)

#### Key Concept — Skills

A user in a particular business unit can follow a custom skill to clone data for a specific business unit in order to work on that data and perform tasks such as building an AI Agent.

Call the `sandbox-frostbyte` and `naming-convention` skills, then:

```
Create a sandbox environment
```

For this lab, please select **Retail / Store Operations**.

The skill will confirm your selections and the names of the database objects — ensure both tables in the MART schema will be cloned.

Proceed with the DDL creation when prompted.

**Expected result:** Sandbox will be provisioned and you can see both tables in your sandbox database/schema.

---

### 2. Extract Key Information from Supplier Documents (10 min)

#### Key Concept — Unstructured Data Extraction with Cortex

Turn unstructured documents into actionable structured information. AI_EXTRACT can extract text from documents and images and add this to a table. This lets you retrieve information from unstructured documents in a simple workflow.  

Continue on with the skill workflow and for the option to select the Prototyping Track, select the option: **Document AI**

It should find the PDFs automatically in the workspace. If there are any issues, you can tell it where to find the files.

CoCo will create a named stage, upload the files, and then use `AI_EXTRACT` to extract key data fields and create a new table with this data. If it hasn't created a SQL file with the commands, you can ask it again to do this so you can see how AI_EXTRACT functions.

**Expected result:** Check in Snowsight under the MARTS schema of your sandbox database for the newly created DIM_SUPPLIER... table.

---

### 3. Generate Analytics Prototype — Semantic View, Cortex Analyst, and Cortex Agent (20 min)

#### Key Concept — Skills Workflow

A skill can provide a workflow and, based on user selections, can step through a process to generate Snowflake objects. In this case we want to select the option for an Analytics Prototype.

Continue on with the skill workflow and select/type **option E: Analytics Prototype**.

When prompted for the business questions you want to answer, select **Other...** and type:

```
Create a semantic view based on the tables in the MARTS schema.
```

CoCo will continue on and generate the YAML and semantic view and test it. Once complete you can see the questions and answers. You can test the Cortex Analyst semantic model with an additional question such as:

```
Test the semantic view with this question: Which suppliers have the most products below reorder point?
```

**Expected result:** A list of suppliers and a count of products below reorder.

You can also view the semantic view in Snowsight under **AI & ML → Cortex Analyst → Semantic View → SANDBOX_FROSTBYTE_RETAIL_POC.MARTS**.

Ask CoCo to create a Cortex Agent based on this semantic view now we know it works:

```
Create a Cortex Agent based on this semantic view and add the agent to Snowflake CoWork.
```

**Expected result:** Successful creation of the agent.

Go to [ai.snowflake.com](https://ai.snowflake.com) and validate the agent was successfully created and is available. You should be able to ask the agent questions about the dataset.  

---

### 4. Build a Streamlit App to Display the Data (15 min)

#### Key Concept — Bundled Skills

CoCo can be used to create a Streamlit app/dashboard on your data in Snowflake.

Let's try another prototyping track and select building a Streamlit app.

```
I'd like to choose another prototyping track
```

Select **Option C: Prototype App**.

In this case we are instructing CoCo to parse the image file, read the general style of the example dashboard and use that as a basis for our new Streamlit dashboard. You could build into your skill the corporate style you wish all Streamlit apps to follow.

CoCo will suggest some data to visualise — select **Something else** and type:

```
Display Inventory Health Dashboard data and use the ~/.snowflake/cortex/skills/sandbox-frostbyte/streamlit_template.png image as a guide for the style of the dashboard
```

CoCo will now create a compute pool and the external access integration (for any Python libraries it needs). It will also create the file artifacts locally and then deploy them into Snowflake.

You can run this app inside your workspace. When you are happy it's working and doesn't need any adjustments, click **Deploy**.

**Expected result:** Click on the link provided by CoCo and view the Streamlit app.

**Optional:** Continue on and have CoCo make changes to the Streamlit app, such as adjusting charts and styles. 

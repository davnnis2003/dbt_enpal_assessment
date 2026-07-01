# Metrify Interview Notes & Context

This document compiles notes, transcripts, and context from the recruiter screening and hiring manager interviews for the **Data Engineering Lead / Analytics Engineering Lead** role at Metrify (a startup inside Enpal).

---

## 1. Role Context & Team Setup

### About Metrify
- **Business**: A "startup inside a startup" at Enpal. Metrify is an MSB (*Messstellenbetreiber*) — a smart meter operator in Germany. They manage smart meters and have customer-level data including 15-minute energy consumption/production readings.
- **Why the data matters**: The energy finance team at Enpal (central) buys energy up to 2 years ahead and uses actuals from Metrify (e.g., 15-min customer readings) to compare forecasts vs. actuals. Metrify is a key data supplier for the broader Enpal energy operation.
- **Office**: Hybrid setup (expecting 3–4 days/week in office). Located at the Empire campus (Berlin), enabling knowledge sharing with the larger Enpal central data team.
- **Current Data Team**: Small team of ~4 people:
  - 1 Data Engineer
  - 2 Analytics Engineers
  - 1 Technical Project Manager (PM)
- **Hiring Manager**: Marcus, the CTO (currently on parental leave until ~July, but will join final interview stage).

### Core Challenges & Priorities
- **Flat & Decentralized structure**: Fuzzy reporting lines, lack of centralized data vision, weak coordination. The CTO wants to reduce the "everyone reporting to everyone" dynamic.
- **No Motivation Issues, But Lack of Guidance**: The team wants to deliver but needs structure, best practices, and close guidance. The team fought their way through work independently since last year.
- **Greenfield Environment**: Bringing structure to chaos and centralizing the data model/infrastructure is the primary mandate — not pure people management or mentoring.
- **Cross-team Collaboration friction**: The central energy team (Daria's team) was blocked on data requests from Metrify. Example: someone promised Wednesday delivery, but by Friday it turned out the legal department process hadn't even started. No visibility, poor communication, no trust.
  - Around May 2026, Daria and a data engineer from her team went to Metrify directly to assess the situation. They:
    - Built ticket-creation automation in the Metrify Slack channel (since the team cited "no time to create tickets")
    - Made sure they started using Azure Boards
    - Implemented weekly data team connects (Kanban)
    - Mapped who is doing what across the team

---

## 2. Interview Process

| Stage | Description |
|---|---|
| 1. Recruiter Screen | Casual HR call with **Antonia** (recruiter) |
| 2. Technical Chat | With a lead analytics engineer from another Enpal entity (e.g. Heat/EMPA) — Metrify team not senior enough to assess |
| 3. Case Study | 5-day take-home assessment (sent only after agreement) |
| 4. On-site / Team Presentation | Present case study, meet the Metrify data team |
| 5. Final CTO Chat | With Marcus (likely online due to parental leave) |

---

## 3. Jimmy Pang's Background & Interview Alignment

### Career Timeline
- **Delivery Hero** (Hong Kong & Berlin): Started as intern, progressed through intermediate and senior levels. ~3 years.
- **HelloFresh**: Analytics Engineer. Met Fabio (former Wayfair, HelloFresh connection).
- **Vestiaire Collective** (French luxury marketplace): Analytics Engineering Manager / BI Engineering Manager. Most recent role. Left January 2025 due to company-wide layoffs (missed business targets by ~2x for 6+ months → CEO replaced, whole data team laid off along with remote employees).

### Key Achievements Mentioned
- **Transportation Data Table Rebuild** (Vestiaire Collective): Rebuilt a chaotic transportation logic/table into a robust, microservices & Kafka-based pipeline. Leveraged an ongoing TMS microservice initiative from product engineering. Defined a clean fact table (one row = one shipment, with lead time, carrier, service type). Became the **5th most used table company-wide** and earned praise from the transportation lead (Amazon background) — "first time he trusted data in the whole year." ~27 row components.
- **Data Mesh Pilot** (Vestiaire Collective): Led the first data mesh pilot. Adapted the fully federal/decentralized model to fit French company culture (which expects a strong central idea + satellite teams). Involved significant stakeholder lobbying, a 6-page business impact proposal, and a move to a centralized-but-federated architecture. CI improvements and cost control were identified as ongoing improvement areas.

### Tech Stack
- dbt, Snowflake, Tableau, Airflow, Kafka, Postgres, microservices

### Proposed 30/60/90 Day Plan
- **Day 1–30 (Handshake & Trust)**:
  - Focus heavily on relationship building and stakeholder mapping.
  - Gather a "wish list" of requests and identify current pain points from all stakeholders (including data team members).
  - Identify and deliver quick wins to establish credibility and trust.
- **Day 30–60 (Process & Prioritization)**:
  - Establish a single source of intake/prioritization for stakeholder requests to eliminate silos.
  - Introduce agile methodologies (e.g., Scrum/Kanban) to improve expectation management and team predictability.
  - Measure baseline team performance: lead time from ticket creation to resolution.
  - Consider introducing a regular "chapter" connect across all data people (weekly or bi-weekly).
- **Day 60–90 (Solidification & Feedback)**:
  - Solidify delivery processes, perform retrospectives with stakeholders, and pivot processes based on feedback.
  - Engage leadership/CTO early and often — having leadership blessing makes problem-solving much easier.

*Reference: Inspired by "The First 90 Days" (book), plus lived experience at Vestiaire Collective and Delivery Hero with multi-profile stakeholders (business, product, operations, PMs, engineers, executives).*

---

## 4. Interview Takeaways & Alignment Points

### Recruiter Screen (Antonia — 17 June 2026)
- **Positive screening**: Recruiter confirmed the role is a hands-on player-coach lead, not a pure people-manager role.
- **Key gap flagged**: Team already works fairly independently — mentoring is not the main focus; bringing structure to chaos is.
- **Org intentionally low-hierarchy**: They want to reduce "everyone reporting to everyone." Fuzzy reporting today across CTO, engineering manager, and PM.
- **Start**: ASAP.
- **Strongest positioning**: Hands-on data leader who brings structure, owns messy systems, and can align business + tech in a greenfield startup environment.

### HM Interview (Daria — 25 June 2026)
- **Interviewer**: Daria, Lead Analytics Engineer from the central energy team (not the CTO — Marcus is CTO and does the final round).
- **Interview character**: Fit and leadership-depth conversation, not a hard technical screen.
- **What landed well**:
  - Transportation table rebuild as a concrete "trustworthy source of truth" example.
  - Data mesh pilot as a leadership/change-management example.
  - 30/60/90-day plan was specific and well-received ("very specific answer").
  - AI stance: productivity booster → stable semantic layers as the foundation → BI/insights generated on the fly for operational frontline teams (referencing the semantic layer trend from Snowflake/open standards).
  - Deal breaker clarity: lack of curiosity is non-negotiable.
- **Net read**: **Positive HM interview.** Strongest signal: can impose structure without killing the startup energy. Biggest theme: they need a **trusted operator who can centralize chaos fast**.

---

## 5. Positioning Summary

- **Role**: Player-coach (significant hands-on technical involvement, especially early, while managing/guiding the team).
- **Core value-add**: Brings structure to messy systems, bridges the business–tech gap, thrives in greenfield startup environments.
- **Stance on AI**: AI as productivity booster. Promote stable semantic/semantic modeling layers as foundation so AI/BI tools can dynamically serve operational insights without breaking.
- **Deal breaker**: Lack of curiosity — non-negotiable.

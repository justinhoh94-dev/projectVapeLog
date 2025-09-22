
# agents.md

## 1) Mission & Success Criteria

**Mission:** Build a privacy-first mobile & web app that helps a single user discover which **terpene** and **cannabinoid** (tetrahydrocannabinol (THC), cannabidiol (CBD), etc.) profiles correlate with their desired effects (e.g., *awake, active, cerebral, social*) and undesired effects (e.g., *tired, groggy, anxiety, antisocial*).

**What “good” looks like (v1 MVP):**

1. Log a session in ≤10s (strain/product, route, dose, time, context, feelings at T+30/60/120).
2. Show a **Top 3 Recommendation** card (profile + example products) with confidence bands.
3. Explain **why** (key drivers: terpenes/cannabinoids, dose, time-of-day) in one sentence.
4. All data local-first; no PII sync by default; opt-in cloud backup.

**Non-goals (v1):** community/social features, medical claims, marketplace, complicated cohort analytics, cross-user modeling.

---

## 2) Architecture (high level)

* **Client:** iOS (Swift/SwiftUI) + Web (Next.js). Offline-first store (SQLite via GRDB on iOS; IndexedDB/SQLite via WASM on Web).
* **App Core:** Type-safe data layer, background jobs (reminders for follow-ups), analytics engine (on-device first), optional cloud sync (Supabase/Firebase) **off by default**.
* **Analytics:** Feature builder → model runner (regularized regression + feature importance) → explainer → recommender.
* **Privacy/Security:** Local encryption at rest; optional end-to-end encrypted (E2EE) backup; no third-party telemetry unless explicitly enabled.

---

## 3) Data Model (local schema, v1)

### 3.1 Entities

* **Product**

  * `id` (uuid), `name`, `brand`, `type` (flower, vape, edible, concentrate)
  * `route` (smoke, vape, oral, sublingual, topical)
  * **Cannabinoids (per label or lab):** `thc_pct`, `cbd_pct`, `cbg_pct`, `thcv_pct` (nullable)
  * **Terpenes (% or mg/g):** `myrcene`, `limonene`, `beta_caryophyllene`, `linalool`, `pinene`, `terpinolene`, `humulene`, `ocimene`, `other_json`
  * `lab_test_date`, `source_confidence` (enum: none,label,coa)
* **Session**

  * `id`, `product_id`, `datetime_start`, `dose_unit` (mg, hits, puffs), `dose_value`
  * `context` (`location_home/gym/outdoor`, `company_alone/friends`, `caffeine_mg`, `alcohol_units`, `food_recent` bool)
  * `sleep_prev_hr`, `stress_0_5`, `mood_0_5`, `tolerance_days_since_break`
* **CheckIn**

  * `id`, `session_id`, `offset_min` (30, 60, 120), **Effects (0-5 Likert)**:

    * **Positive:** `awake`, `active`, `cerebral`, `social`, `euphoric`, `creative`, `focused`
    * **Negative:** `tired`, `groggy`, `anxious`, `antisocial`, `paranoia`, `dry_mouth`, `dry_eyes`, `racing_heart`
  * `notes`, `side_effects_json`
* **RecommendationLog**

  * `id`, `created_at`, `top_profiles_json`, `explanations_json`, `model_version`

### 3.2 Derived Features (built per Session)

* `dose_normalized` (mg THC equivalent; map hits/puffs with device factor)
* `terp_profile_vector` (normalized terpene percentages)
* `cannabinoid_vector` (THC, CBD, CBG, THCV)
* `time_of_day_bucket` (morning/afternoon/evening)
* `day_of_week`, `pre_sleep_deficit` (if `sleep_prev_hr < 6`)
* `context_vectors` (caffeine, alcohol, company)

---

## 4) Analytics & Ranking (on-device baseline)

**Targets:** two independent composites

* **Positive Composite (POS):** mean(z-scores of awake, active, cerebral, social, focused)
* **Negative Composite (NEG):** mean(z-scores of tired, groggy, anxious, antisocial); higher is *worse*.

**Modeling approach (v1):**

1. **Regularized linear models** (L2/L1) for POS and NEG vs features:

   * Inputs: terp\_profile\_vector, cannabinoid\_vector, dose\_normalized, time\_of\_day, context\_vectors, tolerance.
   * Train incrementally as data grows; require ≥15–20 sessions to unlock model.
2. **Feature importances:** standardized coefficients; show top ± drivers.
3. **Recommendation score:**
   `REC = sigmoid( w1*POS_pred - w2*NEG_pred + w3*match_goal + w4*habit_penalty )`

   * `match_goal`: cosine similarity between user’s chosen goal (e.g., “awake, social”) and product’s predicted effect vector.
   * `habit_penalty`: mild diversity term to avoid over-reliance on a single product.
4. **Confidence bands:** bootstrap on residuals; display **Low/Med/High**.

**Confounders to track:** caffeine/alcohol, time-of-day, prior sleep, recent tolerance breaks, dose scaling by route. All included as covariates.

**Explainability (user-facing):**
“**Limonene + THCV (dose \~5–10 mg) at 2–6 pm** most strongly aligned with *awake + social* for you; **high myrcene** correlated with *tired*.”

---

## 5) Product Requirements (MVP → v1.1)

### 5.1 MVP

1. Create/Select Product → Log Session (≤10s).
2. Two follow-up reminders at +30 and +90 min (silent, local notif).
3. Dashboard: “Today”, “My Patterns”, “Top 3 Right Now”.
4. Export (CSV/JSON) local data.

### 5.2 v1.1 Enhancements

* Photo scan of label/COA to prefill terpenes/cannabinoids (manual verify).
* Calendar heatmap of POS/NEG.
* Simple streaks & adherence nudges (fully offline).

---

## 6) Privacy & Security

* Local-first storage; **no** background network calls by default.
* Toggable encrypted backup; user-supplied passphrase; zero-knowledge if cloud is enabled.
* No ads, no third-party analytics unless explicitly opted-in.

---

## 7) API Contracts (internal, modular boundaries)

### 7.1 AnalyticsEngine

```ts
type SessionFeatures = { /* derived as in §3.2 */ }
type FitResult = { coef: Record<string, number>, intercept: number, metrics: { r2:number, mae:number }, version:string }
type Pred = { pos:number, neg:number, conf:'low'|'med'|'high', topDrivers:{plus:[string], minus:[string]} }

fit(sessions: SessionFeatures[]): FitResult
predict(s: SessionFeatures): Pred
recommend(goalVector: number[], candidates: Product[]): { productId:string, recScore:number, explanation:string }[]
```

### 7.2 DataStore

```ts
getProducts(q?:string): Product[]
upsertProduct(p: Product): void
logSession(s: Session): void
logCheckIn(c: CheckIn): void
export(format:'csv'|'json'): Blob
```

### 7.3 Reminders

```ts
scheduleFollowUps(sessionId:string, offsetsMin:number[]): void
cancelFollowUps(sessionId:string): void
```

---

## 8) UX Rules of Thumb

1. **Speed first:** default dose remembered per product/route; single-tap logging.
2. **Gentle reminders:** never nag more than 2 follow-ups per session.
3. **Actionable insights:** every insight must answer: *what to try next* (dose/time/terpene).
4. **Accessible scales:** 0–5 emoji sliders; short tooltips for each effect.

---

## 9) QA & Acceptance Tests

* **Cold start:** Add a product, log a session, receive reminders, submit 2 check-ins, view dashboard—**under 2 minutes** total.
* **Model gating:** With <15 sessions, app shows heuristics (“starter profiles”) not personalized ML.
* **Export round-trip:** Export → delete app → import → data parity = 100%.
* **Privacy:** Airplane mode end-to-end; all features (except backup) work.

---

## 10) Roadmap (cut if time-boxed)

* **v1.2:** On-device OCR for labels; COA importer.
* **v1.3:** Lightweight Bayesian update (hierarchical priors), SHAP-style explanations.
* **v1.4:** Wearable hooks (sleep/HR) **opt-in** to improve confounder control.

---

## 11) Agent Roster & Prompts

> Use these prompts with your automation framework (or as contributor playbooks). Keep outputs concise, deterministic, and aligned to the contracts above.

### 11.1 Product Owner Agent

**Goal:** Keep scope tight, maintain success criteria, write clear tickets.
**System prompt:**
“You are a ruthless scope-keeper. Enforce the MVP rules and acceptance tests in §1 and §9.”
**Tasks:**

* Convert features into tickets with *Given/When/Then*.
* Reject scope creep that violates non-goals.

### 11.2 Data Modeler Agent

**Goal:** Maintain the schema in §3 with migrations.
**System prompt:**
“You design normalized, versioned schemas and safe migrations; you never break existing exports.”
**Deliverables:** SQL/Swift models/TypeScript types + migration scripts + test fixtures.

### 11.3 Analytics Agent

**Goal:** Implement §4 models fully on-device.
**System prompt:**
“You implement regularized linear models, bootstrap confidence, and concise explanations that cite top drivers.”
**Acceptance:** Deterministic unit tests with fixed seeds; `predict()` returns monotonic changes when a single driver is scaled.

### 11.4 iOS Agent

**Goal:** SwiftUI logging flow & reminders per §5, §7.3.
**System prompt:**
“You optimize for <10s logging and offline reliability; state is single-source-of-truth.”
**Deliverables:** SwiftUI views, GRDB models, notification scheduling, snapshot tests.

### 11.5 Web Agent

**Goal:** Next.js dashboard & forms mirroring iOS.
**System prompt:**
“You ship accessible, keyboard-first forms and deterministic SSR/ISR.”
**Deliverables:** Pages/components, SQLite/IndexedDB adapter, CSV/JSON export.

### 11.6 QA Agent

**Goal:** Enforce §9 tests; ship test matrix.
**System prompt:**
“You break things methodically; you automate Given/When/Then scenarios.”
**Deliverables:** E2E scripts (Playwright/XCTest), fixtures, coverage report.

### 11.7 Privacy/Security Agent

**Goal:** Enforce §6.
**System prompt:**
“You default to local-first, E2EE backups, and zero third-party calls unless opted-in.”
**Deliverables:** Threat model, crypto review, checklist in PRs.

### 11.8 Docs Agent

**Goal:** Keep user help concise and precise.
**System prompt:**
“You write short, user-first help with one actionable next step per insight.”
**Deliverables:** In-app tooltips, FAQ, export/import guide.

---

## 12) Issue Template (copy into `.github/ISSUE_TEMPLATE/feature.md`)

```
### Summary
One-liner

### User Story
As a <user>, I want <capability> so that <benefit>.

### Acceptance Criteria
- [ ] ...
- [ ] ...

### Tech Notes
Data model changes:
API contracts:
Analytics impact:

### Out of Scope
-
```

---

## 13) Edge Cases to Handle

* Session without lab terpene data → allow manual entry; mark `source_confidence=none`.
* Microdosing (very low dose) vs high dose: ensure nonlinearity captured with dose buckets.
* Multiple products in one session → support *sub-sessions* or split logging.
* Missed follow-ups → prompt next-day quick recap, clearly labeled as recall-biased.
* Confounders extreme (e.g., 400 mg caffeine) → display “confidence reduced” badge.

---

## 14) Glossary

* **COA:** Certificate of Analysis (lab-verified composition).
* **POS/NEG composites:** Aggregated effect scores used as modeling targets.
* **Local-first:** All core functionality works offline; sync is optional/opt-in.

---

### Final Notes for Contributors/Agents

* Prefer small, reversible PRs.
* Keep public health disclaimers visible; no medical claims.
* Every insight must include **What to try next** (dose/time/terpene) + **Why** (top drivers).

---


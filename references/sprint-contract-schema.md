# Sprint Contract Schema

## Purpose

A sprint contract is a negotiated agreement between Generator and Evaluator on what "done" means for a sprint. It prevents two failure modes:
1. Generator builds something the Evaluator can't verify
2. Evaluator tests things that weren't in scope

## Format

Every sprint contract follows this structure:

```markdown
# Sprint N Contract

## Sprint Goal
One sentence: what does this sprint deliver?

## Scope
Which requirement numbers from spec.md are included.

## Success Criteria
| # | Criterion | Verification Method | Threshold |
|---|-----------|-------------------|-----------|
| 1 | ... | ... | 7/10 |

## Verification Tools
What the evaluator will use.

## Pass Conditions
- Average >= 8/10
- No criterion < 7/10

## Out of Scope This Sprint
Features deferred.
```

## Examples of Good vs Bad Criteria

### Good (Testable)

| Criterion | Verification Method | Why Good |
|-----------|-------------------|----------|
| Server starts on port 3000 without errors | `npm start` then `curl localhost:3000` | Binary pass/fail, tool-verifiable |
| POST /api/recipes with valid JSON returns 201 | `curl -X POST -H 'Content-Type: application/json' -d '{"name":"test"}' localhost:3000/api/recipes` | Specific endpoint, specific status code |
| Home page renders a list of at least 3 seed recipes | Start app, read HTML output, count items | Concrete number, verifiable |
| Invalid email in signup shows "Invalid email" error | Submit form with "notanemail", check response | Specific input, specific expected output |
| Database contains recipes table with name, ingredients, instructions columns | `sqlite3 db.sqlite ".schema recipes"` | Exact tool command, verifiable schema |

### Bad (Subjective or Unverifiable)

| Criterion | Why Bad |
|-----------|---------|
| Code is well-organized | No objective test — what tool proves this? |
| Good user experience | Subjective, no threshold |
| Handles errors gracefully | Too vague — which errors? What's "graceful"? |
| Looks professional | No measurable standard |
| Performant | No benchmark, no threshold |

## Scoping Sprints

**Sprint 1 (MVP):**
- Core data model and API
- Primary user flow end-to-end
- Basic error handling
- 5-8 criteria

**Sprint 2 (Polish):**
- All "Must Fix" items from Sprint 1 evaluation
- Secondary features
- Edge cases and error states
- 6-10 criteria

**Sprint 3 (Complete):**
- Remaining features from spec
- Non-functional requirements (performance, accessibility)
- Final polish
- 5-8 criteria

## Carrying Forward

When Sprint N > 1:
- All "Must Fix" items from Sprint N-1's evaluation become mandatory criteria
- "Should Improve" items become optional criteria
- New features fill remaining slots

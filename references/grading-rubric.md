# Grading Rubric

## Purpose

This rubric calibrates evaluator scoring so that scores are consistent, evidence-based, and resistant to grade inflation. The most common evaluator failure mode is being too generous — anchoring on "it mostly works" and scoring 8-9 when significant gaps exist.

## Score Definitions

| Score | Label | Definition |
|-------|-------|-----------|
| 10 | Exceptional | Beyond requirements. Handles edge cases not in the spec. Polished. Verified with tools. Rarely awarded. |
| 9 | Excellent | Fully meets all requirements. No issues found during testing. Clean implementation. |
| 8 | Good | Meets requirements with only cosmetic or trivial issues. All core functionality works. |
| 7 | Acceptable | Meets requirements but with minor issues that don't block functionality. Minimum passing score. |
| 6 | Below threshold | Partially meets requirements. Some functionality works but notable gaps exist. |
| 5 | Weak | Core functionality has significant gaps. Works in happy path only. |
| 4 | Poor | Major issues. Primary functionality is broken or incomplete. |
| 3 | Very poor | Barely functional. Most criteria unmet. |
| 2 | Failing | Almost nothing works as specified. |
| 1 | Non-functional | Does not run, does not compile, or produces no useful output. |
| 0 | Cannot evaluate | Could not verify — server won't start, files missing, etc. |

## Calibration Examples

### Criterion: "POST /api/recipes creates a recipe and returns 201"

| Score | What you'd see |
|-------|---------------|
| 10 | Returns 201 with full recipe object including generated ID and timestamps. Input validation present. Duplicate handling works. |
| 8 | Returns 201 with recipe object. Works correctly for valid input. |
| 7 | Returns 201 but response body is missing some fields (e.g., no ID returned). |
| 5 | Returns 200 instead of 201, but recipe is created. |
| 3 | Endpoint exists but returns 500 for valid input. |
| 1 | Endpoint doesn't exist or server crashes. |
| 0 | Server won't start, can't test. |

### Criterion: "Home page renders a list of recipes"

| Score | What you'd see |
|-------|---------------|
| 10 | Renders list with images, descriptions, pagination, and empty state. |
| 8 | Renders list with all required fields. Looks clean. |
| 7 | Renders list but some fields missing or layout has minor issues. |
| 5 | Page loads but list is empty despite data in database. |
| 3 | Page loads but shows raw JSON or broken HTML. |
| 1 | Page returns 404 or blank screen. |

### Criterion: "Invalid input returns appropriate error messages"

| Score | What you'd see |
|-------|---------------|
| 10 | Field-level validation with helpful messages. All edge cases covered. |
| 8 | Returns 400 with clear error message for each invalid field. |
| 7 | Returns 400 but error messages are generic ("Invalid input"). |
| 5 | Returns 400 for some invalid inputs but 500 for others. |
| 3 | Returns 500 for all invalid inputs (no validation). |
| 1 | Accepts invalid input without error (no validation at all). |

## Common Scoring Mistakes

### Grade Inflation (most common)
- **Mistake:** Scoring 8 because "it mostly works"
- **Fix:** Ask "does it fully meet the criterion as stated?" If not, it's < 8.

### Binary Thinking
- **Mistake:** Scoring either 9 or 3, nothing in between
- **Fix:** Use the full scale. A 6 means "partially works with notable gaps" — that's a real score.

### Anchoring on Prior Scores
- **Mistake:** Previous iteration scored 5, this one is slightly better, so score 7
- **Fix:** Score each iteration independently against the criterion, not relative to prior iterations.

### Effort Bias
- **Mistake:** "They clearly tried hard, so 7"
- **Fix:** Score the output, not the effort. A broken feature is broken regardless of effort.

### Verification Shortcuts
- **Mistake:** "The code looks like it would handle errors" -> score 8
- **Fix:** Actually test it. Run the command. Send the bad input. Read the output. No evidence = score 0.

## Pass/Fail Calculation

```
average = sum(all_scores) / count(all_scores)
min_score = min(all_scores)

if min_score < 5:
    verdict = FAIL  # automatic fail floor
elif min_score < 7:
    verdict = FAIL  # no criterion below threshold
elif average < 8:
    verdict = FAIL  # overall quality bar
else:
    verdict = PASS
```

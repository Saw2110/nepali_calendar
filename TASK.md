# Comprehensive Analysis & Migration Prompt for Nepali Calendar Library

## Context

We are now in the **final stabilization phase** of the Nepali Calendar library.

The primary goal is **NOT to add new features**, but to make the library:

* Stable
* Consistent
* Easy to maintain
* Easy to migrate
* Future-proof
* Well documented
* Free from unnecessary legacy APIs
* Ready for long-term production use

This library will be used by many Flutter developers in real production applications.

Therefore, every recommendation must prioritize:

* Backward compatibility (when possible)
* Clear migration paths
* Developer Experience (DX)
* API consistency
* Long-term maintainability

---

# Primary Objective

Perform a **complete architecture and API analysis** of the entire package.

The analysis should identify:

* Deprecated widgets
* Deprecated APIs
* Deprecated helper methods
* Legacy implementations
* Duplicate features
* Inconsistent naming
* Old design patterns
* Newly introduced replacements
* Missing migration guides
* Documentation gaps
* Breaking changes

The final output should become the foundation for preparing the next stable release.

---

# Important Rules

## DO NOT

* Do NOT write code.
* Do NOT refactor immediately.
* Do NOT rename anything without justification.
* Do NOT remove APIs simply because they look old.
* Do NOT assume developer intentions.
* Do NOT introduce random improvements.

If any uncertainty exists,

**STOP and ASK FIRST.**

Never guess.

---

# Scope of Analysis

Analyze the **entire package**, including but not limited to:

* NepaliCalendar
* HorizontalCalendar
* YearViewCalendar
* DatePicker
* Calendar Controllers
* Calendar Models
* Utility Classes
* Extensions
* Theme System
* Builder APIs
* Navigation APIs
* Localization
* Formatting Helpers
* Event APIs
* Selection APIs
* Any other public API exposed by the package

Nothing should be skipped.

---

# Analysis Goals

For every public API, determine:

### 1. Is it still needed?

* Yes
* No
* Partially

Explain why.

---

### 2. Is it deprecated?

If yes:

* Why?
* Since when?
* What problem does it solve today?
* Why should developers stop using it?

---

### 3. What replaces it?

Identify the modern replacement.

Explain:

* Why the replacement is better
* New capabilities
* Better architecture
* Performance improvements
* Cleaner API
* Reduced maintenance

---

### 4. Migration Difficulty

Classify migration:

* No Change
* Very Easy
* Easy
* Medium
* Breaking

Explain why.

---

### 5. Migration Example

Provide migration examples such as:

Old API

↓

New API

Include only concise illustrative snippets when necessary (avoid full implementations).

---

# Required Deliverables

---

## 1. Deprecation Summary Table

Use a standardized documentation table such as:

| Deprecated API | Status | Recommended Replacement | Migration Difficulty | Compatibility | Notes |
| -------------- | ------ | ----------------------- | -------------------- | ------------- | ----- |

Every deprecated public API must appear here.

Nothing should be omitted.

---

## 2. Migration Guide

Create a section for every deprecated feature.

Structure:

### Old Feature

Purpose

Why it existed

Problems

---

### New Feature

Benefits

Architecture improvements

Performance improvements

Cleaner API

Future support

---

### Migration Steps

Step-by-step instructions.

---

### Example

Before

↓

After

---

### Breaking Changes

Mention every breaking change explicitly.

Never hide them.

---

## 3. Widget-by-Widget Analysis

Analyze every major widget individually.

Example structure:

### NepaliCalendar

Current Status

Strengths

Weaknesses

Deprecated APIs

Recommended APIs

Migration Notes

Future Recommendation

---

Repeat for:

* NepaliCalendar
* HorizontalCalendar
* YearViewCalendar
* DatePicker
* Any other public widgets

---

## 4. Public API Review

Review every exported API.

Classify as:

* Keep
* Improve
* Merge
* Replace
* Deprecate
* Remove (major version only)

Include reasoning for every decision.

---

## 5. Naming Consistency Review

Identify inconsistent naming.

Examples include:

* Widget naming
* Property naming
* Builder naming
* Callback naming
* Controller naming
* Theme naming
* Utility naming

Recommend a consistent naming convention.

Do not rename anything without clear justification.

---

## 6. Developer Experience (DX) Review

Evaluate:

* API discoverability
* Learning curve
* Documentation quality
* IDE autocomplete friendliness
* Default behaviors
* Error messages
* Builder patterns
* Configuration complexity

Recommend improvements where justified.

---

## 7. Documentation Review

Identify:

* Missing examples
* Missing migration guides
* Missing widget documentation
* Missing API documentation
* Missing best practices
* Missing common use cases
* Missing FAQs
* Missing troubleshooting notes

---

## 8. Breaking Change Report

Produce a dedicated report listing:

| Breaking Change | Impact | Migration Required | Severity | Recommendation |
| --------------- | ------ | ------------------ | -------- | -------------- |

No breaking change should be hidden inside other sections.

---

## 9. Stability Review

Identify anything that may affect:

* API stability
* Long-term maintenance
* Binary compatibility
* Package evolution
* Extensibility
* Scalability

Highlight risks.

Provide recommendations.

---

## 10. Final Recommendations

Summarize:

### APIs to Keep

Explain why.

---

### APIs to Deprecate

Explain why.

---

### APIs to Replace

Explain why.

---

### APIs to Remove (Next Major Version Only)

Explain why.

---

### New Standard APIs

Document the new recommended APIs that developers should adopt going forward.

These become the official APIs for future development.

---

## Expected Deliverables

The final analysis should include:

* Executive Summary
* Complete Package Audit
* Widget-by-Widget Review
* Public API Review
* Deprecation Matrix
* Migration Guide
* Breaking Change Report
* Naming Consistency Report
* Developer Experience Review
* Documentation Review
* Stability Assessment
* Final Recommendations
* Release Readiness Checklist

---

# Expected Quality

The analysis should resemble a professional audit performed before releasing a major open-source library version.

Recommendations must be:

* Objective
* Evidence-based
* Backward-compatible whenever possible
* Easy for existing developers to adopt
* Maintainable for future contributors
* Suitable for long-term production support

If any ambiguity, missing context, or uncertainty is encountered during the review, **stop and ask for clarification before making recommendations**. Do not make assumptions or introduce changes that are not justified by the current library architecture.

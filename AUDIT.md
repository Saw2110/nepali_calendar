# Pre-Release API & Architecture Audit

**Package:** `nepali_calendar_plus`
**Last published version:** 0.0.7
**Version under review:** 0.1.0 (unreleased)
**Scope:** every file in `lib/`, plus `pubspec.yaml`, `README.md`, `CHANGELOG.md` and `test/`

This is an internal pre-release review. The user-facing upgrade instructions live in
[doc/MIGRATION.md](doc/MIGRATION.md).

---

## Premise

Three facts frame every recommendation below. They are stated up front because
changing any of them changes the conclusions.

1. **0.1.0 is a compatible release.** It removes nothing. All 18 currently
   deprecated members remain callable, warning only.
2. **1.0.0 is the removal target.** Every `@Deprecated` annotation in the package
   either says so explicitly or should be made to.
3. **The baseline for "before" statements is 0.0.7**, the last published version.

---

## 1. Executive Summary

The package is in good structural shape. The 0.1.0 cycle has already done the
hard work: a date-keyed event index replaced linear scans, multi-event support
landed, the theme system arrived, the date picker was rebuilt, timezone handling
was corrected, and value equality was added to `NepaliDateTime`. The public
surface is broadly coherent and the widgets are individually well documented.

Three themes emerged. The first two were fixed before release; the third is
carried into 0.2.0.

**An inaccurate manifest.** `pubspec.yaml` declared `flutter: ">=1.17.0"` while
the code uses `Color.withValues` and `Flex.spacing` in 23 places across 10
files, both of which need Flutter 3.27. This was initially assessed as a
resolution hazard and that assessment was wrong: the `sdk: ^3.6.0` constraint
alongside it already implies Flutter 3.27, because Dart 3.6 ships with it. So
pub could not in fact have resolved onto an incompatible Flutter. The constraint
was corrected anyway — a manifest that misstates its own requirements is a
maintenance trap even when it happens to be covered by another line. *Fixed.*

**A cluster of silent no-ops.** Public parameters accepted and then discarded.
`NepaliCalendarStyle.copyWith` took `weekendType` and `weekStartType` and
dropped both. `HorizontalNepaliCalendar.textColor` and `selectedColor` were
never read — already deprecated, correctly. Code that looks like it configures
something and does not is the most expensive defect class for a library, because
the user debugs their own app first. *`copyWith` fixed.*

**An unfinished encapsulation boundary.** `lib/nepali_calendar_plus.dart`
re-exports `src/src.dart`, which in turn exports all 31 internal files. This is
the direct cause of seven widgets being public-but-deprecated, and the mechanism
is still active: any file added under `src/` becomes public API on the next
publish. Closing it is the single highest-leverage change available and it can be
done without breaking anyone. *Outstanding — 0.2.0.*

Nothing found here required an API removal in 0.1.0. The version is a minor bump
rather than a patch because of the timezone conversion fix, which changes which
day an existing app displays.

---

## 2. Complete Package Audit

### 2.1 Public surface inventory

| Category | Members |
|---|---|
| Widgets (supported) | `NepaliCalendar`, `NepaliYearCalendar`, `HorizontalNepaliCalendar`, `NepaliDatePicker` |
| Widgets (deprecated) | `CalendarCell`, `CalendarGrid`, `CalendarHeader`, `CalendarMonthView`, `EmptyCell`, `EventList`, `WeekdayHeader` |
| Widgets (undeprecated, should not be public) | `CalendarItem` |
| Functions | `showNepaliDatePicker` |
| Models | `NepaliDateTime`, `CalendarEvent`, `CalendarEventIndex`, `CalendarConfig`, `CalendarBuilder`, `CalendarCellData`, `WeekdayData` |
| Styling | `NepaliCalendarStyle`, `CellStyle`, `HeaderStyle` |
| Theme | `NepaliCalendarTheme`, `NepaliCalendarThemeData` |
| Controllers | `CalendarController` (abstract), `NepaliCalendarController` |
| Utilities | `CalendarUtils`, `MonthUtils`, `WeekUtils`, `NepaliNumberConverter` |
| Extensions | `DateTimeExtension.toNepaliDateTime` |
| Enums | `Language`, `TitleFormat`, `WeekendType`, `WeekStartType`, `NepaliDatePickerMode` |
| Typedefs | `OnDateSelected`, `SelectedDateCallback` |

### 2.2 Defects — outstanding after 0.1.0

D1, D2, D5 and D8 were fixed before release and are recorded in §2.3. The rest
are deferred to 0.2.0: none is a regression, and none blocks the release.

| ID | Finding | Location |
|---|---|---|
| D3 | `CalendarUtils.nepaliYears` is a public **mutable** `static final Map` holding **mutable** `List<int>`s. A caller can corrupt every date calculation in the package. This is the same defect class already fixed for `calenderyearStart`, whose doc comment explains exactly why mutability was dangerous — while the map it guards stayed mutable. | [calendar_utils.dart:144](lib/src/utils/calendar_utils.dart#L144) |
| D4 | `NepaliDateTime` validates its arguments with `assert`, so **release builds accept invalid dates silently** and fail later with a `RangeError` from an unrelated line. `DateTimeExtension.toNepaliDateTime` already does this correctly with `ArgumentError` — the two disagree. The assert message also says "1970-2250" while the check permits 1969. | [nepali_date_time.dart:21-28](lib/src/models/nepali_date_time.dart#L21-L28) |
| D6 | Theme resolution decides "did the caller customise appearance?" with `identical()` against canonical const defaults. Consequence: `cellsStyle: CellStyle()` **without `const` silently disables theming**, while `const CellStyle()` preserves it. The behaviour hinges on a keyword users treat as optional. | [nepali_calendar_theme.dart:411-414](lib/src/theme/nepali_calendar_theme.dart#L411-L414) |
| D7 | `WeekdayHeader` ignores `config.language` and always renders both scripts, hard-coding `Language.nepali` and `Language.english`. `NepaliYearCalendar` honours the same setting. Two widgets, one config, different behaviour. | [weekday_header.dart:86-120](lib/src/widgets/weekday_header.dart#L86-L120) |
| D9 | `NepaliCalendar.createState()` is declared `State<NepaliCalendar>` rather than `State<NepaliCalendar<T>>`. Compiles via covariance; imprecise. | [calendar_widget.dart:137](lib/src/calendar_widget.dart#L137) |
| D10 | `NepaliNumberConverter.toOrdinal` has an unreachable index 0 (`'सुन्ना'`, guarded out by `number < 1`) and index 9 is `नौ` ("nine"), not `नवौँ` ("ninth"). Unused inside the package. | [number_utils.dart:41-67](lib/src/utils/number_utils.dart#L41-L67) |

### 2.3 Resolved during this cycle

Found and fixed while preparing 0.1.0:

**Behaviour**
- Every month was padded to six week rows, so five-week months carried a full
  trailing row of the next month's dates. Now 5 or 6 as needed, with
  `CalendarConfig.sixWeekMonthsEnforced` as the opt-out.
- **Table rules were painted under the cells, not over them.** Both
  `_wrapWithTableBorder` helpers and the month view's outer frame used a
  `DecoratedBox` at its default `DecorationPosition.background`, so each cell's
  own background decoration painted over the lines. Today's cell, whose
  background is fully opaque, erased its right and bottom rules outright;
  selected cells tinted theirs; weekday header cells, having no background,
  kept all of theirs. That asymmetry is what made the header row and the date
  grid look like they were drawn to different rules. Measurement confirmed the
  geometry itself was exact: header label centres matched date cell centres to
  within 0.01px, and the header row height equalled the date row height.
- **Cell size ignored the month view's own padding.** `cellWidth` came from the
  full `LayoutBuilder` width, but the grid is laid out inside 8px of padding on
  each side, so real cells were narrower and therefore shorter than the budget
  assumed. At 400x800 the viewport was sized to 408px for 392px of content,
  leaving a 16px dead strip at the bottom of every page.
- The event list was centred in the space below the grid rather than
  top-aligned, so sparse months appeared to float. Caused by
  `AnimatedSwitcher.defaultLayoutBuilder` using `Alignment.center`.

**Defects (from §2.2)**
- **D1** — `flutter` constraint raised to `>=3.27.0`; `repository`,
  `issue_tracker` and `topics` added.
- **D2** — `NepaliCalendarStyle.copyWith` now applies `weekendType` and
  `weekStartType` through `config` instead of discarding them.
- **D5** — both uncompilable doc examples corrected: `NepaliCalendarBuilder` →
  `CalendarBuilder`, and `NepaliDateTime(2080, 1, 1)` → named arguments. The
  `event.dart` example also had unterminated code fences, which mangled its
  rendered dartdoc.
- **D8** — `CalendarItem` deprecated, bringing it in line with the other seven
  internal widgets.

**Documentation and packaging**
- `EventListData` was declared, exported, and referenced by nothing. Removed.
- Version references cited three different baselines (0.0.7, 0.0.8, 0.1.0).
  Normalised: 0.0.7 for "before", 0.1.0 for "new".
- All six "removed in a future version" deprecation messages now name 1.0.0, so
  every deprecation in the package states one horizon.
- `EventList` documented itself as a per-date list while rendering a whole
  month. Wording corrected; behaviour unchanged.
- `.pubignore` added so `AUDIT.md`, `TASK.md` and `folder_structure.md` are not
  published to pub.dev. It mirrors `.gitignore`, which pub otherwise stops
  consulting once a `.pubignore` exists.

---

## 3. Widget-by-Widget Review

### 3.1 `NepaliCalendar`

**Status:** Supported. The flagship widget.

**Strengths.** Event lookup is O(1) through a prebuilt `CalendarEventIndex`.
Layout is measured rather than assumed, so it survives being placed under a
toolbar. Builder hooks cover header, cell, weekday and event row. Row count is
now derived per month.

**Weaknesses.**
- The grid/event-list height split is a hard-coded `_gridHeightFraction = 0.62`
  with no way to change it. A user who wants a taller event area has no knob.
- The event-list cross-fade is a hard-coded 1 second — long for a list swap, and
  unconfigurable.
- `eventList` re-indexing keys off `identical()`, which is documented and
  defensible, but means a caller who mutates the list in place sees nothing
  change. Worth stating in the README rather than only in a code comment.
- No builder replaces the event **list container** — only individual rows. A user
  who wants different list layout has to rebuild the widget.

**Deprecated APIs.** `checkIsHoliday`, `headerBuilder`, `eventBuilder`.

**Recommendation.** Keep. Expose the height split and the fade duration in 0.0.9.
Consider an `eventListBuilder` hook; note that `EventListData` was designed for
exactly this and then removed as dead code, so the shape is already thought
through if it is ever wanted.

### 3.2 `NepaliYearCalendar`

**Status:** Supported. Added in 0.1.0.

**Strengths.** Tile framing is fully replaceable via `monthTileBuilder` while
keeping selection and events working. Year stepping is clamped to the bundled
data range and the arrows disable rather than vanish at the ends. Text-scale
aware.

**Weaknesses.** Six rows are fixed, correctly — twelve tiles must be uniform. It
reimplements `_leadingBlanks` and `_weekdayOrder` locally instead of using
`WeekUtils.normalizeWeekday`. It has no controller, unlike `NepaliCalendar`.

**Deprecated APIs.** None.

**Recommendation.** Keep. Deduplicate the weekday helpers.

### 3.3 `HorizontalNepaliCalendar`

**Status:** Supported, but the weakest widget in the package.

**Strengths.** Sizes to content rather than a viewport fraction, which fixed the
swallowed-taps bug. Theme-aware.

**Weaknesses.**
- Shows a fixed 7-day window, always starting 2 days before the selection. Not
  configurable, and not documented as a constraint.
- No controller, no `onMonthChanged`, no event support at all — it cannot show
  that a date has an event, unlike every other widget here.
- Leaks `CalendarItem` as public API (D8).
- Naming breaks the package convention: every other widget is `Nepali*`-prefixed
  (`NepaliCalendar`, `NepaliYearCalendar`, `NepaliDatePicker`), this one is
  `HorizontalNepaliCalendar`.

**Deprecated APIs.** `textColor`, `selectedColor` — both never read.

**Recommendation.** Keep, improve in 0.0.9. Add event support and make the window
size configurable. Do **not** rename in 0.1.0; if the name is ever aligned to
`NepaliHorizontalCalendar`, ship it as a new name plus a deprecated typedef.

### 3.4 `NepaliDatePicker` / `showNepaliDatePicker`

**Status:** Supported. Rebuilt in 0.1.0.

**Strengths.** The best-factored code in the package. All dimensions are named
constants in one block, bounds logic is isolated in `_Bounds`, layout in
`_Layout`, and every helper below the public widget is private. Bounds clamp
rather than throw. Embeddable via `showActions: false` + `onConfirm`, so it never
touches the `Navigator` unless asked to. Has semantic labels.

**Weaknesses.** Six rows fixed — correct here, so the dialog does not resize while
paging. Reimplements `_leadingBlanks`. Action labels are hard-coded Nepali/English
strings rather than going through a localisation seam.

**Deprecated APIs.** None.

**Recommendation.** Keep as the reference for how the rest of the package should
be structured.

---

## 4. Public API Review

| API | Verdict | Reasoning |
|---|---|---|
| `NepaliCalendar` | **Keep** | Core widget, healthy. |
| `NepaliYearCalendar` | **Keep** | New in 0.1.0, well built. |
| `NepaliDatePicker`, `showNepaliDatePicker` | **Keep** | Best-factored area of the package. |
| `HorizontalNepaliCalendar` | **Improve** | Missing event support and navigation callbacks; fixed 7-day window. |
| `NepaliDateTime` | **Improve** | Replace `assert` validation with `ArgumentError` (D4). Add `daysInMonth`. Delete the commented-out `implements DateTime` and `getDaysInMonth` blocks. |
| `CalendarEvent` | **Improve** | No `==`/`hashCode`, no `copyWith`, no `const` constructor. `additionalInfo` is `T?`, so documented usage needs `!`. |
| `CalendarEventIndex` | **Keep** | Correct, immutable, well documented. The model the rest should follow. |
| `CalendarConfig` | **Improve** | Add `==`/`hashCode`. Needed for cheap rebuild comparison and to retire the `identical()` heuristic in D6. |
| `CalendarBuilder` | **Improve** | Fix the non-existent `NepaliCalendarBuilder` in its own doc example (D5). |
| `CalendarCellData`, `WeekdayData` | **Keep** | Good builder payloads. |
| `NepaliCalendarStyle` | **Improve** | Fix `copyWith` (D2); add `==`/`hashCode`. |
| `CellStyle`, `HeaderStyle` | **Improve** | Add `==`/`hashCode`. Rename-with-alias `baseLineDateColor` (see §5). |
| `NepaliCalendarTheme`, `NepaliCalendarThemeData` | **Keep** | Correctly an `InheritedTheme` so it crosses route boundaries. Has value equality. |
| `CalendarController` | **Replace or narrow** | Documents an abstraction across "vertical, horizontal, etc." that has exactly one implementation. Either give the other widgets controllers or drop the claim. |
| `NepaliCalendarController` | **Improve** | `isProgrammatic: false` is effectively a no-op that mutates state without moving the view. `runCallback` defaults to `false`, so programmatic jumps fire no callbacks — defensible but surprising. |
| `CalendarUtils` | **Improve** | Make `nepaliYears` immutable (D3). Add a safe `daysInMonth`. Fix the `calenderyearStart` spelling with an alias. |
| `MonthUtils`, `WeekUtils` | **Keep** | Straightforward. Language defaults differ from `CalendarConfig` (see §5). |
| `NepaliNumberConverter` | **Improve** | Fix `toOrdinal` (D10). |
| `DateTimeExtension` | **Keep** | Correct and timezone-independent as of 0.1.0. |
| `Language`, `TitleFormat`, `WeekendType`, `WeekStartType`, `NepaliDatePickerMode` | **Keep** | Right shape. `Language` is a collision risk (see §5). |
| `OnDateSelected`, `SelectedDateCallback` | **Keep** | Fine. |
| 7 deprecated widgets | **Remove in 1.0.0** | Never intended as public API. |
| `CalendarItem` | **Deprecate in 0.1.0** | Internal detail of `HorizontalNepaliCalendar`; the sweep missed it (D8). |
| `EmptyCell` | **Remove in 1.0.0** | Renders `SizedBox.shrink()` and is referenced by nothing. Pure dead code. |

---

## 5. Naming Consistency Report

### 5.1 The `Nepali` prefix is applied inconsistently

Prefixed: `NepaliCalendar`, `NepaliYearCalendar`, `NepaliDatePicker`,
`NepaliDateTime`, `NepaliCalendarStyle`, `NepaliCalendarTheme`,
`NepaliCalendarThemeData`, `NepaliCalendarController`, `NepaliNumberConverter`,
`NepaliDatePickerMode`.

Unprefixed: `CalendarConfig`, `CalendarBuilder`, `CalendarEvent`,
`CalendarEventIndex`, `CalendarCellData`, `CalendarController`, `CalendarUtils`,
`CalendarItem`, `CellStyle`, `HeaderStyle`, `MonthUtils`, `WeekUtils`,
`Language`, `TitleFormat`, `WeekendType`, `WeekStartType`.

Most of these are harmless. Four are genuine collision risks in consumer code
because the names are generic enough to appear in any app: **`Language`**,
**`CellStyle`**, **`HeaderStyle`**, **`CalendarItem`**. `Language` is the most
likely to clash outright.

**Recommendation.** Do not rename in 0.1.0 — it is breaking and buys nothing this
cycle. If it is ever done, the non-breaking route is to introduce the new name and
keep the old one as a `@Deprecated` typedef, removing it at 1.0.0. Document the
convention now so new APIs stop widening the split.

### 5.2 One concept, three vocabularies

`NepaliCalendarStyle`/`CellStyle` and `NepaliCalendarThemeData` describe the same
things under different names:

| `CellStyle` | `NepaliCalendarThemeData` | Concept |
|---|---|---|
| `dotColor` | `eventDotColor` | event indicator |
| `baseLineDateColor` | `englishDateColor` | the small AD date |
| `weekDayColor` | `weekendColor` | weekend / holiday text |

`baseLineDateColor` is the worst of these — it names an implementation detail
(the cell's baseline) rather than what it colours. `weekDayColor` actively
misleads: it colours *weekend* days, not weekdays.

**Recommendation.** Align on the theme's vocabulary, which is the clearer of the
two. Introduce the new names as additional fields in 0.0.9 and deprecate the old
ones; remove at 1.0.0.

### 5.3 Default-language disagreement

`WeekUtils.formattedWeekDay`, `MonthUtils.formattedMonth` and
`NepaliNumberConverter.formattedNumber` all default to `Language.english` when
none is supplied. `CalendarConfig.language` defaults to `Language.nepali`. The
same enum has opposite defaults depending on which door you come in.

**Recommendation.** Leave the utility defaults alone (changing them is a silent
behaviour change) but document the asymmetry.

### 5.4 Spelling

`CalendarUtils.calenderyearStart` — "calender" should be "calendar", and the
casing should be `calendarYearStart`. Public `const`.

**Recommendation.** Add `calendarYearStart`, deprecate the misspelling, remove at
1.0.0.

---

## 6. Developer Experience Review

**Discoverability: good.** `CalendarBuilder` centralises the hooks and
`CalendarConfig` centralises behaviour. The two-object split (style vs config) is
a sound design and the doc comments explain it.

**Learning curve: moderate, with one cliff.** The `NepaliCalendarStyle` /
`NepaliCalendarThemeData` relationship takes real reading to understand, and the
`identical()` rule behind it (D6) is a genuine trap: whether theming survives
depends on whether the user wrote `const`. No amount of documentation makes that
discoverable — it needs value equality instead.

**Error messages: mostly absent.** The package relies on `assert` (D4) and on
`!` against `nepaliYears`, so out-of-range input tends to surface as a
`RangeError` or a null-check failure pointing at package internals rather than at
the caller's mistake. `_Bounds` in the date picker and the range errors in
`DateTimeExtension` show the better pattern already in use.

**Missing convenience.** There is no safe way to ask the most common question in
the domain — how many days are in a month. Callers must write
`CalendarUtils.nepaliYears[year]![month]`: a raw map index, a bang, and knowledge
that index 0 holds the year total rather than a month.

**Copy-paste hazards.** Two doc examples do not compile (D5). For a package whose
docs are its primary teaching surface, this is worse than a missing example.

**Recommendations, in priority order.**
1. Add `==`/`hashCode` to `CalendarConfig`, `NepaliCalendarStyle`, `CellStyle`,
   `HeaderStyle`, `CalendarEvent`; then replace the `identical()` heuristic.
2. Add `CalendarUtils.daysInMonth(year, month)` and
   `NepaliDateTime.daysInMonth`, both range-checked.
3. Convert `assert` validation to `ArgumentError`.
4. Fix the two uncompilable examples.
5. Make the grid/event height split and the fade duration configurable.

---

## 7. Documentation Review

**Present and good.** Per-member doc comments are unusually thorough, and the
"why" commentary — why `identical` rather than `==`, why `InheritedTheme` rather
than `InheritedWidget`, why bounds clamp rather than throw — is the kind of thing
most packages omit. Keep this.

**Gaps.**

| Gap | Notes |
|---|---|
| No migration guide | The CHANGELOG is currently the only upgrade path. Addressed by [doc/MIGRATION.md](doc/MIGRATION.md). |
| No deprecation table | Users have no single place to see what is going away or when. Addressed in §8. |
| Two horizons, no rule | 12 sites say "Will be removed in 1.0.0"; 6 say "removed in a future version". The vague ones are the *older* deprecations. Users cannot plan. Unify on 1.0.0. |
| `EventList` documented wrongly | It renders events for the whole **month**; `selectedDate` is documented as "date to filter events" and the call site comment says "Event list for selected date". The behaviour is intended; only the wording is wrong. |
| ~~README has no theming section~~ | **Incorrect finding.** The README has a "Theming and dark mode" section covering `fromContext`, placement above the Navigator, and the resolution order. Retracted. |
| ~~README has no `NepaliYearCalendar` section~~ | **Incorrect finding.** The README has a "Year view" section. Retracted. |
| README had two uncompilable examples | `NepaliDateTime(2080, 1, 1)` and `NepaliDateTime(2082, 9, 10)`, both positional on a named-only constructor. Same defect as D5 but in the README, which is the more visible surface. Fixed in 0.1.0. |
| No troubleshooting / FAQ | The three questions worth pre-empting: why does my theme not apply (`const`, D6), why does mutating `eventList` do nothing (identity check), what date range is supported (BS 1970–2100). |
| No documented supported range | The BS 1970–2100 / AD 1913–2044 bound appears only inside error strings. |
| `pubspec.yaml` metadata | Missing `repository`, `issue_tracker`, `topics`, `screenshots`. `homepage` points at a `.git` URL. All affect pub.dev score. |

---

## 8. Deprecation Matrix

All 18 members below remain functional in 0.1.0. Nothing is removed this release.

| Deprecated API | Status | Replacement | Migration | Compatibility | Notes |
|---|---|---|---|---|---|
| `CalendarCell` | Deprecated 0.1.0 | `CalendarBuilder.cellBuilder` | Medium | Removed 1.0.0 | Was never intended as public API |
| `CalendarGrid` | Deprecated 0.1.0 | `NepaliCalendar` | Medium | Removed 1.0.0 | Internal detail |
| `CalendarHeader` | Deprecated 0.1.0 | `CalendarBuilder.headerBuilder` | Easy | Removed 1.0.0 | Internal detail |
| `CalendarMonthView` | Deprecated 0.1.0 | `NepaliCalendar` | Medium | Removed 1.0.0 | Internal detail |
| `EmptyCell` | Deprecated 0.1.0 | — | No Change | Removed 1.0.0 | Renders `SizedBox.shrink()`; unused |
| `EventList` | Deprecated 0.1.0 | `CalendarEventIndex.eventsInMonth` | Easy | Removed 1.0.0 | Internal detail |
| `WeekdayHeader` | Deprecated 0.1.0 | `CalendarBuilder.weekdayBuilder` | Easy | Removed 1.0.0 | Internal detail |
| `NepaliCalendarStyle.showEnglishDate` | Deprecated | `CalendarConfig.showEnglishDate` | Very Easy | Removed 1.0.0 | Horizon unified in 0.1.0 |
| `NepaliCalendarStyle.showBorder` | Deprecated | `CalendarConfig.showBorder` | Very Easy | Removed 1.0.0 | Horizon unified in 0.1.0 |
| `NepaliCalendarStyle.language` | Deprecated | `CalendarConfig.language` | Very Easy | Removed 1.0.0 | Horizon unified in 0.1.0 |
| `HeaderStyle.weekTitleType` | Deprecated | `CalendarConfig.weekTitleType` | Very Easy | Removed 1.0.0 | Horizon unified in 0.1.0 |
| `NepaliCalendar.headerBuilder` | Deprecated | `CalendarBuilder.headerBuilder` | Very Easy | Removed 1.0.0 | Horizon unified in 0.1.0 |
| `NepaliCalendar.eventBuilder` | Deprecated | `CalendarBuilder.eventBuilder` | Very Easy | Removed 1.0.0 | Horizon unified in 0.1.0 |
| `NepaliCalendar.checkIsHoliday` | Deprecated 0.1.0 | `CalendarEvent.isHoliday` | Very Easy | Removed 1.0.0 | Return value was never read |
| `CalendarCellData.event` | Deprecated 0.1.0 | `CalendarCellData.events` | Easy | Removed 1.0.0 | Only ever exposed the first event |
| `CalendarCell.event` | Deprecated 0.1.0 | `CalendarCell.events` | Easy | Removed 1.0.0 | On an already-deprecated class |
| `HorizontalNepaliCalendar.textColor` | Deprecated 0.1.0 | `calendarStyle.cellsStyle` | Very Easy | Removed 1.0.0 | Never had any effect |
| `HorizontalNepaliCalendar.selectedColor` | Deprecated 0.1.0 | `cellsStyle.selectedColor` | Very Easy | Removed 1.0.0 | Never had any effect |

`CalendarItem` was added to this list in 0.1.0 (D8), and the six messages that
previously said only "a future version" now name 1.0.0. Every deprecation in the
package therefore states one horizon.

---

## 9. Breaking Change Report

### 0.1.0 — behaviour changes, no API removals

| Breaking Change | Impact | Migration Required | Severity | Recommendation |
|---|---|---|---|---|
| Months render 5 or 6 week rows instead of always 6; calendar height now varies by month | Visual. Anything below the calendar shifts as the user pages | Only if a constant height is required | Medium | Ship as default. Escape hatch: `CalendarConfig.sixWeekMonthsEnforced: true` |
| Event list is top-aligned instead of centred | Visual. Sparse months look different | No | Low | Ship. The previous behaviour was an unintended `AnimatedSwitcher` default |
| `EventListData` removed | Compile error if referenced | Delete the reference | Low | Ship. Nothing in the package or example used it |
| `NepaliDateTime` gained value equality | Identity comparisons now behave differently | Use `identical()` if identity was intended | Medium | Already shipped; documented on the member |
| `DateTimeExtension.toNepaliDateTime` is now timezone-independent | Dates shift by one day for users who had compensated manually | Remove any manual `-1 day` workaround | **High** | Already in CHANGELOG migration notes; must stay prominent |
| `CalendarUtils.isToday` resolves against Nepal time | "Today" changes for part of each day outside Nepal | No | Low | Correct behaviour for a Nepali calendar |
| `CalendarUtils.calenderyearStart` is now `const` | Assignment is a compile error | Stop assigning to it | Low | Assigning always corrupted state |
| `NepaliCalendar` no longer asserts `checkIsHoliday` alongside `eventList` | None | No | None | Relaxing a constraint cannot break a caller who met it |

The timezone change is the one that can silently produce wrong dates in a
consumer app that worked around the old bug. It needs to be the first thing in
the migration guide, not a bullet in a list.

### 1.0.0 — planned removals

All 18 deprecated members. Not in scope for this release; enumerated in §8 so the
scale is visible now.

---

## 10. Stability Assessment

| Risk | Severity | Detail | Recommendation |
|---|---|---|---|
| Blanket export | **High** | `src.dart` exports all 31 internal files, so every new internal file silently becomes public API. Already cost seven deprecations. | Replace with an explicit export list reproducing today's surface exactly. Non-breaking. |
| ~~Understated Flutter constraint~~ | Resolved | D1. Initially rated High on the assumption that pub could resolve onto an incompatible Flutter; it could not, because `sdk: ^3.6.0` already implies Flutter 3.27. | Fixed in 0.1.0: constraint raised to `>=3.27.0`. |
| Mutable calendar data | **High** | D3. A consumer can corrupt all date maths, and the corruption is untraceable. | `Map.unmodifiable` with unmodifiable inner lists. |
| Duplicated weekday logic | Medium | The Sunday/Monday switch is implemented in four remaining places: `WeekdayHeader._getWeekdayOrder`, `_CompactMonth._weekdayOrder`, `_CompactMonth._leadingBlanks`, `_DayGrid._leadingBlanks`. Two were unified into `WeekUtils.normalizeWeekday` in 0.1.0; the rest will drift. | Route all four through `WeekUtils`. |
| No value equality on config/style | Medium | Forces the `identical()` heuristic (D6) and prevents cheap rebuild comparison. | Add `==`/`hashCode`. |
| Hard-coded strings | Medium | Picker actions, month names, weekday names and numerals are all internal. Adding a third language means touching four files, and there is no seam for callers to supply their own. | Not urgent. Note as a constraint before someone requests it. |
| Unfulfilled `CalendarController` abstraction | Low | One implementation, documented as many. Extending it later to the other widgets may force signature changes. | Narrow the doc now or implement the others. |
| `assert`-based validation | Medium | D4. Release builds skip validation entirely. | `ArgumentError`. |
| No API-surface test | Low | Nothing fails if an internal type accidentally becomes public again. | Add a test asserting the exported symbol set. |

**Test suite:** 235 tests across 14 files, covering conversion, widgets, theming,
the picker, layout and responsiveness. Genuinely good coverage for a package this
size. Gaps: no controller tests for `jumpToToday`, no golden tests, no API-surface
test.

---

## 11. Final Recommendations

### Keep as-is
`NepaliCalendar`, `NepaliYearCalendar`, `NepaliDatePicker`,
`showNepaliDatePicker`, `CalendarEventIndex`, `NepaliCalendarTheme(Data)`,
`CalendarCellData`, `WeekdayData`, `DateTimeExtension`, all five enums, both
typedefs. These are correct, coherent and carry no known defects.

### Fixed for 0.1.0
D1, D2, D5, D8, the six vague deprecation horizons, and the `EventList`
documentation. All were small, low-risk, and all were either
wrong-as-documented or silently broken.

### Fix in 0.2.0
D3, D4, D6, D7, D10; value equality on config and style classes; `daysInMonth`;
the explicit export list; weekday-logic deduplication; configurable height split
and fade duration.

### Deprecated in 0.1.0
`CalendarItem` (D8) — the only member the earlier sweep missed. Done.

### Deprecate in 0.2.0 with aliases
`calenderyearStart` → `calendarYearStart`. `CellStyle.baseLineDateColor` →
`englishDateColor`. `CellStyle.weekDayColor` → `weekendColor`.
`CellStyle.dotColor` → `eventDotColor`. Each ships as a new field plus a
deprecated old one; nothing breaks.

### Remove in 1.0.0 only
All 18 members in §8.

### New standard APIs
These are what developers should use going forward, and what new documentation
and examples should show exclusively:

- `CalendarConfig` for all behaviour — never the top-level style properties.
- `CalendarBuilder` for all customisation — never the individual builder params.
- `NepaliCalendarTheme` + `NepaliCalendarThemeData.fromContext` for appearance,
  in preference to hand-built `NepaliCalendarStyle`.
- `CalendarEvent.isHoliday` for holidays — never `checkIsHoliday`.
- `CalendarCellData.events` for cell events — never `.event`.
- `CalendarEventIndex` for event lookup by day or month.
- `NepaliCalendarController` for programmatic navigation.

---

## 12. Release Readiness Checklist

**Blocking for 0.1.0 — all clear**

- [x] Raise `flutter:` constraint to `>=3.27.0` (D1)
- [x] Fix `NepaliCalendarStyle.copyWith` dropping `weekendType`/`weekStartType` (D2)
- [x] Fix the two uncompilable doc examples (D5)
- [x] Deprecate `CalendarItem` (D8)
- [x] Unify the six "a future version" messages on "1.0.0"
- [x] Correct the `EventList` month-vs-date documentation
- [x] Keep `AUDIT.md` and `TASK.md` out of the published archive (`.pubignore`)
- [x] Version bumped to 0.1.0; CHANGELOG leads with the date-conversion change
- [x] `flutter analyze` clean
- [x] `flutter test` green
- [x] `flutter pub publish --dry-run` passes
- [x] Publish from a clean git tree

**Also done for 0.1.0**

- [x] Version references normalised to 0.0.7 / 0.1.0
- [x] `EventListData` removed
- [x] Dynamic week-row count with `sixWeekMonthsEnforced` opt-out
- [x] Event list top-aligned
- [x] Migration guide written and linked from the README
- [x] `repository`, `issue_tracker`, `topics` added to `pubspec.yaml`; `.git` homepage fixed
- [x] README documents the supported date range

**Carried to 0.2.0**

- [ ] Explicit export list replacing the blanket `src.dart` re-export
- [ ] D3 — make `nepaliYears` immutable
- [ ] D4 — `ArgumentError` instead of `assert`
- [ ] D6 — value equality on config/style, retiring the `identical()` heuristic
- [ ] D7 — `WeekdayHeader` should honour `config.language`
- [ ] D9, D10
- [ ] README: theming and `NepaliYearCalendar` sections
- [ ] `CalendarUtils.daysInMonth` / `NepaliDateTime.daysInMonth`
- [ ] Route the four remaining weekday-order helpers through `WeekUtils`
- [ ] API-surface test

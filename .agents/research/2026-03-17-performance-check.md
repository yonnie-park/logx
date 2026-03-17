# Performance Analysis Report

**Date:** 2026-03-17
**Project:** FitFlex
**Scan Type:** Full Analysis
**Symptoms Reported:** Slow loading

## Executive Summary

The app has clean architecture with no memory leaks, proper `[weak self]` usage, and no energy concerns. The primary performance bottleneck is **sequential HealthKit fetching** — each of 20 workouts makes 2 serial async queries (40 total), which is the likely cause of slow loading. Secondary issues include DateFormatter allocations inside view computed properties (recreated on every render).

## Grade Summary

**Overall: B** (Memory A | CPU B | Energy A | SwiftUI C+ | Launch A | Database N/A)

## Positive Findings

- Proper `[weak self]` in all HealthKitManager closures (class context)
- No Timer leaks, no unremoved NotificationCenter observers
- No location tracking, no sub-second timers, no polling
- LazyVGrid used appropriately for calendar and stats grid
- GeometryReader used only in leaf views (RouteMapView, HeartRateGraph, WeeklyBarChart) — not nested in lists
- Clean app launch — no synchronous work in App init
- No heavy framework imports beyond what's needed
- Async/await used throughout with proper Task context

## Issue Rating Table

| # | Finding | Urgency | Risk: Fix | Risk: No Fix | ROI | Blast Radius | Fix Effort |
|---|---------|---------|-----------|-------------|-----|-------------|------------|
| 1 | Sequential HealthKit fetching — `fetchWorkouts()` loops through 20 workouts calling `fetchActiveKcal` + `fetchTotalKcal` serially (40 sequential async calls) | 🟡 HIGH | Low | Slow initial load, user-reported symptom | 🟠 Excellent | HealthKitManager | Small |
| 2 | DateFormatter() created in view computed properties — `CalendarView.monthLabel()`, `WrappedMonthChip.monthLabel`, `WrappedView.monthName()` recreate formatters on every render | 🟢 MEDIUM | Low | Unnecessary allocations during scrolling/interaction | 🟠 Excellent | 3 view files | Trivial |
| 3 | Non-lazy ForEach for workout list in MainView (line 112-116) — all 20 RecentWorkoutRow views are rendered upfront | 🟢 MEDIUM | Low | All rows rendered even if off-screen | 🟢 Good | MainView | Trivial |
| 4 | WrappedStats recomputes by iterating workouts multiple times — `totalActiveKcal`, `totalKm`, `totalHours`, `donutSlices`, `allHeartRateSamples` each iterate the full array | ⚪ LOW | Low | Redundant iterations over small dataset (max ~30 workouts/month) | 🟡 Marginal | WrappedStats | Small |
| 5 | `DispatchQueue.main.async` in ShareManager/WrappedView for photo save callbacks — legacy pattern, could use `@MainActor` | ⚪ LOW | Low | Works correctly, slightly harder to maintain | 🟡 Marginal | ShareManager, WrappedView | Small |

## Instruments Profiling Recommendations

| Finding | Instruments Template | What to Look For |
|---------|---------------------|------------------|
| #1 Sequential HealthKit fetching | Time Profiler | Long waits on `fetchActiveKcal`/`fetchTotalKcal` during initial load |
| #2 DateFormatter allocations | Allocations | `DateFormatter` object count during scroll — should be 0 with caching |
| #3 Non-lazy list | SwiftUI | View body invocation count for `RecentWorkoutRow` |

## Remediation Examples

### Finding #1: Sequential HealthKit Fetching (HIGH)

**Current code** (`HealthKitManager.swift:54-82`):
```swift
// Sequential — each workout awaits before next starts
for hkWorkout in hkWorkouts {
    let activeKcal = await self.fetchActiveKcal(for: hkWorkout)
    let totalKcal = await self.fetchTotalKcal(for: hkWorkout)
    let model = WorkoutModel(...)
    result.append(model)
}
```

**Optimized fix** — use `TaskGroup` for concurrent fetching:
```swift
let result = await withTaskGroup(of: WorkoutModel.self, returning: [WorkoutModel].self) { group in
    for hkWorkout in hkWorkouts {
        group.addTask {
            let activeKcal = await self.fetchActiveKcal(for: hkWorkout)
            let totalKcal = await self.fetchTotalKcal(for: hkWorkout)
            return WorkoutModel(
                id: hkWorkout.uuid,
                type: hkWorkout.workoutActivityType.name,
                date: hkWorkout.startDate,
                duration: hkWorkout.duration,
                activeKcal: activeKcal,
                totalKcal: totalKcal,
                distance: hkWorkout.totalDistance?.doubleValue(for: .meter()),
                heartRateSamples: [],
                routeCoordinates: []
            )
        }
    }
    var models: [WorkoutModel] = []
    for await model in group {
        models.append(model)
    }
    return models.sorted { $0.date > $1.date }
}
```

### Finding #2: DateFormatter Allocations (MEDIUM)

**Current code** (repeated in 3+ view files):
```swift
private func monthLabel() -> String {
    let formatter = DateFormatter()  // New allocation every render
    formatter.dateFormat = "MMMM"
    return formatter.string(from: month)
}
```

**Optimized fix** — use static cached formatters:
```swift
private static let monthFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "MMMM"
    return f
}()

private func monthLabel() -> String {
    Self.monthFormatter.string(from: month)
}
```

### Finding #3: Non-lazy Workout List (MEDIUM)

**Current code** (`MainView.swift:112-116`):
```swift
VStack(spacing: 10) {
    ForEach(workouts) { workout in
        RecentWorkoutRow(workout: workout)
    }
}
```

**Optimized fix**:
```swift
LazyVStack(spacing: 10) {
    ForEach(workouts) { workout in
        RecentWorkoutRow(workout: workout)
    }
}
```

## Performance Budgets

| Metric | Target | Current Estimate |
|--------|--------|-----------------|
| Cold launch | < 400ms | OK (clean init) |
| Warm launch | < 200ms | OK |
| Memory (idle) | < 50MB | OK (no leaks detected) |
| Initial data load | < 1s | Likely slow (40 sequential queries) |
| Frame rate | 60 fps | OK (no heavy render work) |

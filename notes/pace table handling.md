# Garmin Data Field: Time Delta Calculation with Negative Split Pacing

## Problem

The original implementation calculates the expected elapsed time using a simple proportion of race distance completed:

```monkeyc
function calcTimeDelta(correctedDistance as Float, elapsedTime as Float) as Float {
    var expectedTime = (correctedDistance / raceDistance) * (targetTime * 60);
    var timeDelta = elapsedTime - expectedTime;
    return timeDelta;
}
```

This works correctly when the target pace is constant throughout the race.

However, once a negative split pacing strategy is introduced, where the runner starts slightly slower than average pace and finishes slightly faster, the expected elapsed time is no longer linear. A runner perfectly following the pacing plan will appear to be "behind target" during the early stages of the race and only converge back to zero near the finish.

---

## Correct Approach

Instead of calculating expected time based on a linear distance-to-time relationship, calculate the expected elapsed time according to the same pacing profile used by the race plan.

The question becomes:

> "If the runner is following the pacing strategy perfectly, how much time should have elapsed at this distance?"

Then:

```text
timeDelta = actualElapsedTime - expectedElapsedTime
```

If the runner follows the pacing plan exactly, the time delta will remain close to zero throughout the race.

---

# Recommended Solution: Lookup Table

Given the limited resources available on Garmin devices, precomputing a lookup table at activity start is the best approach.

The pacing profile is known in advance and does not change during the activity.

## Benefits

- Fast runtime lookups
- No repeated integrations during screen updates
- Very low memory usage
- Accurate support for any pacing profile

---

# Step 1: Create the Table

Choose a distance interval.

For example:

```monkeyc
const TABLE_STEP = 0.05; // 50 metres (0.05 km)

var expectedTimeTable = [];
```

---

# Step 2: Generate Expected Times

Build the table once when the race target and pacing strategy are configured.

```monkeyc
function buildExpectedTimeTable() {

    expectedTimeTable.clear();

    var cumulativeTime = 0.0;
    var distance = 0.0;

    expectedTimeTable.add(0.0);

    while (distance < raceDistance) {

        // Use midpoint of segment for better accuracy
        var pace = getTargetPace(distance + (TABLE_STEP / 2.0));

        cumulativeTime += pace * TABLE_STEP;

        expectedTimeTable.add(cumulativeTime);

        distance += TABLE_STEP;
    }
}
```

---

# Step 3: Reuse Existing Pace Logic

The same pacing logic used elsewhere in the data field should be used when constructing the lookup table.

Example:

```monkeyc
function getTargetPace(distance as Float) as Float {

    var pct = distance / raceDistance;

    return averageRacePace + getPaceOffset(pct);
}
```

Where:

```monkeyc
getPaceOffset()
```

returns a positive value early in the race and a negative value later in the race.

The critical principle is:

> The exact same pace model used for pacing guidance must also be used to generate expected elapsed times.

---

# Step 4: Interpolate Between Table Entries

The runner's current distance will rarely line up exactly with a table entry.

For example:

| Distance | Expected Time |
|-----------|-----------|
| 5.00 km | 1525 s |
| 5.05 km | 1540 s |
| 5.10 km | 1555 s |

If the runner is at 5.07 km, interpolate between the surrounding values.

```monkeyc
function getExpectedTime(distance as Float) as Float {

    if (distance <= 0.0) {
        return 0.0;
    }

    if (distance >= raceDistance) {
        return expectedTimeTable[expectedTimeTable.size() - 1];
    }

    var indexFloat = distance / TABLE_STEP;

    var lowerIndex = indexFloat.toNumber().toLong();

    var fraction = indexFloat - lowerIndex;

    var lowerTime = expectedTimeTable[lowerIndex];
    var upperTime = expectedTimeTable[lowerIndex + 1];

    return lowerTime + ((upperTime - lowerTime) * fraction);
}
```

This is standard linear interpolation:

```text
expectedTime =
    lowerTime +
    (upperTime - lowerTime) × fraction
```

---

# Step 5: Update Time Delta Calculation

The original function becomes:

```monkeyc
function calcTimeDelta(correctedDistance as Float,
                       elapsedTime as Float) as Float {

    var expectedTime = getExpectedTime(correctedDistance);

    return elapsedTime - expectedTime;
}
```

---

# Worked Example

Assume:

```text
Race distance: 10 km
Target time:   50 minutes
Average pace:  300 sec/km (5:00/km)
```

Negative split strategy:

```text
First 5 km: 305 sec/km
Last 5 km: 295 sec/km
```

At 5 km:

### Original Linear Method

```text
Expected time
= 0.5 × 3000
= 1500 sec
```

### Actual Pacing Plan

```text
Expected time
= 5 × 305
= 1525 sec
```

If the runner follows the pacing plan perfectly:

```text
Elapsed time = 1525 sec
```

The original calculation reports:

```text
1525 - 1500 = +25 sec
```

which incorrectly suggests the runner is behind target.

Using the lookup table:

```text
Expected time = 1525 sec
Elapsed time  = 1525 sec
Time delta    = 0 sec
```

which is the desired behaviour.

---

# Memory Considerations

For a marathon:

```text
42.2 km / 0.1 km = 422 entries
```

Even a table every 50 metres only requires:

```text
42.2 km / 0.05 km ≈ 844 entries
```

This is very small and should be perfectly reasonable for a Garmin data field.

Recommended setting:

```monkeyc
const TABLE_STEP = 0.05;
```

This provides excellent accuracy while keeping both memory usage and runtime costs extremely low.

---

# Final Recommendation

1. Generate an expected-time lookup table once at startup.
2. Use the same negative-split pacing logic that drives pacing guidance.
3. Store cumulative expected elapsed time every 50m (or 100m).
4. Use linear interpolation to obtain the expected time at the current distance.
5. Calculate:

```monkeyc
timeDelta = elapsedTime - expectedTime
```

With this approach, a runner who follows the negative-split pacing strategy perfectly will remain at **0 seconds ahead/behind target throughout the race**, rather than appearing behind target during the slower early stages.
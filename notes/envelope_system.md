# RacePilot Envelope System - Design Summary

## Overview

The RacePilot pacing engine contains two separate concepts:

### 1. Pace Plan Execution

Measures how closely the runner is following the planned pacing strategy.

For a race using a negative split:

- Running the plan perfectly should show **0s delta** throughout the race.
- Positive values indicate drifting behind the plan.
- Negative values indicate running ahead of the plan.

This is the value displayed to the runner.

---

### 2. Achievement Envelope

Measures whether the runner is still operating within sensible limits for achieving the target time.

This is independent of the pacing plan and is based on:

- Recoverability if behind target.
- Excess aggressiveness if ahead of target.

The envelope determines the colour shown to the runner.

---

# Design Principle

The runner should see:

```text
GREEN
0s
```

when executing the pacing plan perfectly.

The pacing plan and the envelope therefore answer different questions:

| Metric | Question |
|----------|----------|
| Time Delta | "Am I following today's race plan?" |
| Envelope Colour | "Am I still in a sensible position to achieve the race goal?" |

This separation avoids confusion and gives a very simple user experience:

```text
Stay in Green
Stay near 0
```

---

# Delta Calculations

Two internal deltas exist.

## Plan Delta

Calculated against the negative split pacing profile.

```text
planDelta
=
actualElapsedTime
-
expectedElapsedTimeFromPlan
```

This is the value displayed to the runner.

Perfect execution:

```text
planDelta = 0
```

throughout the race.

---

## Goal Delta

Calculated against the target-time pacing line.

```text
goalDelta
=
actualElapsedTime
-
expectedElapsedTimeAtConstantPace
```

This is used only for envelope calculations.

The runner does not need to see this value.

---

# Envelope Philosophy

The envelope is not measuring:

```text
How many seconds ahead/behind am I?
```

Instead it measures:

```text
How healthy or unhealthy is my position
given where I am in the race?
```

The same time delta means different things at different points.

Examples:

```text
20s behind at 2km
```

Generally low risk.

```text
20s behind at 20km of a half marathon
```

Potentially a significant risk.

---

# Behind-Target Envelope

## Purpose

Defines:

```text
How far behind can I be
and still reasonably achieve the target?
```

---

## Step 1 - Calculate Theoretical Recoverability

Assume the runner has a maximum recoverable pace increase.

Example:

```text
5 seconds/km faster than target pace
```

Then:

```text
Maximum Recoverable Time
=
Remaining Distance
×
Maximum Catch-Up Pace
```

Example:

```text
10km remaining
×
5s/km
=
50s recoverable
```

---

## Step 2 - Apply Execution Factor

Theoretical recoverability is optimistic.

The execution factor shapes the curve.

Desired behaviour:

```text
Start of race
    Tight

Middle of race
    Relaxed

End of race
    Tight again
```

This creates the:

```text
GREY boundary
```

which represents the maximum sensible deficit.

---

## Step 3 - Apply Lower Envelope Factor

The grey boundary is then scaled to create a warning boundary.

```text
BLUE boundary
=
GREY boundary
×
Lower Envelope Factor
```

Meaning:

```text
BLUE
=
Recovery needed

GREY
=
Achievement becoming unlikely
```

---

# Ahead-Target Envelope

## Purpose

Defines:

```text
How far ahead can I be
before I am risking over-exertion?
```

The focus is not recoverability.

The focus is:

```text
Time gained per distance covered
```

because gaining time usually requires spending energy.

---

## Step 1 - Calculate Aggressive Gain

Conceptually:

```text
Distance Covered
×
Aggressiveness Allowance
```

This sets a maximum amount of early gain.

---

## Step 2 - Apply Aggressiveness Factor

The aggressiveness factor changes throughout the race.

Desired behaviour:

```text
Start
Very strict

Middle
Moderate

End
Much more relaxed
```

Creating the:

```text
RED boundary
```

which represents excessive aggression.

---

## Step 3 - Apply Yellow Factor

A warning threshold is derived from the red boundary.

```text
YELLOW boundary
=
RED boundary
×
Yellow Factor
```

Meaning:

```text
YELLOW
=
Be careful

RED
=
Potentially over-cooking the race
```

---

# Scaling Across Race Distances

The envelope system should not be based on kilometres.

Instead it should be based on race completion percentage.

---

## Progress Definition

```monkeyc
progress =
    correctedDistance / raceDistance;
```

Where:

```text
0.0 = Start

0.5 = Halfway

1.0 = Finish
```

---

## Why Use Progress?

This allows the same envelope behaviour to scale naturally to:

- 5K
- 10K
- Half Marathon
- Marathon

without redesigning the model.

Only parameters such as:

```text
Catch-up Pace

Aggressiveness Allowance
```

may need adjustment.

---

# Curve Definition

Rather than storing envelope values at fixed distances, define curve shapes using control points.

Example:

```monkeyc
const EXECUTION_CURVE = [
    [0.00, 0.10],
    [0.20, 0.20],
    [0.50, 0.60],
    [0.75, 0.50],
    [0.90, 0.30],
    [1.00, 0.00]
];
```

These values are examples only.

---

# Interpolation

Envelope factors are generated using linear interpolation between control points.

Requirements:

- Simple to implement.
- Lightweight on Garmin devices.
- Easy to tweak through testing.
- Scales automatically to any race distance.

---

# Colour Classification

Conceptually:

```text
Ahead Side

RED
    Too aggressive

YELLOW
    Warning

GREEN
    Healthy

BLUE
    Warning

GREY
    Recovery becoming difficult

Behind Side
```

Or whichever colour ordering is ultimately chosen.

---

# Relationship to Negative Split Plans

A key decision was reached:

## Displayed Delta

Should continue to use the planned pacing profile.

If the runner follows the plan exactly:

```text
0s
```

throughout the race.

---

## Envelope Boundaries

Should remain based on target-time achievement and recoverability.

This is intentional.

The envelope answers:

```text
Can I still achieve my goal?
```

while the displayed delta answers:

```text
Am I following today's plan?
```

---

# Resulting User Experience

When the runner executes correctly:

```text
GREEN
0s
```

When drifting slightly:

```text
GREEN
+12s
```

When recovery will soon be required:

```text
BLUE
+25s
```

When significantly outside reasonable limits:

```text
GREY
+40s
```

or

```text
RED
-40s
```

depending on the direction of deviation.

This provides a very simple race-day experience:

```text
Stay near zero.
Stay in green.
Trust the plan.
```

while allowing all complexity and planning to remain hidden behind the scenes.




# Required Calculations from Excel

## Grey envelope
Calculate 'recoverable' time from max allowed pace delta (2% of target pace) and remaining race distance

`Recoverable Time = MaxPaceDelta * RemainingDistance`

Then multiplied by execution factor interpolated from array.


## Blue envelope
Calculated from grey envelope and a further factor 


## Red envelope
Calculated from max allowed pace delta (2% of target pace) * factor

Factor is 1.0 for most of race but moves out towards end of race


## Yellow envelope
Calcualted from red envelope * factor

At start factor is 0 for first 10%, then ramps from 0.0 to 0.5 at 50% race distance. Factor is 0.5 from 50% to 75% distance and then ramps to 0.70 which it continues with until race end.
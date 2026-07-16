# RacePilot // Technical Design Document

## Architecture and Data Flow

### High-level module structure

```
RacePilot
├── RaceProfile
├── RaceState
├── DistanceCorrector
├── PhaseManager
├── TimeDeltaCalculator
├── PaceEngine
├── HeartRateEngine
├── GuidanceEngine
├── AlertManager
└── DisplayRenderer
```

### RaceProfile

`RaceProfile` holds the configuration of the target race plan:

- Race distance
- Target time
- Phase distances or start points
- HR targets
- Aggression settings
- Gel frequency

Initially hard-coded but eventually will end up as configuration items in ConnectIQ app

### RaceState

`RaceState` holds the information on "Where am I currently in the race plan?"

- Corrected Distance
- Elapsed time
- Current HR
- Race Phase
- Ahead/Behind value
- Average race pace
- Stable pace
- Execution state
- Guidance

This object will be updated by all other relevant engines

### DistanceCorrector

`DistanceCorrector` corrects GPS distance based on manual lap presses at race markers.

Inputs are GPS distance and lap button press.

Output is Corrected Distance - this is the distance used by all other engines

### PhaseManager

`PhaseManager` determines which of the four phases the race is currently in:

- Controlled Start
- Main Race
- Final Push
- Empty the Bucket

Input is corrected distance and phase distances.

Output is current race phase.

### TimeDeltaCalculator

`TimeDeltaCalculator` calculates the ahead/behind value.

Inputs are corrected distance, elapsed time, and race plan

Outputs are target elapsed time, actual elapsed time, and delta

### PaceEngine

`PaceEngine` calculates and determines the current position in the pace envelope.

Core outputs are:

- Target pace (from total distance, target time, and race plan)
- Equivalent average pace (Based on time delta and elapsed race distance)
- Pace offset (Based on target pace, equivalent average pace, and filtered current pace)
- Maximum sustainable pace (from aggression settings and target pace)
- Envelope colour (based on pace offset compared to maximum sustainable pace and equivalent average pace)

Later updates will add:

- Stable pace (based on derivation of current pace)
- Pace trend (based on stable pace over time)
- Future projection (based on pace trend and remaining race distance)

### HeartRateEngine

`HeartRateEngine` calculates HR envelope

Inputs are current HR, current phase, and HR targets per phase

Output is the current HR envelope colour

### GuidanceEngine

`GuidanceEngine` is the core function that outputs guidance to the runner.

Inputs are Pace Envelope Position, HR envelope position, Pace trend, and Race phase

Output is a command to the runner, e.g. Hold, Increas Slightly, Ease Slightly, Ignore HR, Push, etc

### AlertManager

`AlertManager` handles alerts for gels and/or any other piece of information to highlight to the runner.

Initially managing only gel strategy, inputs are Gel frequency and elapsed time.

Output is a message to the display and/or haptic engine

### DisplayRenderer

`DisplayRenderer` takes inputs of Pace Envelope, Guidance output, HR envelope, and Alert output and renders them accordingly on screen



## I/O Responsibilities for Each Module

## Core Data Structures

## Algorithms

### Pace Envelope

The Pace Envelope algorithm determines, for the given moment in the race plan, whether the runner is successfully executing that plan or is pushing too hard, or not enough. The current state is calculated dynamically based on the amount the runner is ahead/behind for the given distance. This current state is then compared to a dynamically calculated upper and lower envelope to determine if the runner is pushing too hard, not enough, or just right. This envelope is not constant throughout the race and will vary based on the elapsed distance and the race phase, with the aim to guide the runner to start the race in a controlled manner and then push at the end, whilst keeping a steady mid section.

The upper and lower envelopes use differnt calculations for the current state of the runner.

#### Upper envelope calculation

Current state is calculated as:

`(TargetElapsedTime - ActualElapsedTime) / CorrectedActualElapsedDistance`

> This implies that a positive value is AHEAD and negative value is BEHIND

This gives the average difference in pace to the planned target pace for the given distance, e.g.:

- Runner is 20s ahead at 20km = `20s / 20km = 1s/km` => Indicates runner hasn't been pushing too hard
- Runner is 20s ahead at 2km = `20s / 2km = 10s/km` => Indicates runner is pushing too hard

The upper envelope is used to determine whether a runner is pushing too hard too early in the race.

At a basic level the upper envelope is a constant value defined by the runner in the datafield settings of how many s/km faster than target they are happy to stretch to and still be within their target race plan - e.g. the runner will give a value of 5s and target pace is 4:50/km means they would be happy at an average of 4:45/km for the race.

This constant value is then factored by a curve of 'aggressiveness' against distance. This curve will have values < 1 in the early stages of the race and > 1 at later stages to encourage the runner to hold back somewhat in the early stages but give 'green headroom' to accelerate in the latter stages.

#### Lower envelope calculation

Current state is calculated as:

`(TargetElapsedTime - ActualElapsedTime) / (RaceDistance - CorrectedActualElapsedDistance)`

> This implies that a positive value is AHEAD and negative value is BEHIND

The key difference to the upper envelope calculation is that the delta time is divided by the **remaining** distance - this gives an indication of the increase in pace required to hit target time, e.g.:

- Runner is 20s behind at 2km = `-20s / (21-2)km ~= -1s/km => Indicates runner only nominally needs to increase speed for the remainder of the race
- Runner is 20s behind at 18km = `-20s / (21-18)km ~= 6s/km => Indicates runner may need to push too hard (if, e.g. max allowed increase is 5s then too fast)

As with the upper envelope, the lower envelope uses the same 'Max allowed pace delta' - *multiplied by -1* - but framed as would I be happy to increase my pace to this amount for the rest of the race in order to win back my time. Likewise, a factor curve - independent to the upper envelope - is used to widen the envelope earlier in the race and tightening up later in the race to take in to account tiredness, etc.

## Update Cycle

## Module Communication


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

## Update Cycle

## Module Communication


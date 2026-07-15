# RacePilot – Design Summary

I'm designing a Garmin Connect IQ data field for my own Garmin Forerunner 165 called **RacePilot**.

## Overall Philosophy

RacePilot is **not** intended to show more running data. Its purpose is to **reduce the mental load of racing** by interpreting the available data and guiding race execution.

The guiding principle is:

> **Only show information that helps the runner make the correct decision right now.**

The runner should not need to mentally interpret pace, HR or time deltas during the race. The data field should perform that interpretation and present simple, intuitive feedback.

The field is therefore a **race execution engine**, not just a pacing screen.

---

# Core Features

## Race Profile

Before the race, the runner configures:

* Race distance
* Target finish time
* Controlled start distance
* Main race section
* Final push distance
* Empty the bucket distance
* Main race HR target
* HR offsets for the different phases
* Gel strategy
* Maximum sustained pace offset (see below)

---

## Race Phases

The race progresses through four phases.

### Controlled Start

Purpose:

Prevent over-excitement and conserve energy.

Characteristics:

* Target pace deliberately slower than race average
* Conservative HR limit
* Minimal display
* No ahead/behind shown
* Main focus is HR and 1 km average pace

---

### Main Race

Purpose:

Execute the race plan.

Display:

* Ahead/behind
* 1 km average pace
* HR

HR limits become the normal race limit.

---

### Final Push

Purpose:

Begin using any saved energy.

Same display as Main Race.

HR limits relax.

Acceptable pace envelope also relaxes.

---

### Empty the Bucket

Purpose:

Use everything left.

Display simplifies to:

* Ahead/behind only

HR guidance removed.

No concept of "too fast".

---

# Heart Rate Guidance

Rather than Garmin HR zones, HR is compared with the target HR for the current phase.

Colours represent actions rather than zones.

Grey/Blue:
Increase effort.

Green:
Hold current effort.

Yellow:
Slightly above target.
Acceptable briefly but don't increase effort further.

Red:
Above planned effort.
Ease off (except in final phase).

The HR target changes automatically as race phases change.

---

# Ahead / Behind

The numerical ahead/behind value remains a simple cumulative time difference.

For example:

+12 s

or

-8 s

The **number itself is never modified**.

Only its colour changes.

---

# Colour Philosophy

The number is descriptive.

The colour is prescriptive.

Example:

+12 s (green)

means

"This amount ahead is appropriate at this stage of the race."

rather than

"You are ahead."

---

# Colour Algorithm

The colour should **not** depend on absolute seconds ahead or behind.

Instead it should be based on the equivalent average pace deviation.

Example:

+15 s after 2 km

means approximately

7.5 s/km too fast.

Whereas

+15 s after 18 km

means

less than 1 s/km too fast.

Same number.

Different colour.

---

# Acceptable Execution Envelope

Rather than manually configuring colour bands, the colour should come from an execution model.

The runner provides only one primary pacing parameter:

Maximum sustained pace offset.

Example:

Target pace:
4:56/km

Maximum sustained pace:
4:51/km

Meaning:

"I'm happy averaging 5 seconds/km faster than target if necessary."

Everything else should be derived from this.

---

## Upper Envelope

Question:

"Have I been using too much energy?"

Based on:

Equivalent average pace achieved so far.

Compared against:

Maximum sustained pace offset.

If outside:

Yellow then Red.

---

## Lower Envelope

Question:

"Can I still realistically hit my target?"

Calculate:

Required average pace for the remaining distance.

Compare with:

Maximum sustainable pace for the remainder.

If still achievable:

Green.

If not:

Grey (increase effort).

This means the lower boundary automatically tightens as the finish approaches.

---

# Dynamic Aggression Curve

The maximum sustained pace offset should not necessarily remain constant throughout the race.

Instead it should be multiplied by a weighting curve.

Example behaviour:

Early race:

Very conservative.

Middle race:

Normal.

Late race:

Increasingly willing to accept faster sustained pacing.

This naturally widens the acceptable envelope later in the race without manually configuring multiple bands.

This weighting should ideally be continuous rather than changing abruptly at phase boundaries.

Race phases mainly control display and HR behaviour.

The aggression curve controls pace judgement.

---

# Distance Correction

The runner presses Lap at known kilometre markers.

RacePilot adjusts its internal corrected distance.

All pacing calculations then use corrected distance rather than GPS distance.

---

# Lap Marker Alerts

RacePilot alerts when the next kilometre marker should be approaching.

Purpose:

Prompt the runner to press Lap for distance correction.

---

# 1 km Average Pace

Displayed because it is more stable than instant pace.

Used for pacing decisions.

---

# Last Lap Pace

Available as an additional metric if useful.

---

# Gel Reminders

RacePilot provides configurable fuelling reminders.

Examples:

* Every 30 minutes
* Every 7 km
* Custom schedule

The runner should not need elapsed time displayed purely for fuelling.

---

# Display Philosophy

The display should evolve throughout the race.

Early:

Prevent mistakes.

Middle:

Execute plan.

Late:

Encourage commitment.

Final:

Focus only on finishing as strongly as possible.

---

# Future Ideas (not Version 1)

Potential future enhancements include:

* GAP-aware pacing or hill-adjusted execution envelopes
* Terrain-aware tolerance changes
* Different aggression curves for different race types
* Course profiles

These should not be part of the initial implementation.

---

# Core Design Principle

RacePilot should answer only one question:

> **"Given my race plan and where I am right now, what should I do next?"**

Every displayed metric, colour and alert should support that objective.

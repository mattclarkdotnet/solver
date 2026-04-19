# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by researching real-device sideloading and then implementing the first practical USB workflow using the better of Xcode UI or command-line tools.

## Objective
- Ship a repeatable developer-phone sideload flow for Solver over USB, with the plan explicitly favoring Xcode UI as the first supported path if research confirms it is the most reliable way to pair the device, satisfy signing requirements, install the app, and verify it launches.

## Assumptions
- The first slice should optimize for reliability and successful installation on the developer's phone, not for automation depth.
- Apple’s documented Xcode device workflow should take precedence over a command-line-first approach unless the command-line tooling clearly offers an equally reliable path for pairing, signing, installation, and launch.
- If command-line tools are still useful after pairing, they can be captured as optional follow-on commands, but they should not be the primary supported path for this slice.
- This slice is about local developer deployment to one connected phone over USB, not general distribution, TestFlight, or App Store delivery.

## Scenario mapping
- `Choose the primary sideload workflow from research`: GIVEN the roadmap asks whether USB sideloading should use Xcode UI or command-line tools, WHEN the implementation plan is prepared, THEN it records the researched recommendation explicitly instead of leaving both paths equally implied.
- `Prepare a connected phone for local development installs`: GIVEN the developer connects their phone by USB, WHEN they follow the documented setup flow, THEN the device becomes eligible for local Solver installs with the required pairing, signing, and Developer Mode steps made clear.
- `Install and launch Solver on the developer phone`: GIVEN the phone is prepared for development installs, WHEN the selected sideload workflow is followed, THEN Solver builds for the physical device, installs successfully, and launches on that phone.
- `Record the practical fallback path`: GIVEN Apple’s command-line tools can help after pairing or for later automation, WHEN the slice is documented, THEN those commands are captured as a secondary path without replacing the primary Xcode-first workflow.

## Exit criteria
- Update the roadmap and design/testing documentation to state the chosen first-class sideload workflow and why it was selected.
- Document the required prerequisites for phone sideloading, including USB connection, pairing, signing/team setup, and Developer Mode.
- Prove the chosen workflow by building Solver for a real iPhone destination, installing it, and confirming it launches on the developer's connected phone.
- Capture any viable command-line follow-up commands only as secondary guidance if they help after the primary Xcode-based setup is complete.
- Add or update test/documentation artifacts as needed so the repo reflects the shipped device-deployment workflow accurately.

## Promotion rule
- Promote this plan when the repo clearly records the researched workflow choice, the developer can follow the documented USB sideload path to get Solver installed and launched on their phone, and the docs are updated so the next roadmap item can start from a known-good real-device deployment baseline.

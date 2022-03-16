# spaniel

A Flutter based frontend for PIFS

## Getting Started

1. Download and set up Flutter
2. Launch the app
3. ???
4. Profit

# Code style

## The Basics

 * All strings must use "double quotes" unless otherwise required.

## File Structure

 * All **Spaniel** related classes, that is, frontend related classes, must be prefixed by SP, and belong under the `spaniel` folder.
 * All **Foxhound** related classes, that is, those that provide interactivity with the Foxhound backend, must be prefixed by FX, and belong under the `foxhound` folder.
 * Objects relating to a shared data layer between the Spaniel and Foxhound modules belong in the `pifs` folder and must be prefixed with Pifs.
 * Miscellaneous classes that may be used by both Spaniel and Foxhound components are stored in an appropriate root level folder, and may not be prefixed.
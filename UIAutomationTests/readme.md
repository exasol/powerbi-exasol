# UI Automation Tests

## Goals
Provides a way of automatically testing the Exasol PowerBI Connector
- It can be run from the .sln file using Test -> Run All Tests.
- Can also be ran from a CLI using "dotnet test" in the solution or test project folder.

## Project
.NET Core Project (3.x)
##Libraries and frameworks used
- FlaUI (for UI automation)
- xUnit (for test setup, + console runner and visual studio runner)

## Current todos:
- Elaborate tests (highest prio) (WIP)
- provide configuration in a config file eventually (done)

## Data used for the integration tests
- adventureworks conversion by T.B.
- "TEST": an empty schema
- the originally named schema 'MORETESTS' described in MORETESTS.SQL


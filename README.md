# trip-analyzer

A fast C++17 analyzer for ride-share trip data. It reads a CSV of trips, counts trips per pickup zone and per (zone, hour) slot, and returns the busiest zones and time slots. It is built to stay correct on messy input and to stay fast on millions of rows.

Built as a team term project for a Data Structures and Algorithms course.

## What it does

Input is a CSV with a header row:

```
TripID,PickupZoneID,PickupTime
1,Z1,2024-01-01 10:30
2,Z2,2024-01-01 11:05
```

- `topZones(k)`: the `k` zones with the most trips, ordered by count (descending), then zone ID (ascending).
- `topBusySlots(k)`: the `k` busiest (zone, hour) pairs, ordered by count, then zone ID, then hour.

## How it works

**One pass, O(n) aggregation.** Every valid row updates a single `unordered_map<string, ZoneStats>`. Each `ZoneStats` holds the zone's total and a fixed `array<long long, 24>` of hourly counts, so one hash lookup per row updates both statistics.

**Sorting only the results.** Sorting happens once, on the aggregated keys rather than on the rows: `O(m log m)` where `m` is the number of unique zones or slots. A comparator with explicit tie-breakers makes the output deterministic.

**A parser that never crashes.** Real data is dirty, so the parser walks each line character by character with an `inQuotes` flag. Commas inside quotes (`"Zone, A"`) don't split fields. Rows with missing fields, empty zones or a broken timestamp are skipped instead of stopping the run.

**Cheap hour extraction.** Instead of a full date parser, it reads the two digits after the space in `PickupTime` and checks they are in `0-23`.

## Build and run

Requires a C++17 compiler (g++ or clang++).

```bash
make run    # builds and runs on SmallTrips.csv
make test   # builds and runs the Catch2 test suite
```

Without `make`:

```bash
g++ -std=c++17 -O2 -I. main.cpp analyzer.cpp -o app && ./app
g++ -std=c++17 -O2 -I. test_trip_analyzer.cpp analyzer.cpp catch_amalgamated.cpp -o tests && FAST=1 ./tests
```

The tests cover malformed rows, boundary hours, tie-breaking and case sensitivity, plus performance tests with hundreds of thousands of unique zones that an O(n²) solution would fail.

## Project layout

```
analyzer.h / analyzer.cpp   # TripAnalyzer: parsing, aggregation, ranking
main.cpp                    # demo driver with timing
test_trip_analyzer.cpp      # Catch2 tests
catch_amalgamated.*         # Catch2 v3 (Boost Software License 1.0)
SmallTrips.csv              # sample data
```

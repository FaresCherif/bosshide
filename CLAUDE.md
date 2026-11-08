# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

BossHide is a simple platformer. The player must reach the end of the level without being spotted, while doing tasks and actions along the way. In the story, an employee is trying to reach the toilets without being seen by the boss.

The project uses Godot 4.3 with the GL Compatibility renderer. `Game.tscn` (`game/game.gd`) is the main scene: it loads the levels listed in `Game.LEVELS` one at a time as a child named `Niveau`, shows "Level n/N" at the top, and keeps each level's score (`game/level_sequence.gd`, replaying a level replaces its score). After a success, Enter (`next_level` action) loads the next level and R replays the same one; after a game over, R replays it. After the last level, an end screen shows the total score and R starts again from level 1.

Each level is its own scene in `levels/` using `level/level.gd`, which emits `succeeded(score)`, `restart_requested` and `next_requested` for the game. A level must contain `Player`, `Arrivee` (goal) and `Interface` (an instance of `level/hud.tscn`, which holds the messages, timer and panels). Desks and managers are found by group (`desks`, `managers`, `patrolling_managers`, set in their scenes), so a level can hold any number of them. The key and door (`Cle`, `Porte`), post-it and keypad door (`PostIt`, `PorteDigicode`) and colleague (`Collegue`) are optional, with at most one of each per level. To add a level, create a scene in `levels/` with those nodes and add its path to `Game.LEVELS`; `tests/unit/test_levels.gd` checks every listed level. `levels/level_02.tscn` is a short placeholder (one manager, two desks) until the real levels are built in M3.

The description below is level 1 (`levels/level_01.tscn`): a level with the player (`player/`), a manager (`manager/`), two walls, a visual floor and a goal zone. The player starts at the left edge, only moves left and right for now, and the camera follows it. Reaching the goal zone near the right wall shows a success message and freezes the player. The manager stands in the background in the middle of the level and alternates 10 seconds facing the camera and 5 seconds turned away. While facing, they scan the three thirds of the zone around them, 2 seconds each, in the order left, center, right, center, left; being in the watched third shows a game over message, with the same freeze and restart. An arrow above them sweeps smoothly along an arc to show the scan coming, and reappears 1 second before they turn back to face the camera. Two desks (blue rectangles) sit inside that zone: pressing E on one puts the player in a working state where they stay still and the manager can't spot them; pressing E again or a fresh press of a move key ends it. A second, patrolling manager walks back and forth across the same zone and spots the player in a short area in front of it, unless the player is working. A key sits on the left desk: the first press of E there picks it up without working, and a "Key" indicator shows while the player carries it. A locked door between the managers' zone and the goal blocks the way; pressing E against it with the key opens it (the door disappears and the key is used up). Before the managers' zone, a post-it near the start shows a random 4-digit code while the player stands in front of it after pressing E, and a second door has a keypad: E against it opens a panel where the player types the code (top-row digits by physical position, or the numpad; Backspace erases, Enter confirms, Esc or E closes). The player can't move while the panel is open, but the game keeps running. The right code opens the door; a wrong one costs 100 points, shows "Wrong code" and attracts the patrolling manager, who walks to the keypad even outside their limits, waits 3 seconds and goes back to patrolling. Just inside the zone, a colleague (green) stops the player the first time they walk into them and asks a random office multiple-choice question (`level/quiz_questions.gd`), answered with 1, 2 or 3. While the question is shown the player can't move and neither manager can spot them. A wrong answer costs 100 points and makes the patrolling manager rush to the colleague at twice their speed; after answering, the colleague no longer blocks. A timer in the top right runs from the start of the level and stops at the goal or on game over; reaching the goal shows the time and a score of 1000 minus 10 points per second (never below 0), and a game over shows no score. The installed Godot is the Mono build and `project.godot` has an assembly name, but the project has no C# code; the existing scripts are GDScript.

`ROADMAP.md` lists the milestones, planned features and open questions. Read it when the user gives a new task, and update the statuses there once a feature is done.

## Commands

Tests use GUT 9.4.0 (`addons/gut/`), configured by `.gutconfig.json`. It picks up `test_*.gd` files anywhere under `res://tests/`.

```powershell
# Run all tests headless (exit code 0 = success)
.\run_tests.ps1

# Run one file, or only the tests in it whose name contains a string
$godot = "F:\informatique\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64_console.exe"
& $godot --headless --path . -s "res://addons/gut/gut_cmdln.gd" -gtest=res://tests/unit/test_scene.gd
& $godot --headless --path . -s "res://addons/gut/gut_cmdln.gd" -gtest=res://tests/unit/test_scene.gd -gunit_test_name=instantiates
```

`run_tests.ps1` uses the path above unless `GODOT_BIN` is set. Use the `_console.exe` binary so that output and exit codes reach the shell.

The script runs `--import` first because it registers `class_name`s such as `GutTest`. When calling Godot directly after a fresh clone or after adding an addon or a new `class_name`, run this first:

```powershell
& $godot --headless --path . --import
```

To launch the game for about 2 seconds and list any errors (no output = no errors):

```powershell
& $godot --path . --quit-after 120 *>&1 | Out-String -Stream | Select-String "ERROR"
```

Always check the logs: Godot exits with code 0 even after a script error. `--quit-after` counts frames.

## Conventions

- Tests extend `GutTest` and live in `tests/unit/`. Wrap instantiated nodes in `autofree()` so they don't leak.
- Comments and assertion messages are in French, written without accents.
- In-game text is in English by default.
- `.gitattributes` normalizes text files to LF.
- `addons/gut/` is third-party code, so don't edit it. The test suite depends on it.
- `run/main_scene` in `project.godot` points to `res://Game.tscn`. `tests/unit/test_scene.gd` and `tests/unit/test_level.gd` each hold that path in their own constant, and `test_level.gd`, `test_level_02.gd` and `test_game.gd` hold the paths of the scenes they load, so update them if a scene moves.

## Rules

- Reply to the user in French.
- Never commit without the user's validation.
- Keep logic separate from the interface so each can be tested on its own:
  - Logic (rules, detection, task state) goes in classes that don't depend on the scene tree and can be tested alone.
  - Nodes only handle display and input.
  - Interface tests check that scenes instantiate and that signals are connected.
- Write at least one test for each new feature.
- Never weaken or delete a test to make it pass. If a test looks wrong, or you are stuck, stop and ask the user.

## Cycle

For each new feature:

1. The user gives a task.
2. Claude enters plan mode and asks all the questions needed to define the scope and anticipate problems or contradictions with earlier rules, before writing any code.
3. Claude writes the tests, then the code, and iterates until the tests pass.
4. Claude launches the game (see Commands) and checks the logs for errors. If needed, it also simulates input or takes a screenshot. How the game feels is left to the user's manual tests.
5. Claude gives the user precise tests to run to check the feature themselves, and opens the project in the Godot editor so they can run them: `Start-Process "F:\informatique\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe" -ArgumentList "--path", ".", "-e"`.
6. Give me a commit name idea

For bugs: only report bugs you have actually observed. Fix one by first writing a test that reproduces it; plan mode is not required.

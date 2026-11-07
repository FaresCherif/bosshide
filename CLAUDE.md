# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

BossHide is a simple platformer. The player must reach the end of the level without being spotted, while doing tasks and actions along the way. In the story, an employee is trying to reach the toilets without being seen by the boss.

The project uses Godot 4.3 with the GL Compatibility renderer. `Scene.tscn` is the main scene: a level (`level/`) with the player (`player/`), a manager (`manager/`), two walls, a visual floor and a goal zone. The player starts at the left edge, only moves left and right for now, and the camera follows it. Reaching the goal zone near the right wall shows a success message, freezes the player and lets R restart the level. The manager stands in the background in the middle of the level and alternates 10 seconds facing the camera and 5 seconds turned away; being in the zone around them while they face the camera shows a game over message, with the same freeze and restart. Two desks (blue rectangles) sit inside that zone: pressing E on one puts the player in a working state where they stay still and the manager can't spot them; pressing E again or a fresh press of a move key ends it. The installed Godot is the Mono build and `project.godot` has an assembly name, but the project has no C# code; the existing scripts are GDScript.

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
- `run/main_scene` in `project.godot` points to `res://Scene.tscn`. `tests/unit/test_scene.gd` and `tests/unit/test_level.gd` each hold that path in their own constant, so update them if the main scene moves.

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

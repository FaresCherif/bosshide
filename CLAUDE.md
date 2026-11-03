# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

BossHide is a simple platformer. The player must reach the end of the level without being spotted, while doing tasks and actions along the way. In the story, an employee is trying to reach the toilets without being seen by the boss.

The project is a Godot 4.3 skeleton: `Scene.tscn` is an empty `Node2D`, and there is no gameplay code yet. It uses the GL Compatibility renderer. The installed Godot is the Mono build and `project.godot` has an assembly name, but the project has no C# code; the existing scripts are GDScript.

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
& $godot --path . res://Scene.tscn --quit-after 120 *>&1 | Out-String -Stream | Select-String "ERROR"
```

Always check the logs: Godot exits with code 0 even after a script error. `--quit-after` counts frames. The scene must be passed explicitly while `run/main_scene` is not set.

## Conventions

- Tests extend `GutTest` and live in `tests/unit/`. Wrap instantiated nodes in `autofree()` so they don't leak.
- Comments and assertion messages are in French, written without accents.
- `.gitattributes` normalizes text files to LF.
- `addons/gut/` is third-party code, so don't edit it. The test suite depends on it.
- `run/main_scene` is not set in `project.godot`. `tests/unit/test_scene.gd` treats `res://Scene.tscn` as the main scene through its own constant, so update that constant if the main scene moves.

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
5. Claude gives the user precise tests to run to check the feature themselves.

For bugs: only report bugs you have actually observed. Fix one by first writing a test that reproduces it; plan mode is not required.

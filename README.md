# Runaway Cat

A colorful 2D platform game for [LÖVE](https://love2d.org/) in which Miso the cat runs away from home.

## Play

1. Install LÖVE 11.4 or later.
2. Drag the project folder onto `love.exe`, or run the following command from the project folder:

   ```powershell
   love .
   ```

## Controls

- **Space**, **W**, **up arrow**, or **left mouse button**: jump
- Release the jump button early for a shorter jump
- **P** or **Esc**: pause/resume
- **R**: restart after winning or getting a game over

## Objective

Miso runs automatically. Help him clear holes, thorns, crates, and logs. Collect fish, milk, and cake for points while traveling through the Home Quarter, Whispering Forest, Big City, and Moon Mountains.

Miso has three lives per run. When he hits an obstacle, he loses a life and resumes from the beginning of the current environment. The run ends after the third hit.

Miso gains an extra life whenever the score crosses a new 2,000-point threshold: 2,000, 4,000, 6,000 points, and so on.

The difficulty increases gradually:

- **Home Quarter** is a gentle introduction with low speed and no obstacles.
- **Whispering Forest** increases the speed and height of bonus platforms and introduces one small hole.
- **Big City** introduces more and wider holes, along with small crates, thorns, and logs.
- **Moon Mountains** has the highest speed, the most holes, the longest safe jumps, and the most small obstacles.

All graphics, animations, and level design are generated directly in Lua.

When Miso reaches the finish line, he runs to his new home, where his cat family is waiting. They gather for a group hug before the results screen appears.

The retro music is “Level 1” from **5 Chiptunes (Action)** by Juhani Junkala / SubspaceAudio. The cat sound is “Meow of a Siamese cat” by freemaster2. Both are released under CC0 1.0; full details are available in [`assets/music/LICENSE.md`](assets/music/LICENSE.md) and [`assets/sounds/LICENSE.md`](assets/sounds/LICENSE.md).

## License

Copyright © 2026 Johan Andersson.

The game’s source code is free software licensed under the [GNU General Public License, version 3 or later](LICENSE). Third-party assets retain their respective CC0 licenses as described above.

## Architecture

The game code is organized into testable classes under `game/`:

- `Player`, `Level`, `Difficulty`, and `Zone` control the player and progression.
- `Platform`, `Hazard`, `Food`, and `Particle` represent game objects.
- `Class`, `Config`, and `Util` provide shared infrastructure.
- `Cache` provides functional memoization, while `RenderCache` rasterizes reusable graphics to canvases only once.
- Food, obstacles, and the house use the canvas cache; the retro music is decoded once and kept in a memoized memory cache.
- `App` owns the game lifecycle, state, rendering, and input.
- `main.lua` is a thin entry point that only delegates LÖVE callbacks to `App`.

## Tests

The project uses Busted 2.3.0. The framework and its dependencies are installed locally in `.luarocks/`.

Run the full test suite:

```powershell
.\scripts\test.ps1
```

The test harness uses an isolated LÖVE mock and covers application startup, class behavior, collisions, scoring, and the progressive difficulty curve.

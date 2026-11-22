# Runaway Cat

A colorful 2D platform game for [LÖVE](https://love2d.org/) in which Miso the cat runs away from home. Texts in the game is currently only in Swedish.

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

When Miso reaches the outdoor finish line, he runs to his home and reunites with his family. He then enters **Level 2: Inside Miso's Home**, a much larger-than-life indoor adventure with five worlds:

1. **Giant Hall (Jättehallen)** — towering furniture, benches, shoes, and scattered yarn toys.
2. **Kitchen Kingdom (Köksriket)** — enormous cupboards, appliances, and slippery spills.
3. **Book Jungle (Bokdjungeln)** — giant bookshelves and stacks of fallen books.
4. **Laundry Labyrinth (Tvättlabyrinten)** — oversized washing machines, laundry baskets, and more scattered toys.
5. **Attic Treasure Room (Vindens skattkammare)** — roof beams, storage boxes, and mousetraps.

Indoor floors have no holes. The speed rises gradually from 450 to 500, household hazards remain small, and bonus platforms stay within Miso's jump height. Score, remaining lives, and extra-life thresholds carry over from Level 1. Each indoor world has a safe respawn point. After finishing Level 2, Miso has a final family hug and the results screen appears. Restarting begins a fresh run at Level 1.

The outdoor retro music is “Level 1” from **5 Chiptunes (Action)** by Juhani Junkala / SubspaceAudio (CC0 1.0). The indoor music is “bgm_menu” from **8-bit Music Pack (Loopable)** by CodeManu on OpenGameArt (CC BY 3.0), played at 90% speed for a gentler feel. The music switches automatically on entering the house and switches back when restarting. Both tracks are cached in memory and loop.

The cat sound is “Meow of a Siamese cat” by freemaster2 (CC0 1.0). It plays on only 3% of fish pickups, with at least 12 seconds between meows, at volume 0.10 versus the music's 0.28.

Attribution and license details are included in [`assets/music/LICENSE.md`](assets/music/LICENSE.md) and [`assets/sounds/LICENSE.md`](assets/sounds/LICENSE.md). The indoor track's full CC BY 3.0 license is included in [`assets/music/CC-BY-3.0.txt`](assets/music/CC-BY-3.0.txt).

## License

Copyright © 2026 Johan Andersson.

The game’s source code is free software licensed under the [GNU General Public License, version 3 or later](LICENSE). Third-party assets retain their respective CC0 or CC BY 3.0 licenses as described above.

## Architecture

The game code is organized into testable classes under `game/`:

- `Player`, `Level`, `Difficulty`, and `Zone` control the player and progression.
- Both levels reuse the same generator and gameplay; `Interior` draws five cached indoor scenery panels.
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

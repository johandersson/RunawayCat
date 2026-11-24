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
- On the results dialog, click **Spela igen** (Restart) or **Avsluta** (Exit), or select with **left/right arrows** or **Tab** and confirm with **Enter**. **Esc** exits.
- Jump keys and clicks outside the dialog buttons never restart a finished run.

## Objective

Miso runs automatically. Help him clear holes, thorns, crates, and logs. Collect fish, milk, and cake for points while traveling through the Home Quarter, Whispering Forest, Big City, and Moon Mountains.

Miso has three lives per run. When he hits an obstacle, he loses a life and resumes from the beginning of the current environment. The run ends after the third hit.

Miso gains an extra life whenever the score crosses a new 2,000-point threshold: 2,000, 4,000, 6,000 points, and so on.

The difficulty increases gradually:

- **Home Quarter** is a gentle introduction with low speed and no obstacles.
- **Whispering Forest** increases the speed and height of bonus platforms, but still has no holes or hazards.
- **Big City** introduces one small 65-pixel hole, along with small crates, thorns, and logs.
- **Moon Mountains** has the highest outdoor speed and one 85-pixel hole, with slightly more small obstacles.

Level 1 now ramps from 220 to 335 pixels per second, with lower bonus platforms and fewer, smaller holes.

Most graphics, animations, and level design are generated directly in Lua. The dog uses freely licensed pixel-art animation frames.

When Miso reaches the outdoor finish line, he runs to his home and reunites with his family. He then enters **Level 2: Inside Miso's Home**, a much larger-than-life indoor adventure with five worlds:

1. **Giant Hall (Jättehallen)** — towering furniture, benches, shoes, and scattered yarn toys.
2. **Kitchen Kingdom (Köksriket)** — enormous cupboards, appliances, and slippery spills.
3. **Book Jungle (Bokdjungeln)** — giant bookshelves and stacks of fallen books.
4. **Laundry Labyrinth (Tvättlabyrinten)** — oversized washing machines, laundry baskets, and more scattered toys.
5. **Attic Treasure Room (Vindens skattkammare)** — roof beams, storage boxes, and mousetraps.

Indoor floors have no holes. The speed rises gradually from 260 to 440, comparable to the previous outdoor difficulty. Early rooms have fewer obstacles; the later rooms add more. Household hazards remain small, and bonus platforms stay within Miso's jump height. Score, remaining lives, and extra-life thresholds carry over from Level 1. Each indoor world has a safe respawn point.

## Unlockable Castle Level

Complete both existing levels in one run with **more than 20,000 points** to earn an old-style money bag. A confirmation dialog displays the reward and asks whether to use it to unlock **Level 3: The Secret Castle**.

- **Unlock Castle** permanently saves the unlock and starts Level 3 immediately.
- **Not now** keeps the castle locked and ends the successful run normally. Another qualifying run will offer the reward again.
- After the castle has been unlocked, future runs continue directly from Level 2 into Level 3 without another score requirement.

The castle contains five parts:

1. **Castle Courtyard (Slottsgården)** — towers, battlements, barrels, and shields.
2. **Great Hall (Stora salen)** — banners, a raised throne, and hanging chains.
3. **Armory (Vapenhallen)** — suits of armor, shields, and the first castle-floor gaps.
4. **Dungeon (Fängelsehålan)** — barred cells, spikes, and faster movement.
5. **Treasury (Skattkammaren)** — treasure chests, gold, the highest speed, and the most demanding jumps.

The unlock is stored in LÖVE's save directory, so it remains available after restarting the game.

A large German Shepherd runs toward Miso near the finish of **every level**. At 120 by 85 pixels, it is larger than Miso's 66 by 58-pixel body. It starts running when Miso approaches and stops attacking once he clears it. Jump a little earlier than for small stationary obstacles to pass it; being caught costs a life, just like other hazards.

Another German Shepherd pursues Miso **from behind** after the opening stretch of every level. It stays outside the camera at first, then catches up and barks shortly before reaching him. Jump on the warning to let it lunge underneath Miso; after a successful escape, it falls back and begins another pursuit. Grounded contact costs a life and resets the chase behind the current checkpoint.

The pursuing dog follows the same ground rules as Miso and jumps over generated holes instead of floating across them. The pursuit becomes progressively harder without becoming unavoidable: each successive world slightly increases the dog's catch-up speed and shortens its fallback distance. Level 1 provides the longest recovery time, the indoor level applies more pressure, and the castle treasury has the fastest chase. Its overall catch-up speed has been kept modest and its fallback distance generous; warning timing is adjusted for each speed so a well-timed jump works at both 30 and 60 updates per second.

The dog's idle, five-frame running and three-frame barking animations are **German Shepherd** by Shepardskin on OpenGameArt (CC0 1.0). The sprite faces Miso and its decoded images are cached. Its bark is a real recording from **Dog sounds** by Pauliuw on OpenGameArt (CC0 1.0), cached at volume 0.55 with a three-second repeat cooldown.

After finishing the final available level, Miso has a final family hug. Both victory and game-over show an encouraging dialog with the score and best score for the current game session. The game stays on this dialog until you explicitly choose Restart or Exit. Restarting begins a fresh run at Level 1.

The outdoor retro music is “Level 1” from **5 Chiptunes (Action)** by Juhani Junkala / SubspaceAudio (CC0 1.0). The indoor music is “bgm_menu” from **8-bit Music Pack (Loopable)** by CodeManu on OpenGameArt (CC BY 3.0), played at 90% speed for a gentler feel. The castle uses the loopable **8-Bit Curious Theme** by emanresU (CC0 1.0), a FamiStudio chiptune with a playfully mysterious feel. Music switches automatically between levels and when restarting. All tracks are cached, looped, and assigned safe per-track gains to keep perceived loudness close to −22 LUFS across the campaign without clipping.

The cat sound is “Meow of a Siamese cat” by freemaster2 (CC0 1.0). Miso meows only when losing a life, including the final life. It never plays on food pickups or protected collisions. The volume is 0.60. Every lost life triggers the meow, without randomness or a cooldown.

The unlock dialog uses the old-style `MoneyBag.png` sprite from the **Ninja Adventure Asset Pack** by Pixel-Boy and AAA (CC0 1.0), enlarged with nearest-neighbor filtering.

Attribution and license details are included in [`assets/music/LICENSE.md`](assets/music/LICENSE.md), [`assets/sounds/LICENSE.md`](assets/sounds/LICENSE.md), [`assets/sprites/dog/LICENSE.md`](assets/sprites/dog/LICENSE.md), and [`assets/sprites/money-bag/LICENSE.md`](assets/sprites/money-bag/LICENSE.md). The indoor track's full CC BY 3.0 license is included in [`assets/music/CC-BY-3.0.txt`](assets/music/CC-BY-3.0.txt).

## License

Copyright © 2026 Johan Andersson.

The game’s source code is free software licensed under the [GNU General Public License, version 3 or later](LICENSE). Third-party assets retain their respective CC0 or CC BY 3.0 licenses as described above.

## Architecture

The game code is organized into testable classes under `game/`:

- `Player`, `Level`, `Difficulty`, and `Zone` control the player and progression.
- All three levels reuse the same generator and gameplay; `Interior` and `Castle` draw cached scenery panels for their five-part environments.
- `Platform`, `Hazard`, `Food`, and `Particle` represent game objects.
- `Dog` guards each finish from ahead, while `ChaserDog` repeatedly pressures Miso from behind with progressive catch-up settings. `DogSprite` draws both directions from the same cached, freely licensed animation frames.
- `CastleUnlock` owns the strict score requirement and persistent unlock, while `UnlockDialog` and `ResultDialog` handle explicit choices.
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

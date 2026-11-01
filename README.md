# Katten på rymmen

Ett färgstarkt, asset-fritt 2D-plattformsspel för [LÖVE](https://love2d.org/) där katten Miso rymmer hemifrån0.

## Spela

1. Installera LÖVE 11.4 eller senare.
2. Dra projektmappen till `love.exe`, eller kör följande i projektmappen:

   ```powershell
   love .
   ```

## Kontroller

- **Mellanslag**, **W**, **uppåtpil** eller **vänster musklick**: hoppa
- Släpp hoppknappen tidigt för ett kortare hopp
- **P** eller **Esc**: pausa/fortsätt
- **R**: starta om efter vinst eller game over

## Målet

Miso springer automatiskt. Hjälp honom över hål, taggar, lådor och stockar. Samla fisk, mjölk och tårta för poäng medan du tar dig genom Hemkvarteren, Viskskogen, Stora staden och Månbergen.

Miso har tre liv per omgång. När han träffar ett hinder förlorar han ett liv och fortsätter från början av den aktuella miljön. Först efter den tredje träffen är omgången slut.

Varje gång poängen passerar en ny 2 000-poängsgräns får Miso ett extraliv. Det innebär extraliv vid 2 000, 4 000, 6 000 poäng och så vidare.

Svårigheten ökar stegvis:

- **Hemkvarteren** är en lugn introduktion med låg fart och inga hinder.
- **Viskskogen** ökar farten och höjden på bonusplattformarna och introducerar ett litet hål.
- **Stora staden** introducerar fler och bredare hål samt små lådor, taggar och stockar.
- **Månbergen** har högst fart, flest hål, längst säkra hopp och flest små hinder.

All grafik, animation, nivådesign och alla ljudeffekter skapas direkt i Lua, så inga externa assets behövs.

När Miso når målet springer han fram till sitt nya hem, där hans kattfamilj väntar och samlas i en gruppkram innan resultatskärmen visas.

Spelets retromusik är “Level 1” från **5 Chiptunes (Action)** av Juhani Junkala / SubspaceAudio. Kattljudet är “Meow of a Siamese cat” av freemaster2. Båda är publicerade under CC0 1.0; fullständig information finns i `assets/music/LICENSE.md` och `assets/sounds/LICENSE.md`.

## Arkitektur

Spelkoden är uppdelad i testbara klasser under `game/`:

- `Player`, `Level`, `Difficulty` och `Zone` styr spelaren och progressionen.
- `Platform`, `Hazard`, `Food` och `Particle` representerar spelobjekt.
- `Class`, `Config` och `Util` innehåller gemensam infrastruktur.
- `Cache` erbjuder funktionell memoization och `RenderCache` rasteriserar återanvänd grafik till canvas bara en gång.
- Mat, hinder och huset använder canvas-cachen; retromusiken avkodas en gång och hålls i en memoiserad minnescache.
- `App` äger spelets livscykel, tillstånd, rendering och input.
- `main.lua` är en tunn startfil som enbart delegerar LÖVE-callbacks till `App`.

## Tester

Projektet använder Busted 2.3.0. Ramverket och dess beroenden installeras lokalt i `.luarocks/`.

Kör hela testsviten:

```powershell
.\scripts\test.ps1
```

Testharnessen använder en isolerad LÖVE-mock och testar både applikationsstart, klassbeteenden, kollisioner, poäng och den progressiva svårighetskurvan.

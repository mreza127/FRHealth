# FRHealth

FRHealth is an FPGA-based digital fitness trainer written in Verilog. It calculates a personalized workout target from a few simple inputs (body weight, calorie/intensity goal, gender, and metabolism/fitness level), then walks the user through a series of timed workout/rest intervals — displaying live progress on a 7-segment display and a 16x2 character LCD, and giving audible feedback through a buzzer.

## How it works

1. **Set your parameters** with the input switches: weight (`w`), calorie/intensity level (`cal`), gender (`g`), and metabolism/fitness level (`met`).
2. A combinational lookup (`FCalc`) maps `w` and `cal` to a base value, which `TCalc` then adjusts for `g` and scales down according to `met` to produce **T** — the total number of exercise rounds for the session.
3. Pressing **Start** begins round 1. Each round is:
   - **Workout** — a 45-second interval, counting down.
   - **Rest** — a 15-second interval, counting down.
4. After every round, the workout name shown on the LCD's second line advances to the next exercise in a built-in 10-exercise rotation (lunges, push-ups, jumping squats, tricep dips, mountain climbers, plank ladder, wall sit, plank hold, burpees, then repeats).
5. **Skip** immediately ends the current interval and advances to the next round (or finishes the session if the last round was reached).
6. **Reset** returns to the idle/setup state at any time.
7. Once round **T** is complete, the session ends and the buzzer sounds a distinct "finished" tone.

Buzzer tones are used as feedback: a short tone marks the end of a normal round, a different tone marks a skip, and a third, higher tone marks the end of the whole session.

## Repository structure

```
src/
├── FRHealth.v      Top-level module — wires everything together
├── FCalc.v         Combinational lookup: (weight, calorie level) -> base value
├── TCalc.v         Applies gender/metabolism scaling to FCalc's output -> target round count (T)
├── FSM.v           Core state machine (Start / Workout / Rest), round counter, interval timer
├── FreqDiv.v       Clock divider — derives all internal clocks and buzzer tones from the system clock
├── Debouncer.v     Button debouncer / edge detector (used for Start, Reset, Skip)
├── SevenSeg.v      Drives a 4-digit multiplexed 7-segment display (round count + time remaining)
├── mainLcd.v       HD44780-style 16x2 character LCD driver (round/time + exercise name)
├── ALL.v           All of the modules above concatenated into a single file (for toolchains that need one file)
└── TCalc_tb.v      Testbench for TCalc: reads test vectors from input.txt, writes results to output.txt
```

`ALL.v` is a generated convenience bundle, not a separate design — keep it in sync with the individual files (or regenerate it) if you make changes, rather than editing it directly.

## Top-level interface (`FRHealth`)

| Signal      | Direction | Width | Description |
|-------------|-----------|-------|-------------|
| `Clk`       | in  | 1 | System clock. **Designed for a 40 MHz clock** — the buzzer tones (500 Hz / 1 kHz / 2 kHz) and internal timing are only accurate at that frequency. |
| `w`         | in  | 3 | Weight selector (8 levels), fed into `FCalc`. |
| `cal`       | in  | 2 | Calorie / intensity level (4 levels), fed into `FCalc`. |
| `g`         | in  | 1 | Gender switch — scales the base value up when set. |
| `met`       | in  | 2 | Metabolism / fitness level (4 levels) — divides the base value by 1/2/4/8. |
| `inSt`      | in  | 1 | **Start** button, active-low. |
| `inRe`      | in  | 1 | **Reset** button, active-low. |
| `inSk`      | in  | 1 | **Skip** button, active-low. |
| `seg_data`  | out | 8 | 7-segment segment pattern (active-high). |
| `seg_sel`   | out | 5 | 7-segment digit-select / multiplex line. |
| `BuFreq`    | out | 1 | Buzzer drive signal (square wave at 500 Hz, 1 kHz, or 2 kHz, or idle). |
| `lcd_Data`  | out | 8 | LCD data bus. |
| `lcd_Rs`    | out | 1 | LCD register select. |
| `lcd_Rw`    | out | 1 | LCD read/write. |
| `lcd_E`     | out | 1 | LCD enable/strobe. |
| `lcd_reset` | out | 1 | LCD reset line. |

Buttons are active-low (a common convention for boards with pull-ups), so `FRHealth.v` inverts them internally before debouncing.

## Internal clocking

`FreqDiv` takes the single 40 MHz system clock and derives every other clock/tone the design needs by counting edges:

| Signal | Approx. frequency | Used for |
|--------|--------------------|----------|
| `ClkFsm` | 1 Hz | 1-second reference tick for the round timer in `FSM` |
| `ClkDeb` | 500 Hz | Sampling clock for button debouncing, and the FSM's main clock domain |
| `Clk7seg` | 250 Hz | 7-segment digit multiplexing |
| `ClkLcd` | 800 Hz | LCD control state machine |
| `beep500` / `beep1k` / `beep2k` | 500 Hz / 1 kHz / 2 kHz | Buzzer tones |

Because these are all derived by counting fixed numbers of `Clk` edges, changing the system clock frequency will shift every one of these — most noticeably making the buzzer tones and the 1-second round timer wrong. If you target a board with a different clock, rescale the counter thresholds in `FreqDiv.v` accordingly.

## Simulation

`TCalc_tb.v` is a simple file-driven testbench for the `TCalc` module. It reads 8-bit test vectors (packed as `w[2:0] cal[1:0] met[1:0] g`) one line at a time from `input.txt` and writes the resulting `T` for each to `output.txt`.

To run it with Icarus Verilog:

```bash
iverilog -o tcalc_sim src/TCalc.v src/FCalc.v src/TCalc_tb.v
vvp tcalc_sim
```

Create an `input.txt` file (in the same directory you run the simulation from) with one 8-bit binary vector per line, e.g.:

```
10101100
00110011
```

Results are written to `output.txt` in the same directory.

## Building for hardware

This repository contains only the design sources — there is no included pin/constraint file, since pin assignments are board-specific. To bring this up on real hardware you'll need to:

1. Create a project in your toolchain of choice (Quartus, Vivado, etc.) and add the files in `src/` (either the individual modules or `ALL.v`).
2. Add a constraints file mapping `Clk`, `w`, `cal`, `g`, `met`, `inSt`, `inRe`, `inSk`, `seg_data`, `seg_sel`, `BuFreq`, and the `lcd_*` signals to your board's actual pins.
3. Supply (or generate via PLL) a **40 MHz** clock on `Clk` for the timing described above to be accurate.
4. Wire `lcd_*` to a standard HD44780-compatible 16x2 character LCD, `seg_data`/`seg_sel` to a 4-digit multiplexed 7-segment display, and `BuFreq` to a buzzer/speaker driver.

## Notes / known limitations

- Workout interval lengths (45 s work / 15 s rest) and the list of exercise names are hard-coded in `FSM.v` and `mainLcd.v` respectively.
- `seg_sel` is 5 bits wide but only the lower 4 are driven (4-digit display).
- No license file is currently included in this repository — add one if you intend to share or reuse this code.

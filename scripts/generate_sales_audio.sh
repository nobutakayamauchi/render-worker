#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-dist}"
mkdir -p "$out_dir"

# Deterministic 15-second sales-ad bed with cues aligned to the six sales sections.
ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i "sine=frequency=110:sample_rate=48000:duration=15" \
  -f lavfi -i "sine=frequency=220:sample_rate=48000:duration=15" \
  -f lavfi -i "anoisesrc=color=pink:sample_rate=48000:duration=15" \
  -filter_complex "\
    [0:a]volume=0.022,tremolo=f=2.0:d=0.30,lowpass=f=600[pulse];\
    [1:a]volume=0.012,tremolo=f=0.25:d=0.35,lowpass=f=1100[pad];\
    [2:a]highpass=f=2400,lowpass=f=6200,volume=0.006,tremolo=f=4.0:d=0.75[air];\
    [pulse][pad][air]amix=inputs=3:normalize=0,afade=t=in:st=0:d=.18,afade=t=out:st=14.55:d=.45[bed];\
    sine=frequency=740:sample_rate=48000:duration=.12,volume=.055,afade=t=out:st=.025:d=.095,adelay=1450|1450[c1];\
    sine=frequency=988:sample_rate=48000:duration=.12,volume=.060,afade=t=out:st=.025:d=.095,adelay=4000|4000[c2];\
    sine=frequency=1175:sample_rate=48000:duration=.14,volume=.062,afade=t=out:st=.03:d=.11,adelay=7500|7500[c3];\
    sine=frequency=1319:sample_rate=48000:duration=.14,volume=.060,afade=t=out:st=.03:d=.11,adelay=11000|11000[c4];\
    sine=frequency=1568:sample_rate=48000:duration=.16,volume=.070,afade=t=out:st=.035:d=.125,adelay=13000|13000[c5];\
    sine=frequency=523.25:sample_rate=48000:duration=.5,volume=.038,afade=t=out:st=.25:d=.25,adelay=13900|13900[land1];\
    sine=frequency=783.99:sample_rate=48000:duration=.5,volume=.032,afade=t=out:st=.25:d=.25,adelay=13900|13900[land2];\
    [bed][c1][c2][c3][c4][c5][land1][land2]amix=inputs=8:normalize=0,alimiter=limit=.82:attack=5:release=80,atrim=0:15[aout]" \
  -map "[aout]" -c:a pcm_s16le "$out_dir/ai_cm_render_sales_audio.wav"

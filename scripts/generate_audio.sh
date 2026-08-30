#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-dist}"
mkdir -p "$out_dir"

# Original deterministic 15-second bed: soft pad, sine pulse, muted beat, and restrained cues.
ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i "sine=frequency=110:sample_rate=48000:duration=15" \
  -f lavfi -i "sine=frequency=164.81:sample_rate=48000:duration=15" \
  -f lavfi -i "sine=frequency=220:sample_rate=48000:duration=15" \
  -f lavfi -i "anoisesrc=color=pink:sample_rate=48000:duration=15" \
  -filter_complex "\
    [0:a]volume=0.026,tremolo=f=1.8667:d=0.22,lowpass=f=520,aecho=0.6:0.3:70:0.12[pulse];\
    [1:a]volume=0.018,tremolo=f=0.2333:d=0.32,lowpass=f=850,aecho=0.7:0.22:180:0.16[pad1];\
    [2:a]volume=0.010,tremolo=f=0.1167:d=0.45,lowpass=f=1100[pad2];\
    [3:a]highpass=f=1800,lowpass=f=4800,volume=0.010,tremolo=f=3.7333:d=0.82[clickbed];\
    [pulse][pad1][pad2][clickbed]amix=inputs=4:normalize=0,afade=t=in:st=0:d=0.45,afade=t=out:st=14.45:d=0.55[bgm];\
    sine=frequency=1318.5:sample_rate=48000:duration=0.11,volume=0.10,afade=t=out:st=0.025:d=0.085,adelay=180|180[ding1];\
    sine=frequency=1568:sample_rate=48000:duration=0.10,volume=0.075,afade=t=out:st=0.02:d=0.08,adelay=255|255[ding2];\
    sine=frequency=880:sample_rate=48000:duration=0.045,volume=0.07,afade=t=out:st=0.008:d=0.037,adelay=2200|2200[tick1];\
    sine=frequency=880:sample_rate=48000:duration=0.045,volume=0.06,afade=t=out:st=0.008:d=0.037,adelay=4800|4800[tick2];\
    sine=frequency=1174.7:sample_rate=48000:duration=0.12,volume=0.065,afade=t=out:st=0.025:d=0.095,adelay=3720|3720[confirm1];\
    sine=frequency=1046.5:sample_rate=48000:duration=0.09,volume=0.055,afade=t=out:st=0.015:d=0.075,adelay=8350|8350[confirm2];\
    sine=frequency=1318.5:sample_rate=48000:duration=0.09,volume=0.05,afade=t=out:st=0.015:d=0.075,adelay=9050|9050[confirm3];\
    sine=frequency=1568:sample_rate=48000:duration=0.14,volume=0.075,afade=t=out:st=0.025:d=0.115,adelay=11900|11900[check];\
    sine=frequency=523.25:sample_rate=48000:duration=0.48,volume=0.045,afade=t=in:st=0:d=0.035,afade=t=out:st=0.24:d=0.24,adelay=13620|13620[land1];\
    sine=frequency=783.99:sample_rate=48000:duration=0.48,volume=0.035,afade=t=in:st=0:d=0.035,afade=t=out:st=0.24:d=0.24,adelay=13620|13620[land2];\
    [bgm][ding1][ding2][tick1][tick2][confirm1][confirm2][confirm3][check][land1][land2]amix=inputs=11:normalize=0,alimiter=limit=0.82:attack=5:release=80,atrim=0:15[aout]" \
  -map "[aout]" -c:a pcm_s16le "$out_dir/bridgepatch_audio.wav"

#!/usr/bin/env python3
"""Synthesizes real WAV music loops and SFX for Puzzle Realm using numpy.
No external samples/licensing concerns: everything is generated waveforms.
"""
import os
import numpy as np
import wave

SR = 44100
MUSIC_DIR = os.path.join(os.path.dirname(__file__), "..", "audio", "music")
SFX_DIR = os.path.join(os.path.dirname(__file__), "..", "audio", "sfx")
os.makedirs(MUSIC_DIR, exist_ok=True)
os.makedirs(SFX_DIR, exist_ok=True)


def write_wav(path, samples, sr=SR):
    """samples: float32 numpy array in [-1, 1], mono."""
    samples = np.clip(samples, -1.0, 1.0)
    pcm = (samples * 32767).astype(np.int16)
    with wave.open(path, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sr)
        f.writeframes(pcm.tobytes())
    print("wrote", path, f"{len(samples)/sr:.2f}s")


def t_axis(duration):
    return np.linspace(0, duration, int(SR * duration), endpoint=False)


def square(freq, duration, duty=0.5):
    t = t_axis(duration)
    phase = (t * freq) % 1.0
    return np.where(phase < duty, 1.0, -1.0).astype(np.float32)


def triangle(freq, duration):
    t = t_axis(duration)
    phase = (t * freq) % 1.0
    return (2 * np.abs(2 * (phase - np.floor(phase + 0.5))) - 1).astype(np.float32)


def sine(freq, duration):
    t = t_axis(duration)
    return np.sin(2 * np.pi * freq * t).astype(np.float32)


def noise(duration):
    return (np.random.uniform(-1, 1, int(SR * duration))).astype(np.float32)


def envelope(samples, attack=0.01, release=0.05):
    n = len(samples)
    env = np.ones(n, dtype=np.float32)
    a = int(SR * attack)
    r = int(SR * release)
    if a > 0:
        env[:a] *= np.linspace(0, 1, a)
    if r > 0:
        env[-r:] *= np.linspace(1, 0, r)
    return samples * env


def mix(*tracks):
    n = max(len(t) for t in tracks)
    out = np.zeros(n, dtype=np.float32)
    for t in tracks:
        out[:len(t)] += t
    return out / max(1.0, len(tracks) * 0.6)


NOTE = {
    'C3': 130.81, 'D3': 146.83, 'Eb3': 155.56, 'E3': 164.81, 'F3': 174.61, 'G3': 196.00,
    'Ab3': 207.65, 'A3': 220.00, 'Bb3': 233.08, 'B3': 246.94,
    'C4': 261.63, 'D4': 293.66, 'Eb4': 311.13, 'E4': 329.63, 'F4': 349.23, 'G4': 392.00,
    'Ab4': 415.30, 'A4': 440.00, 'Bb4': 466.16, 'B4': 493.88,
    'C5': 523.25, 'D5': 587.33, 'Eb5': 622.25, 'E5': 659.25, 'F5': 698.46, 'G5': 783.99,
    'A5': 880.00, 'REST': 0.0,
}


def seq(notes_durs, wave_fn, gap=0.015):
    """notes_durs: list of (note_name, beats). beat = 0.22s default handled by caller scaling."""
    parts = []
    for name, dur in notes_durs:
        freq = NOTE[name]
        d = max(dur - gap, 0.02)
        if freq == 0.0:
            parts.append(np.zeros(int(SR * dur), dtype=np.float32))
        else:
            note = wave_fn(freq, d)
            note = envelope(note, attack=0.005, release=min(0.05, d * 0.3))
            parts.append(note)
            if gap > 0:
                parts.append(np.zeros(int(SR * gap), dtype=np.float32))
    return np.concatenate(parts)


# ---------------------------------------------------------------------------
# MENU THEME — slow, moody, minor-key triangle melody + soft square pad
# ---------------------------------------------------------------------------
def make_menu_theme():
    beat = 0.30
    melody_notes = [
        ('C4', 2*beat), ('Eb4', beat), ('G4', beat), ('F4', 2*beat), ('Eb4', beat), ('D4', beat),
        ('C4', 2*beat), ('REST', beat), ('G3', beat), ('Bb3', 2*beat), ('C4', 2*beat), ('D4', 2*beat),
        ('Eb4', 3*beat), ('D4', beat), ('C4', 4*beat),
    ]
    melody = seq(melody_notes, triangle, gap=0.02)

    bass_notes = [
        ('C3', 4*beat), ('Ab3', 4*beat), ('F3', 4*beat), ('G3', 4*beat),
    ]
    bass_loop = seq(bass_notes, lambda f, d: square(f, d, duty=0.5) * 0.5, gap=0.0)
    reps = int(np.ceil(len(melody) / len(bass_loop)))
    bass = np.tile(bass_loop, reps)[:len(melody)]

    pad = sine(65.41, len(melody) / SR) * 0.15  # low C2 drone

    out = mix(melody * 0.9, bass * 0.6, pad)
    # gentle fade to make the loop seamless
    out = envelope(out, attack=0.05, release=0.05)
    return out


write_wav(os.path.join(MUSIC_DIR, "menu_theme.wav"), make_menu_theme())


# ---------------------------------------------------------------------------
# LEVEL THEME — driving square-wave chiptune loop, more energetic
# ---------------------------------------------------------------------------
def make_level_theme():
    beat = 0.16
    melody_notes = [
        ('C4', beat), ('C4', beat), ('Eb4', beat), ('G4', beat),
        ('F4', beat), ('Eb4', beat), ('D4', beat), ('G4', beat),
        ('C4', beat), ('C4', beat), ('Eb4', beat), ('G4', beat),
        ('Bb4', beat), ('G4', beat), ('F4', beat), ('D4', beat),
        ('Eb4', beat), ('Eb4', beat), ('F4', beat), ('G4', beat),
        ('Ab4', beat), ('G4', beat), ('F4', beat), ('Eb4', beat),
        ('D4', beat), ('D4', beat), ('Eb4', beat), ('F4', beat),
        ('G4', 2*beat), ('C4', 2*beat),
    ]
    melody = seq(melody_notes, lambda f, d: square(f, d, duty=0.4), gap=0.005)

    bass_pattern = [
        ('C3', beat), ('C3', beat), ('G3', beat), ('C3', beat),
        ('Ab3', beat), ('Ab3', beat), ('Eb3', beat), ('Ab3', beat),
        ('F3', beat), ('F3', beat), ('C3', beat), ('F3', beat),
        ('G3', beat), ('G3', beat), ('D3', beat), ('G3', beat),
    ]
    bass_loop = seq(bass_pattern, lambda f, d: triangle(f, d), gap=0.0) * 0.55
    reps = int(np.ceil(len(melody) / len(bass_loop)))
    bass = np.tile(bass_loop, reps)[:len(melody)]

    # simple noise hi-hat on every beat
    hat_unit = envelope(noise(0.03), attack=0.001, release=0.02) * 0.12
    silence_unit = np.zeros(int(SR * beat) - len(hat_unit), dtype=np.float32)
    hat_loop = np.tile(np.concatenate([hat_unit, silence_unit]), int(np.ceil(len(melody) / (SR*beat))))[:len(melody)]

    out = mix(melody * 0.85, bass, hat_loop)
    out = envelope(out, attack=0.02, release=0.02)
    return out


write_wav(os.path.join(MUSIC_DIR, "level_theme.wav"), make_level_theme())


# ---------------------------------------------------------------------------
# SFX
# ---------------------------------------------------------------------------
def sfx_jump():
    t = t_axis(0.18)
    freq = np.linspace(300, 700, len(t))
    wave_ = np.sin(2 * np.pi * np.cumsum(freq) / SR).astype(np.float32)
    return envelope(wave_, attack=0.005, release=0.12) * 0.7


def sfx_dash():
    t = t_axis(0.15)
    freq = np.linspace(900, 200, len(t))
    wave_ = square(1, 0.001, duty=0.5)  # placeholder unused
    wave_ = np.sign(np.sin(2 * np.pi * np.cumsum(freq) / SR)).astype(np.float32)
    n = noise(0.15) * 0.3
    return envelope(mix(wave_ * 0.8, n), attack=0.002, release=0.1) * 0.7


def sfx_hit():
    n = noise(0.08)
    t = t_axis(0.08)
    tone = np.sin(2 * np.pi * 180 * t).astype(np.float32) * 0.6
    return envelope(mix(n, tone), attack=0.001, release=0.06) * 0.8


def sfx_damage():
    t = t_axis(0.25)
    freq = np.linspace(220, 80, len(t))
    wave_ = np.sign(np.sin(2 * np.pi * np.cumsum(freq) / SR)).astype(np.float32)
    n = noise(0.25) * 0.4
    return envelope(mix(wave_, n), attack=0.001, release=0.2) * 0.8


def sfx_puzzle_activate():
    notes = [('C4', 0.08), ('E4', 0.08), ('G4', 0.08), ('C5', 0.18)]
    return seq(notes, sine, gap=0.0) * 0.6


def sfx_door_open():
    t = t_axis(0.4)
    freq = np.linspace(100, 260, len(t))
    wave_ = triangle(1, 0.001)
    wave_ = (2 * np.abs(2 * (((np.cumsum(freq) / SR)) % 1.0 - 0.5)) - 1).astype(np.float32)
    n = noise(0.4) * 0.15
    return envelope(mix(wave_ * 0.7, n), attack=0.02, release=0.25) * 0.6


def sfx_enemy_death():
    t = t_axis(0.3)
    freq = np.linspace(400, 40, len(t))
    wave_ = np.sign(np.sin(2 * np.pi * np.cumsum(freq) / SR)).astype(np.float32)
    n = noise(0.3) * 0.5
    return envelope(mix(wave_, n), attack=0.001, release=0.25) * 0.75


def sfx_level_complete():
    notes = [('C4', 0.12), ('E4', 0.12), ('G4', 0.12), ('C5', 0.12), ('E5', 0.3)]
    return seq(notes, triangle, gap=0.01) * 0.7


def sfx_puzzle_solved_ui():
    notes = [('G4', 0.08), ('C5', 0.2)]
    return seq(notes, sine, gap=0.0) * 0.5


SFX_MAKERS = {
    "jump": sfx_jump,
    "dash": sfx_dash,
    "hit": sfx_hit,
    "damage": sfx_damage,
    "puzzle_activate": sfx_puzzle_activate,
    "door_open": sfx_door_open,
    "enemy_death": sfx_enemy_death,
    "level_complete": sfx_level_complete,
    "puzzle_solved": sfx_puzzle_solved_ui,
}

for name, fn in SFX_MAKERS.items():
    write_wav(os.path.join(SFX_DIR, f"{name}.wav"), fn())

print("Audio generation done.")

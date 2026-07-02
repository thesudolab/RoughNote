import os
import time
from macimu import IMU
from macimu.filters import magnitude, peak_detect

# Files
sounds = ["tap1.mp3", "tap2.mp3", "tap3.mp3"]
tap_count = 0

def play_sound(file):
    # Using afplay, which is built into macOS
    os.system(f"afplay {file} &")

print("Monitoring for taps... (Press Ctrl+C to stop)")

with IMU() as imu:
    try:
        while True:
            # Read recent samples
            samples = imu.read_accel()
            if not samples:
                continue
            
            # Calculate magnitude and check for peaks (impacts)
            mags = [magnitude(s.x, s.y, s.z) for s in samples]
            hits = peak_detect(mags, threshold=1.5) # Adjust threshold if too sensitive
            
            if hits:
                print(f"Tap detected! Playing: {sounds[tap_count]}")
                play_sound(sounds[tap_count])
                
                # Cycle through the three sounds
                tap_count = (tap_count + 1) % 3
                
                # Debounce to prevent one tap triggering multiple times
                time.sleep(1.0) 
                
    except KeyboardInterrupt:
        print("Stopping...")

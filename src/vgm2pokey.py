#!/usr/bin/env python3
import sys
import struct

def parse_vgm(vgm_path, output_path):
    with open(vgm_path, 'rb') as f:
        data = f.read()

    if data[0:4] != b'Vgm ':
        print("Invalid VGM file")
        return

    # Find data offset
    vgm_offset = struct.unpack('<I', data[0x34:0x38])[0]
    if vgm_offset == 0:
        vgm_offset = 0x40
    else:
        vgm_offset += 0x34

    pos = vgm_offset
    output = bytearray()
    
    frame_events = 0
    total_frames = 0
    
    print(f"Processing {vgm_path} starting at offset 0x{pos:X}...")

    while pos < len(data):
        cmd = data[pos]

        if cmd == 0x66: # End of Sound Data
            print("End of song data found.")
            break
            
        elif cmd == 0x62: # Wait 735 samples (1/60th second)
            output.append(0xFF) # End Frame Marker
            total_frames += 1
            pos += 1
            
        elif cmd == 0x61: # Wait n samples
            # This is rare in 60Hz logging but possible
            n = struct.unpack('<H', data[pos+1:pos+3])[0]
            # We treat any wait as a frame end for simplicity in this raw dumper, 
            # OR we just ignore small waits. But for 60Hz locked music, usually see 0x62.
            # Let's assume 0x61 with n=wait is just a wait.
            # Ideally we only emit 0xFF if enough time passed.
            # But standard Furnace export is 0x62 usually.
            # If we see 0x61, we'll just append 0xFF.
            output.append(0xFF)
            total_frames += 1
            pos += 3

        elif cmd == 0xBB: # Game Gear / AY8910 stereo data... used by Furnace for POKEY
            reg = data[pos+1]
            val = data[pos+2]
            
            # Furnace POKEY export quirks: 
            # It maps POKEY registers 0-F to AY registers 0-F.
            # Just pass them through.
            # POKEY has registers $00-$0F at $450-$45F.
            
            # However, we only care about audio regs generally.
            # But let's pass EVERYTHING for now to be safe.
            
            output.append(reg)
            output.append(val)
            frame_events += 1
            pos += 3
            
        elif cmd == 0xB2: # POKEY write? Standard VGM spec says POKEY is different commands
            # But we know this file uses 0xBB from previous analysis.
            pos += 3
            
        elif (cmd & 0xF0) == 0x70: # Wait 1..16 samples
            # Short wait. Usually sub-frame. Ignore for frame timing? 
            # Or treat as delay? Our engine is frame-based.
            # We ignore sub-frame timing and burst writes per frame.
            pos += 1
            
        else:
            # Unknown or unsupported, skip 1 byte?
            # Better to be safe, but usually safe to skip 1.
            # print(f"Unknown command: {hex(cmd)} at {hex(pos)}")
            pos += 1

    # End of song marker for our driver
    output.append(0xFE) 
    
    with open(output_path, 'wb') as f:
        f.write(output)
        
    print(f"Done. {total_frames} frames. Output size: {len(output)} bytes.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 vgm2pokey.py input.vgm output.bin")
    else:
        parse_vgm(sys.argv[1], sys.argv[2])

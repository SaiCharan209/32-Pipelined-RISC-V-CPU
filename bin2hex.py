import sys
import struct

def bin_to_hex32(input_bin, output_hex):
    with open(input_bin, 'rb') as f_in, open(output_hex, 'w') as f_out:
        while True:
            # Read exactly 4 bytes (1 word) at a time
            chunk = f_in.read(4)
            if not chunk:
                break
                
            # If the chunk is less than 4 bytes (end of file), pad it with zeros
            if len(chunk) < 4:
                chunk += b'\x00' * (4 - len(chunk))
                
            # Unpack the 4 bytes as a 32-bit little-endian unsigned integer
            word = struct.unpack('<I', chunk)[0]
            
            # Format as an 8-character zero-padded hex string
            f_out.write(f"{word:08x}\n")

if __name__ == "__main__":
    input_file = "program.bin"
    output_file = "imem_32.hex"
    bin_to_hex32(input_file, output_file)
    print(f"Successfully converted {input_file} to 32-bit word format in {output_file}!")
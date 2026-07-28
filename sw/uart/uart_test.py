import serial
import time
import sys

PORT = "/dev/ttyUSB1"
BAUD = 12_000_000

ser = serial.Serial(PORT, BAUD, timeout=0.25)

test_data = bytes(range(256))

print(f"Sending {len(test_data)} bytes...")

print("TX:")
for i in range(0, len(test_data), 16):
    print(f"{i:03X}: " + " ".join(f"{b:02X}" for b in test_data[i : i + 16]))

ser.reset_input_buffer()
ser.write(test_data)
ser.flush()

received = bytearray()

deadline = time.time() + 3.0

while len(received) < len(test_data) and time.time() < deadline:
    received.extend(ser.read(len(test_data) - len(received)))

print(f"\nReceived {len(received)} bytes")

print("RX:")
for i in range(0, len(received), 16):
    print(f"{i:03X}: " + " ".join(f"{b:02X}" for b in received[i : i + 16]))

if len(received) != len(test_data):
    print(f"\nERROR: Timeout. Received {len(received)}/{len(test_data)} bytes.")
    sys.exit(1)

for i, (tx, rx) in enumerate(zip(test_data, received)):
    if tx != rx:
        print(f"\nERROR at byte {i}")
        print(f"  Sent     : 0x{tx:02X}")
        print(f"  Received : 0x{rx:02X}")
        sys.exit(1)

print("\nPASS: Loopback successful!")

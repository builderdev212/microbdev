from dataclasses import dataclass


@dataclass
class ss_digit:
    """Class for storing digit for seven segment display."""

    def __init__(self, value: hex):
        self.val = value
        match value:
            case 0x0:
                self.raw = int("1000000", 2)
            case 0x1:
                self.raw = int("1111001", 2)
            case 0x2:
                self.raw = int("0100100", 2)
            case 0x3:
                self.raw = int("0110000", 2)
            case 0x4:
                self.raw = int("0011001", 2)
            case 0x5:
                self.raw = int("0010010", 2)
            case 0x6:
                self.raw = int("0000010", 2)
            case 0x7:
                self.raw = int("1111000", 2)
            case 0x8:
                self.raw = int("0000000", 2)
            case 0x9:
                self.raw = int("0010000", 2)
            case 0xA:
                self.raw = int("0001000", 2)
            case 0xB:
                self.raw = int("0000011", 2)
            case 0xC:
                self.raw = int("1000110", 2)
            case 0xD:
                self.raw = int("0100001", 2)
            case 0xE:
                self.raw = int("0000110", 2)
            case 0xF:
                self.raw = int("0001110", 2)
            case _:
                self.raw = 0xBAD

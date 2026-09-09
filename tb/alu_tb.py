import cocotb
from cocotb.triggers import Timer

ALU_ADD, ALU_SUB = 0b0000, 0b1000
ALU_SLL = 0b0001
ALU_SLT, ALU_SLTU = 0b0010, 0b0011
ALU_XOR = 0b0100
ALU_SRL, ALU_SRA = 0b0101, 0b1101
ALU_OR, ALU_AND = 0b0110, 0b0111

MASK32 = 0xFFFFFFFF

CASES = [
    (ALU_ADD,  5, 7, 12),
    (ALU_ADD,  0xFFFFFFFF, 1, 0),                 # wrap
    (ALU_SUB,  10, 3, 7),
    (ALU_SUB,  0, 1, 0xFFFFFFFF),                 # borrow
    (ALU_AND,  0xF0F0F0F0, 0x0FF00FF0, 0x00F000F0),
    (ALU_OR,   0xF0F0F0F0, 0x0F0F0F0F, 0xFFFFFFFF),
    (ALU_XOR,  0xAAAAAAAA, 0xFFFFFFFF, 0x55555555),
    (ALU_SLL,  1, 4, 16),
    (ALU_SLL,  1, 33, 2),                          # shamt masked to [4:0]
    (ALU_SRL,  0x80000000, 4, 0x08000000),
    (ALU_SRA,  0x80000000, 4, 0xF8000000),        
    (ALU_SRA,  0x40000000, 4, 0x04000000),
    (ALU_SLT,  0xFFFFFFFF, 1, 1),                  
    (ALU_SLT,  1, 0xFFFFFFFF, 0),
    (ALU_SLTU, 0xFFFFFFFF, 1, 0),               
    (ALU_SLTU, 1, 2, 1),
]

@cocotb.test()
async def alu_ops(dut):
    for op, a, b, exp in CASES:
        dut.alu_sel.value = op
        dut.src_a.value = a
        dut.src_b.value = b
        await Timer(1, "ns")
        got = int(dut.result.value) & MASK32
        assert got == exp, f"op={op:04b} a={a:#x} b={b:#x}: got {got:#x} exp {exp:#x}"

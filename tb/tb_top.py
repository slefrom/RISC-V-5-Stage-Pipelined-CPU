import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly, ClockCycles

NOP  = 0x00000013

def R(rd, rs1, rs2, f3=0, f7=0):
    return f7 << 25 | rs2 << 20 | rs1 << 15 | f3 << 12 | rd << 7 | 0x33

def I(rd, rs1, imm, f3=0, op=19):
    return (imm & 0xFFF) << 20 | rs1 << 15 | f3 << 12 | rd << 7 | op

def B(rs1, rs2, off, f3=0):
    return ((off >> 12 & 1) << 31 | (off >> 5 & 0x3F) << 25 | rs2 << 20 | rs1 << 15 | f3 << 12 | (off >> 1 & 0xF) << 8 | (off >> 11 & 1) << 7 | 0x63)

def ADDI(rd, rs1, imm):
    return I(rd, rs1, imm)

def ADD(rd, rs1, rs2):
    return R(rd, rs1, rs2)

def LW(rd, rs1, imm):
    return I(rd, rs1, imm, 2, 0x03)

def BEQ(rs1, rs2, off):
    return B(rs1, rs2, off, 0)

def BNE(rs1, rs2, off):
    return B(rs1, rs2, off, 1)


async def setup(dut, prog, dmem=None):
    imem, dmem = dict(enumerate(prog)), dmem or {}
    cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

    async def mem_model():
        while True:
            await FallingEdge(dut.clk)  # addr settled after posedge, rdata stable before the next one
            dut.imem_rdata.value = imem.get(int(dut.imem_addr.value) >> 2, NOP)
            dut.dmem_rdata.value = dmem.get(int(dut.dmem_addr.value) >> 2, 0)

    cocotb.start_soon(mem_model())
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1


async def run(dut, cycles=20):
    hz, fwd, wb = [], set(), {}
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        await ReadOnly()  # sample hazard outputs as they stand for this cycle
        hz.append((int(dut.stall_d.value), int(dut.flush_d.value), int(dut.flush_e.value)))
        fwd.add(int(dut.forward_a.value))
        if dut.we_w.value and int(dut.rd_w.value):
            wb[int(dut.rd_w.value)] = int(dut.result_w.value)
    return hz, fwd, wb


@cocotb.test()
async def test_raw_hazard_ex_to_ex(dut):
    await setup(dut, [ADDI(1, 0, 5), ADD(2, 1, 1)])
    hz, fwd, wb = await run(dut)
    assert all(s == 0 for s, _, _ in hz)
    assert 0b10 in fwd  # forwarded from EX/MEM
    assert wb[1] == 5 and wb[2] == 10


@cocotb.test()
async def test_raw_hazard_mem_to_ex(dut):
    await setup(dut, [ADDI(1, 0, 7), ADDI(3, 0, 1), ADD(2, 1, 1)])
    hz, fwd, wb = await run(dut)
    assert all(s == 0 for s, _, _ in hz)
    assert 0b01 in fwd  # forwarded from MEM/WB
    assert wb[1] == 7 and wb[3] == 1 and wb[2] == 14


@cocotb.test()
async def test_load_use_hazard(dut):
    await setup(dut, [LW(1, 0, 0), ADD(2, 1, 1)], dmem={0: 0x1234})
    hz, _, wb = await run(dut)
    assert hz.count((1, 0, 1)) == 1 and sum(s for s, _, _ in hz) == 1 and sum(f for _, _, f in hz) == 1
    assert wb[1] == 0x1234 and wb[2] == 0x2468


@cocotb.test()
async def test_branch_mispredict_flush(dut):
    await setup(dut, [ADDI(1, 0, 3), BNE(1, 0, 8), ADDI(5, 0, 0x55), ADDI(6, 0, 0x66)])
    hz, _, wb = await run(dut)
    assert hz.count((0, 1, 1)) == 1
    assert 5 not in wb
    assert wb[1] == 3 and wb[6] == 0x66


@cocotb.test()
async def test_consecutive_branch_flushes(dut):
    prog = [ADDI(1, 0, 1), BEQ(0, 0, 8), ADDI(5, 0, 0x55), BNE(1, 0, 8),
            ADDI(6, 0, 0x66), BEQ(1, 0, 8), ADDI(7, 0, 0x77)]  # taken, taken, not-taken
    await setup(dut, prog)
    hz, _, wb = await run(dut)
    assert hz.count((0, 1, 1)) == 2 and all(s == 0 for s, _, _ in hz)
    assert 5 not in wb and 6 not in wb
    assert wb[1] == 1 and wb[7] == 0x77
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def setup(dut):
    cocotb.start_soon(Clock(dut.clk, 10, "ns").start())
    dut.wr_reg.value = 0
    dut.rd.value = 0
    dut.wr_data.value = 0
    dut.rs1.value = 0
    dut.rs2.value = 0
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


async def write(dut, rd, val):
    dut.rd.value = rd
    dut.wr_data.value = val
    dut.wr_reg.value = 1
    await RisingEdge(dut.clk)
    dut.wr_reg.value = 0


@cocotb.test()
async def x0_reads_zero(dut):
    await setup(dut)
    await write(dut, 0, 0xDEADBEEF)  
    dut.rs1.value = 0
    await Timer(1, "ns")
    assert int(dut.rs1_data.value) == 0


@cocotb.test()
async def write_then_read(dut):
    await setup(dut)
    await write(dut, 5, 0x12345678)
    dut.rs1.value = 5
    dut.rs2.value = 5
    await Timer(1, "ns")
    assert int(dut.rs1_data.value) == 0x12345678
    assert int(dut.rs2_data.value) == 0x12345678


@cocotb.test()
async def write_first_same_cycle(dut):
    await setup(dut)
    dut.rd.value = 7
    dut.wr_data.value = 0xCAFEBABE
    dut.wr_reg.value = 1
    dut.rs1.value = 7
    await Timer(1, "ns")
    assert int(dut.rs1_data.value) == 0xCAFEBABE



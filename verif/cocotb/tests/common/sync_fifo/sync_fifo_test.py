import os
import shutil
import pytest
import cocotb
from cocotb.triggers import RisingEdge
from cocotb_tools.runner import get_runner
from filelock import FileLock
from tb import TB


@cocotb.test()
async def test_reset(dut):
    tb = TB(dut)
    await tb.reset()
    result = await tb.cycle()

    assert result["empty"] == 1
    assert result["full"] == 0
    assert result["cnt"] == 0
    assert result["drop_cnt"] == 0
    assert result["dout_v"] == 0


@cocotb.test()
async def test_fill_and_drain_in_fifo_order(dut):
    tb = TB(dut)
    await tb.reset()

    values = [0x12, 0x34, 0x56, 0x78]

    for index, value in enumerate(values, start=1):
        result = await tb.cycle(wr_en=1, din=value)
        assert result["cnt"] == index
        assert result["dout_v"] == 0

    for index, expected_value in enumerate(values):
        result = await tb.cycle(rd_en=1)

        assert result["dout_v"] == 1
        assert result["dout"] == expected_value
        assert result["cnt"] == len(values) - index - 1

    result = await tb.cycle()
    assert result["empty"] == 1
    assert result["cnt"] == 0


@cocotb.test()
async def test_underflow_does_not_produce_valid_data(dut):
    tb = TB(dut)
    await tb.reset()

    result = await tb.cycle(rd_en=1)

    assert result["empty"] == 1
    assert result["cnt"] == 0
    assert result["dout_v"] == 0


@cocotb.test()
async def test_overflow_increments_drop_counter(dut):
    tb = TB(dut)
    await tb.reset()

    for value in range(tb.fifo_depth_param):
        result = await tb.cycle(wr_en=1, din=value)

    assert result["full"] == 1
    assert result["cnt"] == tb.fifo_depth_param

    result = await tb.cycle(wr_en=1, din=0xAA)

    assert result["full"] == 1
    assert result["cnt"] == tb.fifo_depth_param
    assert result["drop_cnt"] == 1


@cocotb.test()
async def test_simultaneous_read_write_while_nonempty(dut):
    tb = TB(dut)
    await tb.reset()

    await tb.cycle(wr_en=1, din=0x11)
    await tb.cycle(wr_en=1, din=0x22)

    result = await tb.cycle(wr_en=1, din=0x33, rd_en=1)

    assert result["dout_v"] == 1
    assert result["dout"] == 0x11
    assert result["cnt"] == 2

    result = await tb.cycle(rd_en=1)
    assert result["dout"] == 0x22

    result = await tb.cycle(rd_en=1)
    assert result["dout"] == 0x33


tests_dir = os.path.abspath(os.path.dirname(__file__))
base_dir = os.path.abspath(os.path.join(tests_dir, "..", "..", "..", "..", ".."))
rtl_dir = os.path.abspath(os.path.join(base_dir, "cores", "common"))
dut = "sync_fifo"


_BUILT_BUILDS = {}
COCOTB_TESTCASES = [
    "test_reset",
    "test_fill_and_drain_in_fifo_order",
    "test_underflow_does_not_produce_valid_data",
    "test_overflow_increments_drop_counter",
    "test_simultaneous_read_write_while_nonempty",
]
PARAMETER_SETS = [
    {
        "NUM": 0,
        "DATA_WIDTH": 8,
        "FIFO_DEPTH": 16,
        "CNT_WIDTH": 5,
        "DROP_CNT_WIDTH": 8,
    },
]


@pytest.fixture
def parameters(request):
    return request.param


@pytest.fixture
def cocotb_runner(parameters):
    build_key = "-".join(f"{k}-{v}" for k, v in parameters.items())
    if build_key in _BUILT_BUILDS:
        return _BUILT_BUILDS[build_key]

    sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    sim = os.getenv("SIM", "verilator")
    build_parameters = {k: v for k, v in parameters.items() if k != "NUM"}
    extra_env = {f"PARAM_{k}": str(v) for k, v in build_parameters.items()}
    build_dir = f"{tests_dir}/sim_build/{dut}_NUM{parameters['NUM']}"

    lock_file = os.path.join(build_dir, ".build.lock")
    os.makedirs(build_dir, exist_ok=True)
    with FileLock(lock_file, timeout=300):
        runner = get_runner(sim)
        runner.build(
            sources=sources,
            hdl_toplevel=dut,
            build_dir=build_dir,
            build_args=[
                "--coverage",
                "--Wno-WIDTHEXPAND",
                "--Wno-WIDTHTRUNC",
                "--timing",
                "-O3",
            ],
            parameters=build_parameters,
        )

    _BUILT_BUILDS[build_key] = (build_dir, runner, extra_env)
    return build_dir, runner, extra_env


@pytest.mark.parametrize("parameters", PARAMETER_SETS, indirect=True)
@pytest.mark.parametrize("testcase", COCOTB_TESTCASES)
def test_sync_fifo(testcase, cocotb_runner):
    build_dir, runner, extra_env = cocotb_runner
    module = os.path.splitext(os.path.basename(__file__))[0]
    lock_file = os.path.join(build_dir, ".run.lock")

    with FileLock(lock_file, timeout=300):
        runner.test(
            hdl_toplevel=dut,
            test_module=module,
            testcase=testcase,
            extra_env=extra_env,
        )

        cov_src = os.path.join(build_dir, "coverage.dat")
        cov_dst = os.path.join(build_dir, f"coverage_{testcase}.dat")

        if os.path.exists(cov_src):
            shutil.move(cov_src, cov_dst)

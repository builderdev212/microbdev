import os
import shutil
import pytest

import cocotb
from cocotb.triggers import RisingEdge
from cocotb_tools.runner import get_runner
from filelock import FileLock

from tb import TB


@cocotb.test()
async def test_counter(dut):
    tb = TB(dut)
    await RisingEdge(tb.clk)

    for i in range(10000):
        assert int(dut.counter.value) == i
        tb.log.info(f"Count: {int(dut.counter.value)}")
        assert tb.led.value == (
            int(dut.counter.value) >> (tb.counter_width_param - tb.led_count_param)
        )
        await RisingEdge(tb.clk)


tests_dir = os.path.abspath(os.path.dirname(__file__))
base_dir = os.path.abspath(os.path.join(tests_dir, "..", "..", "..", "..", ".."))
rtl_dir = os.path.abspath(os.path.join(base_dir, "cores", "basys3"))
dut = "led_shift_reg"


_BUILT_BUILDS = {}
COCOTB_TESTCASES = ["test_counter"]
PARAMETER_SETS = [
    {
        "NUM": 0,
        "LED_COUNT": 16,
        "COUNTER_WIDTH": 32,
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
def test_led_shift_reg(testcase, cocotb_runner):
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

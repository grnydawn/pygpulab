from pygpulab import GPULab

import os

here = os.path.dirname(os.path.abspath(__file__))


def test_basic(capsys):

    prj = GPULab()

    cmd = ""
    ret, fwds = prj.run_command(cmd)

    assert ret == 0

    captured = capsys.readouterr()
    assert "usage" in captured.out
    assert captured.err == ""

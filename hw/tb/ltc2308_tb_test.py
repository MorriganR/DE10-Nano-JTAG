import unittest
import os

NOT_FATAL = 0
vvp = "vvp ./tb/ltc2308_tb.vvp"
iverilog = "iverilog {} -y./tb -o ./tb/ltc2308_tb.vvp ./tb/ltc2308_tb.v"

class ltc2308(unittest.TestCase):
  def test_tWCLK_MIN(self):
    # in ltc2308_tb.v: tWCLK = 25_000

    # tWCLK > tWCLK_MIN => test - PASS
    self.assertEqual(os.system(iverilog.format("-D tWCLK_MIN=20_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    # tWCLK == tWCLK_MIN => test - PASS
    self.assertEqual(os.system(iverilog.format("-D tWCLK_MIN=25_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    # tWCLK < tWCLK_MIN => test - FAIL
    self.assertEqual(os.system(iverilog.format("-D tWCLK_MIN=25_001")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp), NOT_FATAL)

  def test_tWHCONV_MIN(self):
    # in ltc2308_tb.v: tWHCONV = 30_000

    # tWHCONV > tWHCONV_MIN => test - PASS
    self.assertEqual(os.system(iverilog.format("-D tWHCONV_MIN=20_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    # tWHCONV == tWHCONV_MIN => test - PASS
    self.assertEqual(os.system(iverilog.format("-D tWHCONV_MIN=30_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    # tWHCONV < tWHCONV_MIN => test - FAIL
    self.assertEqual(os.system(iverilog.format("-D tWHCONV_MIN=30_001")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp), NOT_FATAL)

  def test_tWHCONV_MAX(self):
    # in ltc2308_tb.v: tWHCONV = 30_000

    # tWHCONV < tWHCONV_MAX => test - PASS
    self.assertEqual(os.system(iverilog.format("-D tWHCONV_MAX=40_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    # tWHCONV == tWHCONV_MAX => test - PASS
    self.assertEqual(os.system(iverilog.format("-D tWHCONV_MAX=30_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    # tWHCONV > tWHCONV_MAX => test - FAIL
    self.assertEqual(os.system(iverilog.format("-D tWHCONV_MAX=29_999")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp), NOT_FATAL)

  @classmethod
  def tearDownClass(cls):
    dir_name = "./tb/"
    test = os.listdir(dir_name)

    for item in test:
      if (item.endswith(".vvp") or item.endswith(".vcd")) and (item.startswith("ltc2308_tb")):
        os.remove(os.path.join(dir_name, item))

    os.system(iverilog.format("-D get_vcd"))
    os.system(vvp)

if __name__ == '__main__':
  unittest.main()

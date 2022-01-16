import unittest
import os

NOT_FATAL = 0
vvp = "vvp ./tb/ltc2308_tb.vvp"
iverilog = "iverilog {} -y./tb -o ./tb/ltc2308_tb.vvp ./tb/ltc2308_tb.v"

class ltc2308(unittest.TestCase):
  def test_tWHCONV_MIN(self):
    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MIN=20_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MIN=30_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MIN=35_000")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp), NOT_FATAL)

  def test_tWHCONV_MAX(self):
    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MAX=40_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MAX=30_000")), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MAX=25_000")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp), NOT_FATAL)


if __name__ == '__main__':
  unittest.main()

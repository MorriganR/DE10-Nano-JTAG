import unittest
import os

NOT_FATAL = 0
vvp = "vvp -v ./tb/ltc2308_tb{}.vvp"
iverilog = "iverilog {} -y./tb -o ./tb/ltc2308_tb{}.vvp ./tb/ltc2308_tb.v"

class ltc2308(unittest.TestCase):
  def test_tWHCONV_MIN(self):
    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MIN=20_000", "0")), NOT_FATAL)
    self.assertEqual(os.system(vvp.format("0")), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MIN=30_000", "1")), NOT_FATAL)
    self.assertEqual(os.system(vvp.format("1")), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MIN=35_000", "2")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp.format("2")), NOT_FATAL)

  def test_tWHCONV_MAX(self):
    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MAX=40_000", "3")), NOT_FATAL)
    self.assertEqual(os.system(vvp.format("3")), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MAX=30_000", "4")), NOT_FATAL)
    self.assertEqual(os.system(vvp.format("4")), NOT_FATAL)

    self.assertEqual(os.system(iverilog.format("-DtWHCONV_MAX=25_000", "5")), NOT_FATAL)
    self.assertNotEqual(os.system(vvp.format("5")), NOT_FATAL)


if __name__ == '__main__':
  unittest.main()

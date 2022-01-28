import unittest
import os

NOT_FATAL = 0
iverilog = "iverilog -y./tb -y./main_unit/ -o ./tb/main_unit_tb.vvp ./tb/main_unit_tb.v"
vvp = "vvp ./tb/main_unit_tb.vvp"

class main_unit(unittest.TestCase):
  def test_main_unit(self):
    self.assertEqual(os.system(iverilog), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)


if __name__ == '__main__':
  unittest.main()

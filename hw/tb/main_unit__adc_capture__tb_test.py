import unittest
import os

NOT_FATAL = 0
iverilog = "iverilog -y./tb -y./main_unit/ -o ./tb/main_unit__adc_capture__tb.vvp ./tb/main_unit__adc_capture__tb.v"
vvp = "vvp ./tb/main_unit__adc_capture__tb.vvp"

class adc_capture(unittest.TestCase):
  def test_adc_capture(self):
    self.assertEqual(os.system(iverilog), NOT_FATAL)
    self.assertEqual(os.system(vvp), NOT_FATAL)


if __name__ == '__main__':
  unittest.main()

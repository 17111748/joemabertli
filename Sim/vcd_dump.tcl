# file path to dump vcd
database -open -vcd dump -into ./unary_shift_mac.vcd
# change design.DUT name to top level name  
probe -create unary_shift_mac_tb.dut -depth to_cells  -vcd -all -database dump -all -memories
run
exit

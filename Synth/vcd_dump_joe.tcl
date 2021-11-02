# file path to dump vcd
database -open -vcd dump -into ./counter_mxu.vcd
# change design.DUT name to top level name  
probe -create mxu_full_tb.dut -depth to_cells  -vcd -all -database dump -all -memories
run
exit

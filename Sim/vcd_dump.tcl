# file path to dump vcd
database -open -vcd dump -into ./unary_multiplier.vcd
# change design.DUT name to top level name
probe -create unary_multiplier_tb.dut -depth to_cells  -vcd -all -database dump -all -memories
run
exit

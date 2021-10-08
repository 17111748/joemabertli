# file path to dump vcd
database -open -vcd dump -into ./systolic_unary.vcd
# change design.DUT name to top level name  
probe -create systolic_unary_matmul_tb.dut -depth to_cells  -vcd -all -database dump -all -memories
run
exit

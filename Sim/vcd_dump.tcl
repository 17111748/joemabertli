# file path to dump vcd
database -open -vcd dump -into ./vcd_gen/design.vcd
# change design.DUT name to top level name  
probe -create design.DUT -depth to_cells  -vcd -all -database dump -all -memories
run
exit

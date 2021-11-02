analyze -library WORK -format sverilog {bitonic_sort_2.sv bitonic_sort_4.sv bitonic_sort_8.sv bitonic_sort_16.sv bitonic_sort_32.sv neuron_snl_grl.sv}

elaborate neuron_snl_grl -architecture verilog -library WORK

set_dont_touch neuron_snl_grl

# Create user defined variables 
set CLK_PERIOD 10000.00 
set CLK_SKEW   [expr {$CLK_PERIOD} * 0.04]

# set INPUT_DELAY [expr {$CLK_PERIOD} * 0.1]

# set OUTPUT_DELAY [expr {$CLK_PERIOD} * 0.05]

create_clock -period $CLK_PERIOD -name my_clock
set_clock_uncertainty $CLK_SKEW my_clock

# set_input_delay $INPUT_DELAY -max -clock my_clock [remove_from_collection [all_inputs] my_clock]
# set_output_delay $OUTPUT_DELAY -max -clock my_clock [all_outputs]

compile -map_effort low -area_effort none -power_effort none

report_area                                                                                                                  > simresults/neuron.area
report_power                                                                                                                 > simresults/neuron.pow
report_timing -nworst 3                                                                                                      > simresults/neuron.tim

check_timing
check_design
#exit

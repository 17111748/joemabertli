# set work library to dump intermediate files
define_design_lib work -path ./work

# Set the technology
set search_path "../../Synth/";
set target_library "NangateOpenCellLibrary_typical_ccs.db";
set symbol_library "NangateOpenCellLibrary_typical_ccs.sdb";

#set synthetic_library {standard.sldb dw_foundation.sldb}
#set link_library {"*" cmulib18.db dw_foundation.sldb}
#set synlib_wait_for_design_license {DesignWare-Foundation}

#set link_library "NangateOpenCellLibrary_typical_ccs.db"; 

# generate reports and save them to a file
set AREA_RPT ./area.rpt
set TIME_RPT ./time.rpt
set POWER_RPT ./power.rpt

# Small loop to read in several files
set all_files {counter_array.sv multiplier.sv vector_in.sv tb_define.vh}
foreach file $all_files {
  set module_source "./$file"
  set both "{$module_source}"
  read_file -f sverilog $both
  analyze -f sverilog $both
}

#read_file -f verilog ./gatelib.v
#analyze -f verilog ./gatelib.v

# to avoid 'assign' statements
set_fix_multiple_port_nets -all -buffer_constants 

#Specify top-level module name
current_design multiplier

#Specify clock
create_clock -period 2.5 -waveform {0 0.5} clk

# Uniquify (optional) and compile
uniquify
compile
# Do incremental compile (optional)
compile -incremental

redirect $AREA_RPT { report_area }
# type 'man report_timing' withing DC shell to see what these options mean
redirect $TIME_RPT { report_timing -path full -delay max -max_paths 1 -nworst 1}
redirect $POWER_RPT { report_power }

quit
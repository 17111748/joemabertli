#### Template Script for RTL->Gate-Level Flow (generated from GENUS 18.14-s037_1) 

if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

##############################################################################
## Preset global variables and attributes
##############################################################################

#set P 82
#set Q 2
#set THRES 13

# top-level module name
set DESIGN column
set GEN_EFF high
set MAP_OPT_EFF high
set DATE [clock format [clock seconds] -format "%b%d-%T"] 
set _OUTPUTS_PATH ./output/
set _REPORTS_PATH ./report/
set _LOG_PATH ./log/

# specify vcd file path (can also replace vcd with tcf)
set vcd_file /afs/ece.cmu.edu/usr/pvellais/Private/New_DATE/Sim/rtl/std/column82x2.vcd

# Change! paths to asap7 lib and lef folder
set_db / .init_lib_search_path {/afs/ece.cmu.edu/usr/pvellais/Private/ASAP7/ASAP7_PDKandLIB_v1p6/lib_release_191006/asap7_7p5t_library/rev25/LIB/CCS/ /afs/ece.cmu.edu/usr/pvellais/Private/ASAP7/ASAP7_PDKandLIB_v1p6/lib_release_191006/asap7_7p5t_library/rev25/LEF/}
# Change! path to tcl script
set_db / .script_search_path {/afs/ece.cmu.edu/usr/pvellais/Private/New_DATE/Synth/new_tcl/}
# Change! rtl path
set_db / .init_hdl_search_path {/afs/ece.cmu.edu/usr/pvellais/Private/New_DATE/RTL/src_original/} 

set_db / .information_level 7 

set_db auto_ungroup none

set_db libscore_enable true 

###############################################################
## Library setup
###############################################################

read_libs " \
      asap7sc7p5t_AO_RVT_TT_ccs_191031.lib \
    asap7sc7p5t_INVBUF_RVT_TT_ccs_191031.lib \
    asap7sc7p5t_OA_RVT_TT_ccs_191031.lib\
    asap7sc7p5t_SEQ_RVT_TT_ccs_191031.lib \
    asap7sc7p5t_SIMPLE_RVT_TT_ccs_191031.lib \
"
read_physical -lef " \
  asap7_tech_4x_181009.lef \
  asap7sc7p5t_24_R_4x_170912.lef \
"

# Change! path to qrcTech
read_qrc /afs/ece.cmu.edu/usr/pvellais/Private/ASAP7/ASAP7_PDKandLIB_v1p6/lib_release_191006/asap7_7p5t_library/rev25/qrc/qrcTechFile_typ03_scaled4xV06
set_db / .hdl_generate_index_style %s_%d_
set_db / .lp_insert_clock_gating false
set_db / .hdl_track_filename_row_col true 
#set_db lp_power_unit uW 

####################################################################
## Load Design
####################################################################
# Change! specify rtl files to synthesize
read_hdl -language sv "adder.sv  edge2pulse.sv incdec.sv neuron_body.sv pac.sv stdp_case_gen.sv wta.sv column82x2.sv  flogic.sv fsm_simple.sv  less_equal.sv  neuron_rnl_ptt.sv  pulse2edge.sv  stdp.sv fsm_synapse.sv "
elaborate $DESIGN
puts "Runtime & Memory after 'read_hdl'"
time_info Elaboration

check_design -unresolved

####################################################################
## Constraints Setup
####################################################################

# Change! sdc file name (should be inside folder with tcl script)
read_sdc chip.sdc
puts "The number of exceptions is [llength [vfind "$DESIGN" -exception *]]"

if {![file exists ${_LOG_PATH}]} {
  file mkdir ${_LOG_PATH}
  puts "Creating directory ${_LOG_PATH}"
}

if {![file exists ${_OUTPUTS_PATH}]} {
  file mkdir ${_OUTPUTS_PATH}
  puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}
check_timing_intent

###################################################################################
## Define cost groups (clock-clock, clock-output, input-clock, input-output)
###################################################################################

if {[llength [all_registers]] > 0} { 
  define_cost_group -name I2C -design $DESIGN
  define_cost_group -name C2O -design $DESIGN
  define_cost_group -name C2C -design $DESIGN
  path_group -from [all_registers] -to [all_registers] -group C2C -name C2C
  path_group -from [all_registers] -to [all_outputs] -group C2O -name C2O
  path_group -from [all_inputs]  -to [all_registers] -group I2C -name I2C
}

define_cost_group -name I2O -design $DESIGN
path_group -from [all_inputs]  -to [all_outputs] -group I2O -name I2O
foreach cg [vfind / -cost_group *] {
  report_timing -group [list $cg] >> $_REPORTS_PATH/${DESIGN}_pretim.rpt
}

#set_pin_activity -activity_type system -duty 0.5 -freq 100000 -global
#set_db lp_power_analysis_effort high

####################################################################
## Annotate Switching
####################################################################

# Change! DUT name
read_vcd $vcd_file -vcd_scope column_tb/DUT

####################################################################
## Power Constraints Setup
####################################################################

set_db lp_power_analysis_effort medium


####################################################################################################
## Synthesizing to generic 
####################################################################################################

set_db / .syn_generic_effort $GEN_EFF
syn_generic

build_rtl_power_models -clean_up_netlist

puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC
report_dp > $_REPORTS_PATH/generic/${DESIGN}_datapath.rpt
write_snapshot -outdir $_REPORTS_PATH -tag generic
report_summary -directory $_REPORTS_PATH


# ####################################################################################################
# ## Synthesizing to gates
# ####################################################################################################

 set_db / .syn_map_effort $MAP_OPT_EFF
 syn_map
 puts "Runtime & Memory after 'syn_map'"
 time_info MAPPED
 write_snapshot -outdir $_REPORTS_PATH -tag map
 report_summary -directory $_REPORTS_PATH
 report_dp > $_REPORTS_PATH/map/${DESIGN}_datapath.rpt

 foreach cg [vfind / -cost_group *] {
   report_timing -group [list $cg] > $_REPORTS_PATH/${DESIGN}_[vbasename $cg]_post_map.rpt
 }


#######################################################################################################
## Optimize Netlist
#######################################################################################################
 
set_db / .syn_opt_effort $MAP_OPT_EFF
syn_opt
set_db [get_db lib_cells] .cell_delay_multiplier 1.0
write_snapshot -outdir $_REPORTS_PATH -tag syn_opt
report_summary -directory $_REPORTS_PATH

puts "Runtime & Memory after 'syn_opt'"
time_info OPT

foreach cg [vfind / -cost_group *] {
  report_timing  -group [list $cg] > $_REPORTS_PATH/${DESIGN}_[vbasename $cg]_post_opt.rpt
}

######################################################################################################
## write backend file set (verilog, SDC, config, etc.)
######################################################################################################

report_timing -path_type full -max_paths 100 -nworst 100 > $_REPORTS_PATH/${DESIGN}_timing.rpt
report_messages > $_REPORTS_PATH/${DESIGN}_messages.rpt
write_snapshot -outdir $_REPORTS_PATH -tag final
report_summary -directory $_REPORTS_PATH
write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}_m.v
write_script > ${_OUTPUTS_PATH}/${DESIGN}_m.script
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_m.sdc

write_sdf -timescale ns -precision 3 > ${_OUTPUTS_PATH}/${DESIGN}_m.sdf

# Change! DUT name
read_vcd $vcd_file -vcd_scope column_tb/DUT
report_power > $_REPORTS_PATH/${DESIGN}_power.rpt

#################################
### write_do_lec
#################################

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

exit


# change DUT name and output file name/path
dumptcf -scope design.DUT -internal -memories -overwrite -output "tcf_gen/design.tcf" -inctoggle
run
exit

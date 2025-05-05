
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name ula -dir "/home/sd/ula/planAhead_run_3" -part xc3s700anfgg484-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "ula.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {../Desktop/ula/debouncer.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../Desktop/ula/ula.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top ula $srcset
add_files [list {ula.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s700anfgg484-4

catch {vdel -all -lib work}
vlib work
vmap work work

set TOP_ENTITY {work.tb}

vlog -work work my_FPU.sv
vlog -work work tb.sv

vsim -voptargs=+acc ${TOP_ENTITY}

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

do wave.do
run 1ms
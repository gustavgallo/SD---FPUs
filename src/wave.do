onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock & Reset}
add wave -noupdate -radix binary /tb/clk
add wave -noupdate -color {Blue Violet} /tb/rst
add wave -noupdate -divider Entradas
add wave -noupdate -radix hexadecimal /tb/send_A
add wave -noupdate -radix hexadecimal /tb/send_B
add wave -noupdate -divider Sai­das
add wave -noupdate -radix hexadecimal /tb/result
add wave -noupdate -radix binary /tb/op_status
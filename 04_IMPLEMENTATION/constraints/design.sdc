# C07 - SDC Constraints
# Mach TUAN TU: dinh nghia clock that tu cong clock cua thiet ke.
# Chu ky 10 ns va IO delay 1 ns la GIA DINH phan tich khoi diem,
# KHONG phai yeu cau he thong.

create_clock -name clk -period 10.0 [get_ports clk]

# Tiny Tapeout Inputs: ui_in, uio_in, rst_n, ena
set_input_delay  1.0 -clock clk [get_ports {ui_in[*] uio_in[*] rst_n ena}]

# Tiny Tapeout Outputs: uo_out, uio_out, uio_oe
set_output_delay 1.0 -clock clk [get_ports {uo_out[*] uio_out[*] uio_oe[*]}]

.PHONY: all setup gui clean
all: setup gui
setup: 
	vivado -mode batch -source create_project.tcl -nolog -nojournal
gui: 
	vivado -mode gui lab2_fpga/lab2_fpga.xpr  -nolog -nojournal
gui_log: 
	vivado -mode gui lab2_fpga/lab2_fpga.xpr  -nojournal
clean:
	rm -rf lab2_fpga
	rm -rf *.log
	rm -rf *.jou
	rm -rf *.str
	rm -rf *.pb
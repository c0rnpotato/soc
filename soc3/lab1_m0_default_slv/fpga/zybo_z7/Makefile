.PHONY: all setup gui clean
all: setup gui
setup: 
	vivado -mode batch -source create_project.tcl -nolog -nojournal
gui: 
	vivado -mode gui lab1_fpga/lab1_fpga.xpr  -nolog -nojournal
gui_log: 
	vivado -mode gui lab1_fpga/lab1_fpga.xpr  -nojournal
clean:
	rm -rf lab1_fpga
	rm -rf *.log
	rm -rf *.jou
	rm -rf *.str
	rm -rf *.pb
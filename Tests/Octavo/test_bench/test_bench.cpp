
// Test bench driver.
// Based off Dan Gisselquist's work: http://zipcpu.com/blog/2017/06/21/looking-at-verilator.html

// General code
#include <stdlib.h>
#include <stdbool.h>

// Specific to the DUT and Verilator
#include "VDUT.h"
#include <verilated.h>
#include <verilated_vcd_c.h>

int
main
(
    int     argc,
    char ** argv
)
{
    int cycles_executed = 0;
    int cycles_to_run   = 1000; 

    // Current simulation time (64-bit unsigned)
    vluint64_t main_time = 0;
	
    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
	Verilated::commandArgs(argc, argv);

    // Set debug level, 0 is off, 9 is highest presently used
    Verilated::debug(9);

	// Create an instance of our Device Under Test
	VDUT *DUT = new VDUT;

    // Setup VCD dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* vcd = new VerilatedVcdC;
    // Trace 99 levels of hierarchy
    DUT->trace(vcd, 99);
    vcd->open("dump.vcd");

    // Make sure all state is initialized
	DUT->clock = 0;
    DUT->eval();

	// Tick the clock until we are done
	while(true) {
		DUT->clock = 0;
		DUT->eval();
        vcd->dump(main_time);
        main_time++;

		DUT->clock = 1;
		DUT->eval();
        vcd->dump(main_time);
        main_time++;
        
        cycles_executed++;

	    if ( (cycles_executed == cycles_to_run) || (Verilated::gotFinish() == true) )
        {
            printf("Simulation terminated normally at cycle %u\n", cycles_executed);
            DUT->final();
            vcd->close();
            delete vcd;
            vcd = NULL;
            delete DUT;
            DUT = NULL;
            exit(EXIT_SUCCESS);
        }
	}

    printf("Simulation terminated abnormally. Executable likely corrupted.\n");
    exit(EXIT_FAILURE);
}


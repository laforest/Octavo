
// Test bench driver.
// Based off Dan Gisselquist's work: http://zipcpu.com/blog/2017/06/21/looking-at-verilator.html

// General code
#include <stdlib.h>
#include <stdbool.h>

// Specific to the DUT and Verilator
#include "VDUT.h"
#include "verilated.h"

int
main
(
    int     argc,
    char ** argv
)
{
    int cycles_executed = 0;
    int cycles_to_run   = 1000; 

	// Initialize Verilator's variables
	Verilated::commandArgs(argc, argv);

	// Create an instance of our Device Under Test
	VDUT *DUT = new VDUT;

    // Make sure all state is initialized
	DUT->clock = 0;
    DUT->eval();

	// Tick the clock until we are done
	while(true) {
		DUT->clock = 0;
		DUT->eval();
		DUT->clock = 1;
		DUT->eval();
        
        cycles_executed++;

	    if ( (cycles_executed == cycles_to_run) || (Verilated::gotFinish() == true) )
        {
            printf("Simulation terminated normally at cycle %u\n", cycles_executed);
            exit(EXIT_SUCCESS);
        }
	}

    printf("Simulation terminated abnormally. Executable likely corrupted.\n");
    exit(EXIT_FAILURE);
}


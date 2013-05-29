
// Name definitions precede.

    initial begin
        // Avoids later-on synthesis warnings from X values
        for(i = 0; i <= END_ADDR; i = i + 1) mem[i] = 0;
        // Always all 0 in mem[0], always executed by first thread
        `ALIGN(0)
        `NOP
        `ALIGN(START_ADDR)

// Assembly code follows.


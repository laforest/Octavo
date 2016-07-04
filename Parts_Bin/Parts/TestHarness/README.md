
The test harness exists solely to isolate I/O to prevent overly optimistic
optimizations (and thus timing results). It also reduces the number of pins to
1 bit per I/O to prevent running out during testing. The test harness is not
usable for simulation, as the I/O values are mangled to nonsense.


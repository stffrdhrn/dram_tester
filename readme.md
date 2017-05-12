## SDRAM Tester

This is a test module for my [SDRAM
controller](https://github.com/stffrdhrn/sdram-controller).  On reset it
will:

1. Wait for initialization to complete
2. Loop from 0-memsize, writing to all addresses a checksum value
3. Loop from 0-memsize, reading all values back in and verifying the
   checksum
4. If any mismatches it will go to state FAIL
5. If all values match it will go to state PASS

### To Run

*Testing*

I use fusesoc to kick off iverilog.

```
  fusesoc sim dram_tester --vcd

  # open the vcd file with gtkwave
  gtkwave ${FUSESOC_BUILD}/dram_tester/sim-icarus/testlog.vcd
```

*On FPGA*

Fusesoc is also used to build using quartus and load into the fpga

```
  # Quartus build
  fusesoc build dram_tester

  # FPGA program (currently de0 nano only)
  fusesoc pgm dram_tester
```



### Notes

- This uses micron memory module for simulation
  [zip](http://www.micron.com/~/media/Documents/Products/Sim%%20Model/DRAM/DRAM/4012mt48lc16m16a2.zip)

#!/bin/bash
iverilog -o wave tb_gpu_small.v
vvp -n wave
gtkwave wave.vcd
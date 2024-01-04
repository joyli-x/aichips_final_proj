# AIChips Lab 1
A 'gpgpu' with 4 'cpu' core which can do 16*16 matrix multiplication and relu parallelly.

## Quik Start
First, generate input matrix by running ```generate_input.ipynb```

Then run the gpu by:
```
iverilog -o wave tb_gpu_small.v
vvp -n wave
```

Finally we can check the answer by running the ```check``` function in ```generate_input.ipynb```


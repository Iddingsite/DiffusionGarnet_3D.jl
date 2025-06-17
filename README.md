[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15680919.svg)](https://doi.org/10.5281/zenodo.15680919)

This repository contains the Julia scripts used to generate the data for the paper "Simulating major element diffusion in garnet using realistic 3D geometries" by Dominguez et al. (2025). They can be used to reproduce the results presented in the paper by running the scripts in the `scripts` directory.

### Running the scripts

To get started, clone or download this repository, launch Julia in project mode `julia --project` and `instantiate` or `resolve` the dependencies from within the REPL in package mode `julia> ]`.

The scripts can be launched either from within the REPL:
```julia-repl
julia> include("scripts/<script_name>.jl")
```
or executed from the shell as:
```shell
julia --project -t auto "scripts/<script_name>.jl"
```

Note that for optimal performance, it is recommended to run the scripts with multiple threads. You can set the number of threads by using the `-t` option, e.g., `-t auto` will use all available threads on your machine.

To run the GPU version of the scripts, you need an NVIDIA GPU with CUDA support.

The first step consists as initialising DiffusionGarnet.jl to be compatible with GPUs using ParallelStencil.jl. To do so, we first need to load DiffusionGarnet.jl, modify its backend, and start again a new session.

To do so, you can run this command in your terminal:

```
julia --project=. -e '
using DiffusionGarnet
set_backend("CUDA_Float32_3D")
exit()'
```

Going line by line, this command will:
1. Start Julia in the current project folder and activate the project environment.
2. Load DiffusionGarnet.jl.
3. Set the backend to `CUDA_Float32_3D`.
4. Exit Julia.

To switch back to multithread mode on CPU, replace `CUDA` by `Threads` on the command.

Then, the scripts including `GPU` can be run as usual, but they will now run on the GPU.

The scripts `CPU_save_data.jl` and `GPU_save_data.jl` will also save to disk the results of the simulation whereas `CPU_performance` and `GPU_performance` will only save the total run time of the simulation in a text file. Two files will be created in the same folder as your current session at the end of the simulation: `data_model_10_Myr.h5` and `data_model_10_Myr.xdmf`. The first one is the HDF5 file containing the results of the simulation, and the second one is an XDMF file describing the HDF5 file. This last file can be opened with visualisation software programs, such as [ParaView](https://www.paraview.org/). For any visualisation software, make sure you open the XDMF file and not the HDF5 file. For ParaView, select the XDMF Reader as the reader when you open your data. Only Paraview has been tested with this package, but other software should work as well.

Author: Hugo Dominguez (hdomingu@univ-mainz.de).

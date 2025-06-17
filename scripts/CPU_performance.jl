#=
This script demonstrates how to simulate element diffusion in a 3D domain using the DiffusionGarnet.jl package. It also serves as the reproducibility file for the manuscript “Simulating Major Element Diffusion in Garnet Using Realistic 3D Geometries” by Dominguez et al. (2025).
=#

using Downloads
using JLD2
using DiffusionGarnet
using Printf

# define the current directory as the working directory
cd(@__DIR__)

# print number of threads
println("Number of threads: ", Threads.nthreads())

# Define the Zenodo dataset URL, you can change the name to download other datasets in the Zenodo repository (https://zenodo.org/records/15045718)
# here, we will download the lowest resolution dataset (256³) to save time, for the model isolated matrix model (IMM). See publication for more details.
data_file = "256_cubed_IMM_compo.jld2"

println("\nDownloading the dataset from Zenodo, this may take a while...")

# check if the file is already downloaded
if !isfile(data_file)
    # Define the Zenodo dataset URL, you can change the name to download other datasets in the Zenodo repository.
    zenodo_url = "https://zenodo.org/records/15045718/files/" * data_file * "?download=1"

    # Download the file in the same folder as this file (this can take a while if you connection is slow)
    Downloads.download(zenodo_url, data_file)

    println("Dataset downloaded successfully.")
else
    println("File already exists, skipping download.")
end


println("\nLoading the dataset...")

# use JLD2
file = jldopen(data_file, "r")
@unpack Mg0, Fe0, Mn0, Ca0, grt_boundary = file
close(file)

# define total length in x and y
Lx = 11422.61u"µm"
Ly = 11422.61u"µm"
Lz = 7623.57u"µm"
# define total time for the model
tfinal = 10.0u"Myr"
# define the pressure and temperature conditions
T = 700u"°C"
P = 0.8u"GPa"

# composition at the contact between garnet and matrix
Mg_border = 0.1152
Fe_border = 0.6012
Mn_border = 0.0435
Ca_border = 0.2401

# add this to fix the composition on the boundary
Mg0[grt_boundary .== 1] .= Mg_border
Fe0[grt_boundary .== 1] .= Fe_border
Mn0[grt_boundary .== 1] .= Mn_border
Ca0[grt_boundary .== 1] .= Ca_border

# convert to float32
Mg0 = convert(Array{Float32}, Mg0)
Fe0 = convert(Array{Float32}, Fe0)
Mn0 = convert(Array{Float32}, Mn0)
Ca0 = convert(Array{Float32}, Ca0)
grt_boundary = convert(Array{Float32}, grt_boundary)

IC3D = DiffusionGarnet.InitialConditions3D(Mg0, Fe0, Mn0, Lx, Ly, Lz, tfinal; grt_boundary=grt_boundary)
domain3D = Domain(IC3D, T, P)

# free memory, as 3D data is large
file = nothing
data = nothing
Mg0 = nothing
Fe0 = nothing
Mn0 = nothing
Ca0 = nothing
grt_boundary = nothing
IC3D = nothing

println("Domain created successfully.")
println("\nRunning the simulation...")

# run the simulation with ROCK2 solver
time_sim = @elapsed simulate(domain3D; save_everystep=false,  save_start=false, progress=true, progress_steps=1, solver=ROCK2());


# save first 3 characters of the dataset name to use in the output file
dataset_name = splitext(basename(data_file))[1][1:3]



# save the value of time in a file
open("time_CPU_$(dataset_name).txt", "w") do io
    @printf(io, "Total run time: %.4f s", time_sim)
end

println("\nSimulation completed successfully in $(round(time_sim)) seconds.")

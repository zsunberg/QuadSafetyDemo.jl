struct HJValueFunction{N} <: Function
    grid::RectangleGrid{N}
    data::Array{Float64, N}
end

HJValueFunction(matfile::AbstractString) = matopen(f->HJValueFunction(f), matfile)

function HJValueFunction(matfile_handle::HDF5.DataFile)
    data = read(matfile_handle, "data")
    schemeData = read(matfile_handle, "schemeData")
end

(v::HJValueFunction)(x::AbstractVector) = interpolate(v.grid, v.data, x)

struct LinearQuadValueFunction <: Function
    ls::Vector{Float64}                 # sorted smallest to largest
    vfuncs::Vector{HJValueFunction{4}}
end

function LinearQuadValueFunction(dir::AbstractString)
    ls = Float64[]
    vfuncs = HJValueFunction{4}[]
    for file in readdir(dir)

    end
end

function (v::QuadValueFunction)(x::HorizontalState)
    i = searchsortedfirst(v.ls, s.l)
    return vfuncs[i](HorizontalDynamicState(x))
end
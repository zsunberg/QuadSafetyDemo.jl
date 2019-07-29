struct HJValueFunction{N} <: Function
    grid::RectangleGrid{N}
    data::Array{Float64, N}
end

HJValueFunction(matfile::AbstractString) = matopen(f->HJValueFunction(f), matfile)

function HJValueFunction(matfile_handle::HDF5.DataFile)
    data = read(matfile_handle, "lastData")
    matgrid = read(matfile_handle, "safegrid")
    cutpoints = [vec(v) for v in matgrid["vs"]]
    return HJValueFunction(RectangleGrid(cutpoints...), data)
end

(v::HJValueFunction)(x::AbstractVector) = interpolate(v.grid, v.data, x)

Base.extrema(v::HJValueFunction) = extrema(v.data)

struct LinearQuadValueFunction <: Function
    ls::Vector{Float64}                 # sorted smallest to largest
    vfuncs::Vector{HJValueFunction{4}}
end

function LinearQuadValueFunction(m::LinearQuad, dir::AbstractString)
    ls = Float64[]
    vfuncs = HJValueFunction{4}[]
    for filename in readdir(dir)
        matopen(joinpath(dir, filename)) do f
            p = read(f, "physParams")
            @assert minimum(actions(m)) <= -p["maxTheta"]
            @assert maximum(actions(m)) >= p["maxTheta"]
            @assert p["m1"] == m.m1
            @assert p["m2"] == m.m2
            @assert p["leftWall"] >= m.leftwall
            @assert p["grav"] == g
            push!(ls, read(f, "physParams")["l"])
            push!(vfuncs, HJValueFunction(f))
        end
    end
    p = sortperm(ls)
    LinearQuadValueFunction(ls[p], vfuncs[p])
end

function (v::LinearQuadValueFunction)(s::HorizontalState)
    i = searchsortedfirst(v.ls, s.l)
    return v.vfuncs[i](HorizontalDynamicState(s))
end

function Base.extrema(v::LinearQuadValueFunction)
    exs = map(extrema, v.vfuncs)
    return (minimum(map(first, exs)), maximum(map(last, exs)))
end    

function safe_actions(m::LinearQuad, v::LinearQuadValueFunction, b; eps::Float64=0.0)
    safeacts = actiontype(m)[]
    for a in actions(m)
        if issafe(m, v, b, a, eps=eps)
            push!(safeacts, a)
        end
    end
    return safeacts
end

function safest_action(m::LinearQuad, v::LinearQuadValueFunction, b)
    acts = collect(actions(m))
    vals = similar(acts, Float64)
    for (i,a) in enumerate(acts)
        val = 0.0
        for (s,w) in weighted_particles(b)
            sp = dynamics(m, s, a)
            val += w*v(sp)
        end
        vals[i] = val/weight_sum(b)
    end
    besti = argmin(vals)
    return acts[besti]
end

function issafe(m::LinearQuad, v::LinearQuadValueFunction, b, a; eps::Float64=0.0)
    for s in particles(b)
        sp = dynamics(m, s, a)
        if v(sp) > -eps
            return false
        end
    end
    return true
end

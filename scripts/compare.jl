using POMDPs
using QuadSafetyDemo
using POMDPSimulators
using ParticleFilters
using DataFrames
using Printf
using Statistics

N = 10
dt = 0.2
const m = LinearQuad(timestep=dt, obsnoise=0.02)

policies = Dict(
    "periodic" => TimeDependentUntilSafe((b,t)->0.2*sin(5t), m),
    "random" => TimeDependentUntilSafe((b,t)->rand(POMDPs.actions(m)), m)
)

alldata = DataFrame()
for (name, p) in policies
    @show name
    queue = []
    for i in 1:N
        re = LinearQuadResampler(1000, 1e-5)
        up = BasicParticleFilter(m, re, 1000)
        sup = StepUpdater(up)
        sm = Sim(m, p, sup, metadata=(policy=name,), max_steps=100)
        push!(queue, sm)
    end
    df = run_parallel(queue)

    rs = df[:reward]
    println(@sprintf("reward: %6.3f ± %6.3f", mean(rs), std(rs)/sqrt(length(rs))))

    if isempty(alldata)
        global alldata = df
    else
        global alldata = vcat(alldata, df)
    end
end

using POMDPs
using QuadSafetyDemo
using POMDPSimulators
using ParticleFilters
using DataFrames
using Printf
using Statistics
using Distributions
using Random

let
    N = 10
    dt = 0.2
    noise = 0.05
    m = LinearQuad(timestep=dt, obsmodel=(a,sp)->Normal(sp.x, noise))
    safety_value = LinearQuadValueFunction(joinpath(dirname(@__FILE__), "..", "matlab", "data"))

    policies = Dict(
        "periodic" => TimeDependentUntilSafe(m) do b,t
            a = 0.2*sin(5t)
            if issafe(m, safety_value, b, a)
                return a
            else
                return safest_action(m, safety_value, b)
            end
        end,
        "random" => TimeDependentUntilSafe(m) do b, t
            vals = map(safety_value, particles(b))
            safeacts = safe_actions(m, safety_value, b, eps=0.2)
            if isempty(safeacts)
                return safest_action(m, safety_value, b)
            else
                return rand(safeacts)
            end
        end
    )

    alldata = DataFrame()
    for (name, p) in policies
        @show name
        queue = []
        for i in 1:N
            re = LinearQuadResampler(1000, 1e-5)
            up = BasicParticleFilter(m, re, 1000)
            sup = StepUpdater(up)
            sm = Sim(m, p, sup, metadata=(policy=name,), max_steps=300, rng=MersenneTwister(400000+i))
            push!(queue, sm)
        end
        df = run_parallel(queue) do sim, hist
            return (n_steps=n_steps(hist), reward=discounted_reward(hist))
        end

        rs = df[:reward]
        println(@sprintf("reward: %6.3f ± %6.3f", mean(rs), std(rs)/sqrt(length(rs))))

        if isempty(alldata)
            alldata = df
        else
            alldata = vcat(alldata, df)
        end
    end

    display(alldata)
end

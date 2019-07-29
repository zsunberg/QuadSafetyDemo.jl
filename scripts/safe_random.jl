using Revise
using POMDPs
using BlinkPOMDPSimulator
using QuadSafetyDemo
using POMDPPolicies
using POMDPSimulators
using Distributions
using POMDPGifs
using ParticleFilters

let
    dt = 0.2
    noise = 0.05
    m = LinearQuad(timestep=dt, obsmodel=(a,sp)->Normal(sp.x, noise))
    safety_value = LinearQuadValueFunction(m, joinpath(dirname(@__FILE__), "..", "matlab", "data"))
    policy = TimeDependentUntilSafe(m) do b, t
        vals = map(safety_value, particles(b))
        if any(vals .>= 0.0)
            @warn("$(count(vals.>=0.0))/$(length(particles(b))) states unsafe. 22222222222222", t=t)
        end
        safeacts = safe_actions(m, safety_value, b, eps=0.05)
        if isempty(safeacts)
            @warn("no safe actions! using safest 111111111111111", t=t)            
            return safest_action(m, safety_value, b)
        else
            return rand(safeacts)
        end
    end
    up = SIRParticleFilter(m, 10_000)
    sup = StepUpdater(up)

    bs = BlinkSimulator(max_fps=1.0/m.timestep, render_kwargs=(maxghosts=100,), extra_final=true)
    simulate(bs, m, policy, sup, initialstate_distribution(m))
end

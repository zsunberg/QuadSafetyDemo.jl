using POMDPs
using BlinkPOMDPSimulator
using QuadSafetyDemo
using POMDPPolicies
using POMDPSimulators
using POMCPOW
using Distributions
using Debugger
using ProfileView
using Profile
using BenchmarkTools
using POMDPGifs
using ParticleFilters

let
    dt = 0.2
    noise = 0.05
    m = LinearQuad(timestep=dt, obsmodel=(a,sp)->Normal(sp.x, noise))
    # policy = TimeDependentUntilSafe((b,t)->0.1*sin(5t), m)
    safety_value = LinearQuadValueFunction("../matlab/data")
    policy = TimeDependentUntilSafe(m) do b, t
        rand(safeactions(m, safety_value, b))
    end
    up = SIRParticleFilter(m, 10_000)
    sup = StepUpdater(up)

    # sim = HistoryRecorder(max_steps=1000, show_progress=true)
    # hist = simulate(sim, m, planner)
    # gif = makegif(m, hist, show_progress=true, fps=round(Int, 1.0/m.timestep))
    # run(`xdg-open $(gif.filename)`)

    bs = BlinkSimulator(max_fps=1.0/m.timestep, render_kwargs=(maxghosts=100,))
    simulate(bs, m, policy, sup, initialstate_distribution(m))
end

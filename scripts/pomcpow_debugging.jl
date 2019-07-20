using Revise
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

m = LinearQuad()
# p = FunctionPolicy(s-> s.l<m.safelength ? 0.1 : 0.0)
p = FunctionPolicy(s->0.1)
# p = RandomPolicy(m)

solver = POMCPOWSolver(estimate_value=FORollout(p), max_depth=100, tree_queries=1000)
planner = solve(solver, m)
is = QuadSafetyDemo.HorizontalState(-1.0, 0.0, 0.0, 0.0, 0.49)

# @show @benchmark action(planner, initialstate_distribution(m))
# Profile.clear()
# @profile action(planner, initialstate_distribution(m))
# ProfileView.view()

sim = HistoryRecorder(max_steps=10, show_progress=true)
hist = simulate(sim, m, planner)

@time makegif(m, hist, show_progress=true, fps=round(Int, 1.0/m.timestep))
# Profile.clear()
# @profile makegif(m, hist, show_progress=true, fps=round(Int, 1.0/m.timestep))
# ProfileView.view()



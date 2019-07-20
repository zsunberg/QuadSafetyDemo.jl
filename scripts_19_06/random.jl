using POMDPs
using BlinkPOMDPSimulator
using QuadSafetyDemo
using POMDPPolicies
using POMDPSimulators
using POMCPOW
using Distributions

m = LinearQuad()
p = FunctionPolicy(o->0.1)
# p = RandomPolicy(m)

solver = POMCPOWSolver(estimate_value=FORollout(p))
planner = solve(solver, m)
is = QuadSafetyDemo.HorizLen(-1.0, 0.0, 0.0, 0.0, 0.4)

bs = BlinkSimulator(max_fps=1.0/m.timestep)
simulate(bs, m, planner, updater(planner), initialstate_distribution(m), is)

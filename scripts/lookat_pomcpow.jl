using Revise
using POMDPs
using POMDPModelTools
using Distributions
using BlinkPOMDPSimulator
using QuadSafetyDemo
using POMDPPolicies
using POMDPSimulators
using POMCPOW
using D3Trees

dt = 0.2
noise = 0.05
m = LinearQuad(timestep=dt, obsmodel=(a,sp)->Normal(sp.x, noise))
p = FunctionPolicy(s-> s.l<m.safelength ? 0.1 : 0.0)
# p = FunctionPolicy(s->0.1)
# p = RandomPolicy(m)

solver = POMCPOWSolver(estimate_value=FORollout(p),
                       max_depth=100,
                       max_time=dt,
                       criterion=MaxUCB(20000.0),
                       tree_in_info=true,
                       enable_action_pw=false,
                       k_observation=4,
                       alpha_observation=1/30
                      )
planner = solve(solver, m)

a, i = action_info(planner, initialstate_distribution(m))

inchrome(D3Tree(i[:tree]))

# bs = BlinkSimulator(max_fps=1.0/m.timestep, render_kwargs=(maxghosts=100,))
# simulate(bs, m, planner, updater(planner), initialstate_distribution(m))

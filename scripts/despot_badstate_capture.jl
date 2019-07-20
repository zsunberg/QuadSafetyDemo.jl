using Revise
using POMDPs
using BlinkPOMDPSimulator
using QuadSafetyDemo
using POMDPPolicies
using POMDPSimulators
using Distributions
using ARDESPOT
using ParticleFilters
using D3Trees

dt = 0.2
noise = 0.05
sm = LinearQuad(timestep=dt, obsmodel=(a,sp)->DiscretizedObsDist(sp.x, noise, 0.05))
m = LinearQuad(timestep=dt, obsmodel=(a,sp)->Normal(sp.x, noise))
p = FunctionPolicy(b->maximum(s.l for s in particles(b))<m.safelength ? 0.1 : 0.0)

function ub(m, b)
    if minimum(s.l for s in particles(b)) < m.safelength
        # there's a chance!
        return m.goalreward
    else # no chance
        return -m.timestepcost
    end
end

bounds = IndependentBounds(DefaultPolicyLB(p), ub, check_terminal=true)
solver = DESPOTSolver(K=100, T_max=dt, bounds=bounds, tree_in_info=true)
planner = solve(solver, sm)
# is = QuadSafetyDemo.HorizontalState(-1.0, 0.0, 0.0, 0.0, 0.49)

up = SIRParticleFilter(m, 10_000)

# bs = BlinkSimulator(max_fps=1.0/m.timestep, render_kwargs=(maxghosts=100,))
# simulate(bs, m, planner, up, initialstate_distribution(m))

b = nothing
try
    for step in stepthrough(m, planner, up)
        @show step.a
        global b = step.b
    end
finally
    a, i = action_info(planner, b)
    inchrome(D3Tree(i[:tree]))
end

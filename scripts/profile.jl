using Revise
using POMDPs
using QuadSafetyDemo
using Distributions
using BenchmarkTools
using Random
using ProfileView
using Profile
using Debugger

m = LinearQuad()

is = QuadSafetyDemo.HorizontalState(-1.0, 0.0, 0.0, 0.0, 0.4)
rng = MersenneTwister(2)

# @enter generate_s(m, is, -0.01, rng)
@benchmark generate_s($m, $is, -0.01, $rng)

# function drift(m, s, rng)
#     for i in 1:1000000
#         s = generate_s(m, s, -0.01, rng)
#     end
# end
# drift(m, is, rng)
# 
# Profile.clear()
# @profile drift(m, is, rng)
# ProfileView.view()

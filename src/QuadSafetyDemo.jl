module QuadSafetyDemo

using POMDPs
using POMDPModelTools
using StaticArrays
using Parameters
using Distributions
using Random
using Compose
using ParticleFilters
using Mat

export
    LinearQuad,
    HorizontalState

export
    TimeDependentUntilSafe,
    StepUpdater,
    LinearQuadResampler,
    DiscretizedObsDist,
    safe_hack_actions

const g = 9.8

struct HorizontalDynamicState <: FieldVector{4, Float64}
    x::Float64
    xdot::Float64
    eta::Float64
    etadot::Float64
end
StaticArrays.similar_type(::Type{HorizontalDynamicState},::Type{Float64},::Size{(4,)}) = HorizontalDynamicState

struct HorizontalState <: FieldVector{5, Float64}
    x::Float64
    xdot::Float64
    eta::Float64
    etadot::Float64
    l::Float64
end
StaticArrays.similar_type(::Type{HorizontalState},::Type{Float64},::Size{(5,)}) = HorizontalState
HorizontalState(ds::HorizontalDynamicState, l::Float64) = HorizontalState(ds.x, ds.xdot, ds.eta, ds.etadot, l)

@with_kw struct LinearQuad{OM} <: POMDP{HorizontalState, Float64, Float64}
    timestep::Float64       = 0.1
    m1::Float64             = .1
    m2::Float64             = .1
    F::Float64              = (m1+m2)*g
    goalreward::Float64     = 1000.0
    crashcost::Float64      = 100000.0
    maneuvercost::Float64   = 2.0
    timestepcost::Float64   = 1.0
    safelength::Float64     = 0.5
    leftwall::Float64       = -2.0
    obsmodel::OM            = (a,sp)->Normal(sp.x, 0.02)
    nm2g_m1::Float64        = -m2*g/m1
    nm1m2g_m1::Float64      = -(m1+m2)*g/m1
    F_m1::Float64           = F/m1
end

function derivative(m::LinearQuad, l, x::HorizontalDynamicState, a)
    xddot = m.nm2g_m1*x.eta + m.F_m1*a
    etaddot = m.nm1m2g_m1/l*x.eta + m.F_m1/l*a
    return HorizontalDynamicState(x.xdot, xddot, x.etadot, etaddot)
end

POMDPs.generate_s(m::LinearQuad, s, a, rng::AbstractRNG) = dynamics(m, s, a)
    
function dynamics(m::LinearQuad, s, a)
    ## Differential Equation Tries
    
    ### Euler (not accurate enough)
    # xp = s.x + s.xdot*m.timestep
    # xdotp = s.xdot + xddot*m.timestep
    # etap = s.eta + s.etadot*m.timestep
    # etadotp = s.etadot + etaddot*m.timestep
    # return HorizontalState(xp, xdotp, etap, etadotp, s.l)
    
    ### RK4 # mean time: 20.396 ns (0.00% GC)
    x = HorizontalDynamicState(view(s, 1:4))
    k1 = m.timestep*derivative(m, s.l, x, a)
    k2 = m.timestep*derivative(m, s.l, x+k1/2, a)
    k3 = m.timestep*derivative(m, s.l, x+k2/2, a)
    k4 = m.timestep*derivative(m, s.l, x+k3, a)
    xp = x + (k1 + 2*k2 + 2*k3 + k4)/6
    return HorizontalState(xp, s.l)

    ## c2d from ControlSystems.jl # mean time: 14.561 μs (5.45% GC)
    # A = @SMatrix([0. 1. 0. 0.;
    #      0. 0. -m.m2*g/m.m1 0.;
    #      0. 0. 0. 1.;
    #      0. 0. -(m.m1+m.m2)*g/(s.l*m.m1) 0.])
    # B = @SMatrix([0.; m.F/m.m1; 0.; m.F/(s.l*m.m1)])
    # C = @SMatrix([1. 0. 0. 0.])
    # D = @SMatrix([0.])
    # dsys,_ = c2d(ss(A,B,C,D),m.timestep)
    # dynstate = dsys.A*s[1:4] + dsys.B*[a]
    # return HorizontalState(dynstate..., s.l)
    
    # Analytic matrix exponential
    # https://www.wolframalpha.com/input/?i=expm(%5B%5B0,+1,+0,+0%5D,+%5B0,+0,+a,+0%5D,+%5B0,+0,+0,+1%5D,+%5B0,+0,+b%2Fl,+0%5D%5D)
    #
end

POMDPs.observation(m::LinearQuad, a, sp) = m.obsmodel(a,sp)

function POMDPs.reward(m::LinearQuad, s, a, sp)
    r = 0.0
    x2p = sp.x - sp.l*sin(sp.eta)
    if x2p >= 0.0
        if sp.l < m.safelength
            r += m.goalreward
        else
            r -= m.crashcost
        end
    elseif sp.x <= m.leftwall || x2p <= m.leftwall
        return r -= m.crashcost
    end
    if a != 0.0
        r -= m.maneuvercost
    end
    r -= m.timestepcost
    return r
end

function iscrash(m::LinearQuad, s)
    x2 = s.x - s.l*sin(s.eta)
    return (s.l >= m.safelength && x2 >= 0.0) || x2 <= m.leftwall || s.x <= m.leftwall
end

function POMDPs.isterminal(m::LinearQuad, s)
    return iscrash(m, s) || s.x - s.l*sin(s.eta) >= 0.0
end

@with_kw struct QuadInitialDist
    x::Float64      = -1.0
    ldist::Distributions.Uniform  = Distributions.Uniform(0.1, 1.0)
end

Base.rand(rng::AbstractRNG, d::QuadInitialDist) = HorizontalState(d.x, 0.0, 0.0, 0.0, rand(rng, d.ldist))

POMDPs.initialstate_distribution(m::LinearQuad) = QuadInitialDist()
POMDPs.actions(m::LinearQuad) = (-0.05,0.0,0.05)
# POMDPs.actions(m::LinearQuad) = (-0.05,0.05)
POMDPs.discount(m::LinearQuad) = 0.95

include("visualization.jl")
include("heuristics.jl")
include("filters.jl")
include("obsmodels.jl")
include("safety_hack.jl")

end # module

struct TimeDependentUntilSafe{F<:Function} <: Policy
    f::F
    m::LinearQuad
end

function POMDPs.action(p::TimeDependentUntilSafe, b::Pair) 
    if any(w > 0.0 && s.l > p.m.safelength for (s,w) in weighted_iterator(last(b)))
        return p.f(last(b), p.m.timestep*first(b))
    else
        return maximum(actions(p.m))
    end
end

# returns a pair of timestep=>b
struct StepUpdater{U} <: Updater
    up::U
end

POMDPs.update(u::StepUpdater, b, a, o) = first(b)+1 => update(u.up, last(b), a, o)

POMDPs.initialize_belief(u::StepUpdater, b) = 0 => initialize_belief(u.up, b)
POMDPs.initialize_belief(u::StepUpdater, b::Pair{Int}) = b

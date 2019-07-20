function safe_hack_actions(m::LinearQuad, b::AbstractParticleBelief)
    acts = actions(m)
    okacts = actiontype(m)[]
    mn = mean(particles(b))
    x1 = mn.x
    x2 = mn.x - mn.l*sin(mn.eta)
    xm = (x1*m.m1 + x2*m.m2)/(m.m1+m.m2)
    if xm > m.leftwall/2 # rightwall is closer
        baddir = 1.0
        best = maximum(acts)
    else
        baddir = -1.0
        best = minimum(acts)
    end
    for a in acts
        ok = true
        for s in particles(b)
            while s.xdot*baddir > 0.0 && (s.xdot-s.l*cos(s.eta)*s.etadot)*baddir > 0.0
                if iscrash(m, s)
                    ok = false    
                    break
                end
                s = dynamics(m, s, best)
            end
            if !ok
                break
            end
        end
        if ok
            push!(okacts, a)
        end
    end
    @assert !isempty(okacts)
    return okacts
end

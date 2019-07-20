struct LinearQuadResampler
    n::Int
    eps::Float64
end

function Base.clamp(s::HorizontalState, m::LinearQuad, eps)
    x1 = clamp(s.x, m.leftwall+eps, 0.0-eps)
    x2 = clamp(x1+s.l*sin(s.eta), m.leftwall+eps, 0.0-eps)
    eta = asin((x2-x1)/s.l)
    return HorizontalState(x1, s.xdot, eta, s.etadot, s.l)
end

function ParticleFilters.resample(r::LinearQuadResampler,
                                  bp::WeightedParticleBelief,
                                  pm::LinearQuad,
                                  rm::LinearQuad,
                                  b,
                                  a,
                                  o,
                                  rng)

    new = resample(LowVarianceResampler(r.n), bp, rng)
    if all(isterminal(pm, s) for s in particles(new))
        fixed = ParticleCollection(collect(clamp(s, pm, r.eps) for s in particles(new)))
        return fixed
    end
    return new
end

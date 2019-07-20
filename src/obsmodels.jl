struct DiscretizedObsDist
    x::Float64
    noise::Float64
    delta::Float64
end

function Base.rand(rng::AbstractRNG, d::DiscretizedObsDist)
    y = d.noise*randn(rng) + d.x
    return round(y/d.delta)*d.delta
end

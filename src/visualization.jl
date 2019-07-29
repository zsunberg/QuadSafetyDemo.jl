function POMDPModelTools.render(m::LinearQuad, step; maxghosts=typemax(Int))
    s = step.s
    z = 1.5
    theta = get(step, :a, 0.0)

    if haskey(step, :b)
        if step.b isa Pair{Int}
            b = last(step.b)
        else
            b = step.b
        end
        bnt = [(x=s.x, z=z, eta=s.eta, l=s.l, opacity=max(p,0.05)) for (s, p) in weighted_iterator(b)]
        ghosts = underslungs(bnt[1:min(end,maxghosts)])
    else
        ghosts = nothing
    end

    if haskey(step, :t)
        txt = compose(context(), text(0.02,0.05,"step=$(step.t)"), stroke("black"))
    else
        txt = nothing
    end

    scale = 0.3
    compose(context(),
            rectangle(), fill("sky blue"),
            txt,

            (context(0.8, 1.0, scale*w, -scale*h),

             quad(s.x, z, theta, color="green"),
             underslung(s.x, z, s.eta, s.l, color="green"),

             ghosts,

             (context(), line([(0,1.6),(0,1/scale)]),
                         line([(0,0),(0,1.5-m.safelength-0.1)]),
                         line([(m.leftwall,0), (m.leftwall,1/scale)]),
                         linewidth(4mm), stroke("red"))
            )
           )
end

function quad(x, z, theta; color="black", opacity=1.0)
    compose(context(x, z, rotation=Rotation(theta, 0, 0)),
            (context(), line([(-0.1, 0), (0.1, 0)]), stroke(color), linewidth(2mm), strokeopacity(opacity)),
           )
end

function underslungs(namedtuples; color="gray1") # each NamedTuple must contain x, z, eta, l, opacity
    lines = collect([(t.x,t.z), (t.x-(t.l-0.03)*sin(t.eta),t.z-(t.l-0.03)*cos(t.eta))] for t in namedtuples)
    ops = collect(t.opacity for t in namedtuples)
    xs = collect(t.x-t.l*sin(t.eta) for t in namedtuples)
    zs = collect(t.z-t.l*cos(t.eta) for t in namedtuples)
    compose(context(),
            line(lines),
            stroke(color),
            strokeopacity(ops),
            circle(xs, zs, fill(0.03, length(namedtuples))),
            fill(color),
            fillopacity(ops)
           )
end

function underslung(x, z, eta, l; color="gray1", opacity=1.0)
    compose(context(x, z, rotation=Rotation(eta, 0, 0)),
            (context(), line([(0,0), (0,-(l-0.03))]), stroke(color), linewidth(1mm), strokeopacity(opacity)),
            (context(), circle(0,-l,0.03), fill(color), fillopacity(opacity))
           )
end

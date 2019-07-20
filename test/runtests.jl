using Test
using QuadSafetyDemo
import QuadSafetyDemo
using Random
using POMDPs
using Compose
using POMDPModelTools

m = LinearQuad()
@show s = initialstate(m, MersenneTwister(0))

rng = MersenneTwister(4)
b0 = SparseCat([initialstate(m, rng) for i in 1:1000], fill(0.1, 1000))

svgname = tempname()*".svg"
render(m, (s=s, a=0.1, b=b0)) |> SVG(svgname)
run(`xdg-open $svgname`)

# pngname = tempname()*".png"
# render(m, (s=s, a=0.1, b=b0)) |> PNG(pngname)
# run(`xdg-open $pngname`)

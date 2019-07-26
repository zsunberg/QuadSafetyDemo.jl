g = 9.8
m1 = 0.1
m2 = 0.1
l = 1.0
F = g*(m1+m2)

A = [0 1 0                 0;
     0 0 -m2*g/m1          0;
     0 0 0                 1;
     0 0 -(m1+m2)*g/(l*m1) 0]

C = [1 0 0 0]

obsmat = [C; C*A; C*A*A; C*A*A*A]
@show rank(obsmat)

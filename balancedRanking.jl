using JuMP
using Plots
using Gurobi

lpRatio = Model(with_optimizer(Gurobi.Optimizer, Presolve=2, Threads=4))

n = 1000
eps = 1//n

@variable(lpRatio, ratio >= 0)
@objective(lpRatio, Max, ratio)

@variable(lpRatio, h[0:eps:1+eps] >= 0)
@variable(lpRatio, H[0:eps:1] >= 0)

@constraint(lpRatio, h[0] == 0)
@constraint(lpRatio, h[1] == 1)
@constraint(lpRatio, h[1+eps] == 1)

for y=eps:eps:1
    @constraint(lpRatio, h[y-eps] <= h[y])
    @constraint(lpRatio, h[y-eps]+2*eps >= h[y])
end

@constraint(lpRatio, H[0] == 0)

for y=eps:eps:1
    @constraint(lpRatio, H[y] == eps *
                sum(0.5*h[x-eps]+0.5*h[x] for x=eps:eps:y))
end

for i = 0:eps:1
    @constraint(lpRatio, ratio + 4*eps*eps <= i*h[i] - H[i] + 1-i )
end

for i=0:eps:1
    for j=0:eps:1
        @constraint(lpRatio, ratio + 8*eps*eps <= i*h[i] - H[i] + j*h[j] - H[j]
                                    + H[1-i] + (1-h[i])*(1-j) )
    end
end

status = optimize!(lpRatio)

println("Objective value: ", getobjectivevalue(lpRatio))

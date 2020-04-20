using JuMP
using Plots
using Gurobi

function lpEagerWaterFilling(n)
    # set solver to Gurobi
    lpRatio = Model(with_optimizer(Gurobi.Optimizer))

    # set step size
    step = 1//n

    # initial variables
    @variable(lpRatio, ratio >= 0)
    @objective(lpRatio, Max, ratio)
    @variable(lpRatio, h[0:step:1+step] >= 0)
    @variable(lpRatio, H[0:step:1] >= 0)

    # set bondary constraints
    @constraint(lpRatio, h[0] == 0)
    @constraint(lpRatio, h[1] == 1)
    @constraint(lpRatio, h[1+step] == 1)

    for y=step:step:1
        @constraint(lpRatio, h[y-step] <= h[y])             # h monotone
        @constraint(lpRatio, h[y-step]+2*step >= h[y])      # h Lipschitzness
    end

    @constraint(lpRatio, H[0] == 0)

    # set H to be the sum of h
    for y=step:step:1
        @constraint(lpRatio, H[y] == step *
                    sum(0.5*h[x-step]+0.5*h[x] for x=step:step:y))
    end

    for i = 0:step:1
        @constraint(lpRatio, ratio + 4*step*step <= i*h[i] - H[i] + 1-i )
    end

    for i=0:step:1
        for j=0:step:1
            @constraint(lpRatio, ratio + 8*step*step <= i*h[i] - H[i] + j*h[j] - H[j]
                                        + H[1-i] + (1-h[i])*(1-j) )
        end
    end

    status = optimize!(lpRatio)

    println("Objective value: ", getobjectivevalue(lpRatio))
end

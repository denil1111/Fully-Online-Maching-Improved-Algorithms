using JuMP
using Gurobi

function lpEagerWaterFilling(n)
    # set Gurobi to be the solver
    lpRatio = Model(Gurobi.Optimizer)

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

    for q = 0:step:1
        @constraint(lpRatio, ratio + 3/4*step*step <= q*h[q] - H[q] + 1-q )
    end

    for p=0:step:1
        for q=0:step:1
            @constraint(lpRatio, ratio + 8*step*step <= q*h[q] - H[q] + p*h[p] - H[p]
                                        + H[1-q] + (1-h[q])*(1-p) )
        end
    end

    status = optimize!(lpRatio)

    println("Objective value: ", objective_value(lpRatio))
end

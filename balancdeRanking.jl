using JuMP
using Gurobi
using Plots
function lpBalancedRanking(n)
    # Set Gurobi to be the solver
    lpRatio = Model(with_optimizer(Gurobi.Optimizer))

    # set step size
    step = 1//n

    #initial variables
    @variable(lpRatio, ratio >= 0)
    @objective(lpRatio, Max, ratio)
    @variable(lpRatio, g[0:step:1] >= 0)
    @variable(lpRatio, f[0:step:1] >= 0)
    @variable(lpRatio, l[0:step:1] >= 0)
    @variable(lpRatio, min[0:step:1, 0:step:1] >= 0)

    @constraints(lpRatio,
    begin
        [y = 0:step:1-step] , g[y] <= g[y+step]                                         # g monotone
        [y = 0:step:1-step] , f[y] <= f[y+step]                                         # f monotone
        [y = 0:step:1-step] , g[y] + step >= g[y+step]                                  # g Lipschitzness
        [y = 0:step:1-step] , g[y] + 0.01 * step <= g[y+step]                           # g Reverse Lipschitzness
        [y = 0:step:1-step] , f[y] + step >= f[y+step]                                  # f Lipschitzness
        [yu = 0:step:1 , theta=step:step:1], min[yu, theta] <= 1-g[theta]               # min[yu,theta] = min(g(yu), 1 - g(theta))
        [yu = 0:step:1 , theta=step:step:1], min[yu, theta] <= g[yu]                    # min[yu,theta] = min(g(yu), 1 - g(theta))
        [y = 0:step:1-2*step] , l[y] + l[y+2*step] >= 2 * l[y+step]                     # l convex
        g[1] + f[1] <= 1                                                                # dual varialbe non-negative
        g[0] >= 0                                                                       # dual varialbe non-negative
        f[0] >= 0                                                                       # dual varialbe non-negative
        [tau = 0:step:1 , gamma = step:step:1-step , theta = gamma-step:step:1-step],
        l[tau] <=   (sum(step/2 * (g[yu] + g[yu + step]) for yu = 0:step:tau-step)      # stengthened constraints (l bound, regular)
                    +  sum(step/2 * (g[yv] + g[yv + step]) for yv = 0:step:gamma-step)
                    + (1-tau) * (1 - gamma - (1-theta) * g[theta])
                    +  sum(gamma * step/2 * (min[yu,theta+step] + min[yu+step,theta+step]) for yu=tau:step:1-step)
                    - step*step/2      #error bound
        )
        [tau = 0:step:1 , gamma = 0:0 , theta = 0:step:1-step],
        l[tau] <=   (sum(step/2 * (g[yu] + g[yu + step]) for yu = 0:step:tau-step)      # stengthened constraints (l bound, regular, gamma = 0)
                    +  sum(step/2 * (g[yv] + g[yv + step]) for yv = 0:step:gamma-step)
                    + (1-tau) * (1 - gamma - (1-theta) * g[theta])
                    +  sum(gamma * step/2 * (min[yu,theta+step] + min[yu+step,theta+step]) for yu=tau:step:1-step)
                    - step*step/2      #error bound
        )
        [tau = 0:step:1 , gamma = 0:step:1],
        l[tau] <=   (sum(step/2 * (g[yu] + g[yu + step]) for yu = step:step:tau-step)   # stengthened constraints (l bound, theta = 1)
                    +  sum(step/2 * (g[yv] + g[yv + step]) for yv = step:step:gamma-step)
                    + (1-tau) * (1- gamma)
                    - step*step/4       #error bound
        )
        [tau = 0:step:1, pv =0:step:1],
        ratio <= (l[tau]                                                                # stengthened constraints (r bound)
                + step * sum((f[yu-step]/2 + f[yu]/2) for yu = step:step:tau)
                + step * sum((f[yv-step]/2 + f[yv]/2) for yv = step:step:pv)
                - (1-tau) * (f[pv])
                - step*step/4            #error bound
        )
    end
    )
    status = optimize!(lpRatio)
    println("Objective value: ", objective_value(lpRatio))
    return objective_value(lpRatio)
end

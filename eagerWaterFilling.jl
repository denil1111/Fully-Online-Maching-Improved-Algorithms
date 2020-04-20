using Gurobi
using Plots
function lp(n)
    GRB_ENV = Gurobi.Env()
    lpRatio = Model(with_optimizer(Gurobi.Optimizer,GRB_ENV, Threads=8))
    step = 1//n
    @variable(lpRatio, ratio >= 0)
    @objective(lpRatio, Max, ratio)
    @variable(lpRatio, g[0:step:1] >= 0)
    @variable(lpRatio, h[0:step:1] >= 0)
    @variable(lpRatio, m[0:step:1] >= 0)
    @variable(lpRatio, l[0:step:1, 0:step:1] >= 0)
    @constraints(lpRatio,
    begin
        [y = 0:step:1-step] , g[y] <= g[y+step]         #g monotone
        [y = 0:step:1-step] , h[y] <= h[y+step]         #h monotone
        [y = 0:step:1-step] , g[y] + step >= g[y+step]          #g Lipschitzness
        [y = 0:step:1-step] , g[y] + 0.01 * step <= g[y+step]          #g Reverse Lipschitzness
        [y = 0:step:1-step] , h[y] + step >= h[y+step]          #h Lipschitzness
        [yu = 0:step:1 , theta=step:step:1], l[yu, theta] <= 1-g[theta]     #l[yu,theta] = min(g(yu), 1 - g(theta))
        [yu = 0:step:1 , theta=step:step:1], l[yu, theta] <= g[yu]          #l[yu,theta] = min(g(yu), 1 - g(theta))
        [y = 0:step:1-2*step] , m[y] + m[y+2*step] >= 2 * m[y+step]         #m convex
        g[1] + h[1] <= 1           # dual varialbe non-negative
        [tau = 0:step:1 , gamma = step:step:1-step , theta = gamma-step:step:1-step],
        m[tau] <=   (sum(step/2 * (g[yu] + g[yu + step]) for yu = 0:step:tau-step)
                    +  sum(step/2 * (g[yv] + g[yv + step]) for yv = 0:step:gamma-step)
                    + (1-tau) * (1 - gamma - (1-theta) * g[theta])
                    +  sum(gamma * step/2 * (l[yu,theta+step] + l[yu+step,theta+step]) for yu=tau:step:1-step)
                    - step*step/2      #error bound
        )
        [tau = 0:step:1 , gamma = 0:0 , theta = 0:step:1-step],
        m[tau] <=   (sum(step/2 * (g[yu] + g[yu + step]) for yu = 0:step:tau-step)
                    +  sum(step/2 * (g[yv] + g[yv + step]) for yv = 0:step:gamma-step)
                    + (1-tau) * (1 - gamma - (1-theta) * g[theta])
                    +  sum(gamma * step/2 * (l[yu,theta+step] + l[yu+step,theta+step]) for yu=tau:step:1-step)
                    - step*step/2      #error bound
        )
        [tau = 0:step:1 , gamma = 0:step:1],
        m[tau] <=   (sum(step/2 * (g[yu] + g[yu + step]) for yu = step:step:tau-step)
                    +  sum(step/2 * (g[yv] + g[yv + step]) for yv = step:step:gamma-step)
                    + (1-tau) * (1- gamma)
                    - step*step/4       #error bound
        )
        [tau = 0:step:1, pv =0:step:1],
        ratio <= (m[tau]
                + step * sum((h[yu-step]/2 + h[yu]/2) for yu = step:step:tau)
                + step * sum((h[yv-step]/2 + h[yv]/2) for yv = step:step:pv)
                - (1-tau) * (h[pv])
                - step*step/4            #error bound
        )
    end
    )
    println("solving...")
    status = optimize!(lpRatio)
    println("Objective value: ", objective_value(lpRatio))
end

# run LP(n) to optimize a size n lp

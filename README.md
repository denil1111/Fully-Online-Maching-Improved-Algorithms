# Fully-Online-Maching-Improved-Algorithms
We support functions to solve the LPs which optimzie the competitive ratio of balanced ranking and eager water-filling written in Julia.
- balancedRanking.jl
- eagerWaterFilling.jl
## balancedRanking.jl
The script provides a function to optimize the competitive ratio of balanced ranking with a size n LP. This is an example to load the script and run it with n = 100.
```
include("balancedRanking.jl")
lpBalancedRanking(100)
```
## eagerWaterFilling.jl
The script provides a function to optimize the competitive ratio of eager water-filling with a size n LP. This is an example to load the script and run it with n = 1000.
``` 
include("eagerWaterFilling.jl")
lpEagerWaterFilling(1000)
```


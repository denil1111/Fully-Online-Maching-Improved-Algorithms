# Fully-Online-Maching-Improved-Algorithms
We provide the two function to optimzie the competitive ratio for balanced ranking and eager water-filling written in Julia.
- balancedRanking.jl
- eagerWaterFilling.jl
## API
### lpBalancedRanking in balancedRanking.jl
```
include("balancedRanking.jl")
lpBalancedRanking( n = 20 )
```
Output the optimized ratio for balnced ranking with n=20.
### lpEagerWaterFilling in eagerWaterFilling.jl
``` 
include("eagerWaterFilling.jl")
lpEagerWaterFilling( n = 20 )
```
Output the optimized ratio for eager water filling with n=20.

# rich1d
A numerical model that solves 1D Richards equation for simulating variably-saturated groundwater flow. 


## Method
The rich1d is written based on the predictor-corrector (PC) scheme proposed by <Lai and Ogden (2015)>, with novel modifications implemented to redistribute moisture after the corrector step. The moisture redistribution helps the model to achieve strict mass conservation (the Lai's method also includes a redistribution step, but we find their approach is not strictly conservative). 

Three adaptive time control strategies are available in rich1d to efficiently adjust dt. They are (1) adjusting dt based on the evolution of water content, (2) adjusting dt based on the truncation error of the time derivative <Kavetski etal (2002)>, and (3) adjusting dt based on both evolution of water content and the Courant number. The third approach is proposed by the author to better link the required dt to the soil properties. 

## Some references
Li, Z., Ozgen-Xian, I., Maina, F., 20XX. A mass-conservative predictor-corrector solution to the 1D Richards equation with adaptive time control. under review

Lai, W., Ogden, F., 2015. A mass-conservative finite volume predictor-corrector solution of the 1D Richards’ equation. Journal of Hydrology 523, 119–127. doi:10.1016/j.jhydrol.2015.01.053.

Kavetski, D., Binning, P., Sloan, S., 2002. Noniterative time stepping schemes with adaptive truncation error control for the solution of richards equation. Water Resources Research 38, 1211. doi:10.1029/2001WR000720.


## Zipkin_et_al_Ecology&Evolution_2014
*Zipkin E.F., Sillett T.S., Grant E.H.C., Chandler R.B., and Royle J.A. 2014. Inferences from count data using multi-state population models: a comparison to capture-recapture approaches. Ecology and Evolution. 4: 417-426.*

These data and scripts are associated with Zipkin et al. 2014 Ecology and Evolution. The warbler model is a 2-stage (yearling and adult), 2 sex model. The count data are summarized from capture-recapure data at Hubard Brook from 1998-2010 by Scott sillett.

**Data:**

female.csv - Female warbler counts (yearling, older, unknow) from 1996-2010, with an annual sampling events in up to three elevations
male.csv - Male warbler counts (yearling, older, unknow) from 1996-2010, with an annual sampling events in up to three elevations

**Code:**

Wrapper_warbler.R - Start with this file. The code loads and formats warbler count data and then fits a structured Dail-Madsen model using the associated JAGS code "warbler.R". The code produces a summary of the parameter estimates for the model and model diagnostics (e.g., traceplots and R-hat statisic).

Summarize and plot results.R - Examines results from the model and creates a plot of the posterior distribution of parameter estimates similar to the one in Figure 3.

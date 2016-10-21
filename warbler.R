#This is the JAGS code file to run the structured Dail-Madsen model
#in Zipkin et al. 2014 Ecology and Evolution.  See "Wrapper warbler.R" for 
#more information and instructions on how to run the code.

model {
  # priors
  
  ## 1=M,yearling; 2=f,yearling; 3=m,adult; 4=f,adult
  lambda[1] ~ dunif(0, 30)
  lambda[2] ~ dunif(0, 30)
  lambda[3] ~ dunif(0, 30)
  lambda[4] ~ dunif(0, 30) 
  
  gamma[1] ~ dunif(0, 30)
  gamma[2] ~ dunif(0, 30)

  
  omega[1] ~ dunif(0, 1)
  omega[2] ~ dunif(0, 1)
  omega[3] ~ dunif(0, 1)
  omega[4] ~ dunif(0, 1)
  
  K ~ dunif(0,150)
  
  #Put strong priors on detection
 # Q1.b <-
  #Q1.a <- (0.926*Q1.b)/(1-.926)
  
  Q[1] ~ dnorm(0.926, 1/(0.034^2))I(0,1)
  Q[2] ~ dnorm(0.869, 1/(0.061^2))I(0,1)
  
  #Detection rate for unspecified
  C[1] ~ dunif(0,1)
  C[2] ~ dunif(0,1)
  
  # loop across sites
  for(i in 1:nSites) {
    # Year 1 - poisson with parameter lambda
    N[i,1,1] ~ dpois(lambda[1])
    N[i,1,2] ~ dpois(lambda[2])
    N[i,1,3] ~ dpois(lambda[3])
    N[i,1,4] ~ dpois(lambda[4])
    
    #Detection model
    #Detection probability for each stage
    y[i,1,1] ~ dbin(Q[1]*C[1], N[i,1,1])
    y[i,1,2] ~ dbin(Q[2]*C[2], N[i,1,2])   
    y[i,1,3] ~ dbin(Q[1]*C[1], N[i,1,3])   
    y[i,1,4] ~ dbin(Q[2]*C[2], N[i,1,4]) 
    y[i,1,5] ~ dbin(Q[1]*(1-C[1]), (N[i,1,1]+N[i,1,3]))   
    y[i,1,6] ~ dbin(Q[2]*(1-C[2]), (N[i,1,2]+N[i,1,4])) 
    
    
    
    # Year 2+
    for(t in 2:nYears) {
      #Estimate survivorship
      #Possibly combine the ages and estimate sex only
      S[i,t-1,1] ~ dbin(omega[1], N[i,t-1,1]) #rate age 1 males
      S[i,t-1,2] ~ dbin(omega[2], N[i,t-1,2]) #rate age 1 females
      S[i,t-1,3] ~ dbin(omega[3], N[i,t-1,3]) #male adults
      S[i,t-1,4] ~ dbin(omega[4], N[i,t-1,4]) #female adults
      
      #Estimate recruitment (gamma1) and movement (gamma2 and gamma3)
      NN[i,t-1]<-N[i,t-1,3]+N[i,t-1,4]+N[i,t-1,3]+N[i,t-1,4]
      G[i,t-1,1] ~ dpois( (gamma[1]*(exp(1-NN[i,t-1]/K))*NN[i,t-1]) )
      G[i,t-1,2] ~ dpois( (gamma[1]*(exp(1-NN[i,t-1]/K))*NN[i,t-1]) )
      G[i,t-1,3] ~ dpois( (gamma[2]*(exp(1-NN[i,t-1]/K))*NN[i,t-1]) ) #number new adult males 
      G[i,t-1,4] ~ dpois( (gamma[2]*(exp(1-NN[i,t-1]/K))*NN[i,t-1]) ) #number new adult females
      
      #Sum all stages to get total N at each site i in each year t
      N[i,t,1] <- G[i,t-1,1]
      N[i,t,2] <- G[i,t-1,2]
      N[i,t,3] <- S[i,t-1,1] + S[i,t-1,3] + G[i,t-1,3]
      N[i,t,4] <- S[i,t-1,2] + S[i,t-1,4] + G[i,t-1,4]
      
      #loop accross reps to estimate detection prob
      y[i,t,1] ~ dbin(Q[1]*C[1], N[i,t,1])
      y[i,t,2] ~ dbin(Q[2]*C[2], N[i,t,2])   
      y[i,t,3] ~ dbin(Q[1]*C[1], N[i,t,3])   
      y[i,t,4] ~ dbin(Q[2]*C[2], N[i,t,4]) 
      y[i,t,5] ~ dbin(Q[1]*(1-C[1]), (N[i,t,1]+N[i,t,3]))   
      y[i,t,6] ~ dbin(Q[2]*(1-C[2]), (N[i,t,2]+N[i,t,4])) 
    }
  }
  
  #sum up the number of individuals in all sights to estimate annual
  #total N
  for (t in 1:nYears){
    Ntotal[1,t] <- sum(N[,t,1])
    Ntotal[2,t] <- sum(N[,t,2])
    Ntotal[3,t] <- sum(N[,t,3])
    Ntotal[4,t] <- sum(N[,t,4])
    Nall[t] <- sum(Ntotal[,t])
  }
  
  for (t in 1:nYears){
    Ntt[1,t] <- sum(N[1,t,])
    Ntt[2,t] <- sum(N[2,t,])
    Ntt[3,t] <- sum(N[3,t,])
    
  }
}
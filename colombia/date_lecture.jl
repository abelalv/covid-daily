
using CSV
using DataFrames
using Dates
using Plots
using DifferentialEquations
using NeuralPDE, Lux, Plots, OrdinaryDiffEq, Distributions, Random
# Specify the file path

#file_path = "/home/user/Documents/Github/covid-daily/colombia/coronavirus-cases-linear.csv"

file_path = "/home/abel/Documents/repos_git/covid-daily/colombia/coronavirus-cases-linear.csv"

# Read the file
data = CSV.read(file_path, DataFrame)
data = data[21:end, :]

# Plot the total cases infected
data[:, 1] = DateTime.(data[:, 1])
scatter(data.Date, data[:, 2])

# Create a new column with the difference of the second column
data.diff_cases = [missing; diff(data[:, 2])]

# Replace missing values with 0
data.diff_cases[ismissing.(data.diff_cases)] .= 0

# Plot the difference in cases
scatter(data.Date, data.diff_cases)



#Solution of the SIR model from ODEs

function sir_model(u, p, t)
    S, I, R = u
    β, γ = p
    N = S + I + R
    dx = -β * S * I / N
    dy = β * S * I / N - γ * I
    dz = γ * I
    return [dx, dy, dz]
end




N=5e7
I0=1
R0=0
β=1.3
γ=0.1
# Set initial conditions and parameters
u0= [N - I0, I0, R0]
p = [β, γ]

# Set up the time span
tspan = (0.0, 60.0)

# Solve the ODE g

prob = ODEProblem(sir_model, u0, tspan, p)
# Plot the results

dt = 0.01
solution = solve(prob, Tsit5(); saveat = dt)

plot(solution, title = "SIR Model", xlabel = "Time", ylabel = "Population", label = ["Susceptible" "Infected" "Recovered"])

value_noise=0.02
time = solution.t
u = hcat(solution.u...)
x = u[1, :] + (u[1, :]) .* (value_noise.* randn(length(u[1, :])))
y = u[2, :] + (u[2, :]) .* (value_noise .* randn(length(u[2, :])))
z = u[3, :] + (u[3, :]) .* (value_noise .* randn(length(u[3, :])))
dataset = [x, y,z, time]

# Plotting the data which will be used
plot(time, x, label = "noisy x")
plot!(time, y, label = "noisy y")
plot!(time, z, label = "noisy z")
plot!(solution, labels = ["x" "y" "z"])


## Neural 


# Neural Networks must have 2 outputs as u -> [dx,dy] in function lotka_volterra()
chain = Lux.Chain(Lux.Dense(1, 6, tanh), Lux.Dense(6, 6, tanh),
    Lux.Dense(6, 3))


alg = BNNODE(chain;
    dataset = dataset,
    draw_samples = 1000,
    l2std = [0.1, 0.1,0.1],
    phystd = [0.1, 0.1,0.1],
    priorsNNw = (0.0, 3.0),
    param = [
        Normal(1, 2),
        Normal(2, 2),
        Normal(2, 2),
        Normal(0, 2)], progress = false)

sol_pestim = solve(prob, alg; saveat = dt)



## 
'
Here we need o defien the data set, because the data set in the original problem is 
defined to all dates, and we problem we have only date of one varible.
'





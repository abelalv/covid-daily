
using CSV
using DataFrames
using Dates
using Plots
using DifferentialEquations
# Specify the file path
file_path = "/home/user/Documents/Github/covid-daily/colombia/coronavirus-cases-linear.csv"

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
    du[1] = -β * S * I / N
    du[2] = β * S * I / N - γ * I
    du[3] = γ * I
    return du
end


# Define the SIR model
function sir_model!(du, u, p, t)
    S, I, R = u
    β, γ = p
    N = S + I + R
    du[1] = -β * S * I / N
    du[2] = β * S * I / N - γ * I
    du[3] = γ * I
end
N=5e7
I0=1
R0=0
# Set initial conditions and parameters
initial_conditions = [N - I0, I0, R0]
parameters = [β, γ]

# Set up the time span
tspan = (start_date, end_date)

# Solve the ODE
solution = solve(sir_model!, initial_conditions, tspan, parameters)

# Plot the results
plot(solution, xlabel="Date", ylabel="Population", label=["Susceptible" "Infected" "Recovered"])


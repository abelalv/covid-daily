
using CSV
using DataFrames
using Dates
using Plots

# Specify the file path
file_path = "/home/abel/Documents/repos_git/covid-daily/data/colombia/coronavirus-cases-linear.csv"

# Read the file
data = CSV.read(file_path,DataFrame)
data=data[21:end,:]

# Plot the total cases infeted 


data[:,1]=DateTime.(data[:,1])
scatter(data.Date,data[:,2])

data
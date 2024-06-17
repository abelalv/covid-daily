
#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import odeint

# Specify the file path
file_path = 'coronavirus-cases-linear.csv'

# Read the CSV file into a dataframe
df = pd.read_csv(file_path)

# Now you can use the dataframe 'df' to work with the data

df.head()
df = df.iloc[20:]

df.head()
# Rename the column
df.rename(columns={'Total Coronavirus Cases': 'total_cases'}, inplace=True)
df.head()

# Plot the timeline
df['Date'] = pd.to_datetime(df['Date'])  # Convert the 'Date' column to datetime
df.plot(x='Date', y='total_cases', title='Confirmed cases over time')

# Show the dataframe
df.head(30)
plt.show()

# Calculate the number of new cases
new_cases = df['total_cases'].diff()
df['new_cases'] = new_cases
# Replace NaN values with 0
df.fillna(0, inplace=True)

df.head()
df.plot(x='Date', y='new_cases', title='new_cases')
plt.show()
population = 5e7
df['susceptible'] = population - df['total_cases']
df.head()



# Define the function that represents the system of differential equations
def sir_model(y, t, transmission_rate, recovery_rate):
    susceptible, infected, recovered = y
    dSdt = -transmission_rate * susceptible * infected / population
    dIdt = transmission_rate * susceptible * infected / population - recovery_rate * infected
    dRdt = recovery_rate * infected
    return [dSdt, dIdt, dRdt]

# Set the initial conditions
initial_conditions = [population - df['total_cases'].iloc[1], df['total_cases'].iloc[1], 0]

# Set the time points to simulate
t = np.arange(len(df) - 20)

# Set the parameters for the model
transmission_rate = 1.2
recovery_rate = 0.1

# Solve the system of differential equations
solution = odeint(sir_model, initial_conditions, t, args=(transmission_rate, recovery_rate))

# Extract the simulated values
susceptible_simulated = solution[:, 0]
infected_simulated = solution[:, 1]
recovered_simulated = solution[:, 2]

# Add the simulated values to the dataframe
df['susceptible_simulated'] = susceptible_simulated
df['infected_simulated'] = infected_simulated
df['recovered_simulated'] = recovered_simulated

# Plot the simulated results
plt.plot(df['Date'], df['susceptible_simulated'], label='Susceptible')
plt.plot(df['Date'], df['infected_simulated'], label='Infected')
plt.plot(df['Date'], df['recovered_simulated'], label='Recovered')
plt.xlabel('Date')
plt.ylabel('Population')
plt.title('SIR Model Simulation')
plt.legend()
plt.show()

aqui
##
# %%

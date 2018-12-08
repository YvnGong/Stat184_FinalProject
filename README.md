# Stat184_FinalProject
Stat184 final project Repo with dataset donations

# Dataset 
Dataset is publicly avaiable in Kaggle
## Data Science for Good: DonorsChoose.org
https://www.kaggle.com/donorschoose/io

It includes six seperate csv tables with approximate size 4.2GB in total

# Purpose
For this project, I mainly focus on digging the donation data that are relevant in organization of schools.
with include three tables: Projects.csv, Resources.csv, Schools.csv that required to be merged togther.


# Working directionary
Dataset is stored in folder dataset relatively

# New Variable
1. formatted and used date-time columns : project posted date and project fully funded date, to calculate the time in unit of days that each project spent.
2. Calculate the total count of projects each school has.
3. Calculate the total cost of projects each school spent.
4. Calculate the average unit price of all projects each school spent.
5. Calculate the average quantity of units all projects each school used.
6. Calculate the average fully funded time of all projects each school spent.
7. Calculate the average cost of each project each school spent.

# New Table 
Merge all new variables along with information of each school into a new tidy table, School_Donation_Stat.csv.

# Plots
1. plot the relation between school project count and school project total cost.
2. plot the relation between school project average cost and project average unit price for each school.
3. plot the relation between school project total cost and average quantity of units for each school.

# Functions
Code is organized into a series of functions with flagged arguments passed in.
Main function runs all of them.

# Message
There is message of each function that reports back to the user to show the function is working fine.

# Output
Output which includes the school_donation_Stat.csv file and three plots are stored in folder 'output'.

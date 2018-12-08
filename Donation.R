library(data.table)
library(reshape2)
library(ggplot2)
library(geosphere)
library(lubridate)

setwd("~/Desktop/R_184/FinalProject/dataset")

#function to calculate the duration within two date-time column
cal_time<-function(col1, col2){
  result<-difftime(as.Date(col1), as.Date(col2), units = c("days"))
  message("cal_time is working fine")
  return(result)
}

#function to calcualte new variable with length for object school_id with message back
cal_len<-function(source, var){
  result<-dcast(source, School_ID~., length, value.var = c(var))
  message("cal_len function is working fine")
  return(result)
}

#function to calculate new variable with sum for object school_id
cal_sum<-function(source, var){
  result<-dcast(source, School_ID~., sum, value.var = c(var))
  message("cal_sum function is working fine")
  return(result)
}

#function to calcualte new variable with mean for object school_id
cal_mean<-function(source, var){
  result<-dcast(source,School_ID~ .,mean,value.var=c(var))
  message("cal_mean function for is working fine")
  return(result)
}

#function data.table to organized the data
dataTable<-function(content){
  result<-data.table(content)
  message("data.table is appied")
  return(result)
}
  
#function of ggplot
plot<-function(source, Xaes, Yaes){
  p<-ggplot(source, aes(Xaes, Yaes))
  message("plot function is working fine")
  return(p)
}

main<-function(){
  #loading in the data
  Projects<-fread("Projects.csv")
  Schools<-fread("Schools.csv")
  Resources<-fread("Resources.csv")
  
  #Calculate the Duration between posted date and fully funded date from each projects, Use the date-time column and make 1 new variable.
  setnames(Projects, "Project Posted Date", "Project_Posted_Date")
  setnames(Projects, "Project Fully Funded Date", "Project_Fully_Funded_Date")
  
  #calculate the time a project needed to be fully funded
  Projects$FullyFundedTime<-cal_time(Projects$Project_Fully_Funded_Date, Projects$Project_Posted_Date)
  #change the data type so it can be calculated by dcast
  Projects$FullyFundedTime<-as.numeric(Projects$FullyFundedTime)
  
  #merging resources into project table, setkey and setname
  setnames(Resources, "Project ID", "Project_ID")
  setnames(Projects, "Project ID", "Project_ID")
  setkey(Resources, Project_ID)
  setkey(Projects, Project_ID)
  proj_Resource<-merge(Projects,Resources,all.x=T)
  setnames(proj_Resource,"School ID","School_ID")
  
  #call cal_len function to calculate the total count of school Project
  schoolProjCount<-cal_len(proj_Resource, 'School_ID')
  
  #call cal_sum function to calculate the project total cost for each school
  schoolProjTotalCost<-cal_sum(proj_Resource, 'Project Cost')
  
  #call cal_mean function to calculate the average unit price for each school
  schoolAvgUnitPrice<-cal_mean(proj_Resource, 'Resource Unit Price')
  
  #call cal_mean function to calculate the average quantity for each school
  schoolAvgQuantity<-cal_mean(proj_Resource, 'Resource Quantity')
  
  #call cal_mean function to calculate the average fullyfunded time for each school
  schoolAvgFullyFunded<-cal_mean(proj_Resource, 'FullyFundedTime')
  
  #reset all the name for four new calculated variables
  setnames(schoolProjCount, ".", "School_Proj_Count")
  setnames(schoolProjTotalCost, ".", "school_Proj_Total_Cost")
  setnames(schoolAvgUnitPrice, ".", "Avg_UnitPrice")
  setnames(schoolAvgQuantity, ".", "Avg_Quantity")
  setnames(schoolAvgFullyFunded, '.', "Avg_FullyFunded_time")
  
  #use dataTable functino to organize the data
  schoolProjCount<-dataTable(schoolProjCount)
  schoolProjTotalCost<-dataTable(schoolProjTotalCost)
  schoolAvgUnitPrice<-dataTable(schoolAvgUnitPrice)
  schoolAvgQuantity<-dataTable(schoolAvgQuantity)
  schoolAvgFullyFunded<-dataTable(schoolAvgFullyFunded)
  
  #merging all the new data for schools along with school information to one new tidy table
  setnames(Schools, "School ID", "School_ID")
  setkey(Schools, School_ID)
  setkey(schoolProjCount, School_ID)
  setkey(schoolProjTotalCost, School_ID)
  setkey(schoolAvgUnitPrice, School_ID)
  setkey(schoolAvgQuantity, School_ID)
  setkey(schoolAvgFullyFunded, School_ID)
  
  #merging
  schoolStat<-merge(Schools,schoolProjCount,all.x=T)
  schoolStat<-merge(schoolStat,schoolProjTotalCost,all.x=T)
  schoolStat<-merge(schoolStat,schoolAvgUnitPrice,all.x=T)
  schoolStat<-merge(schoolStat,schoolAvgQuantity,all.x=T)
  schoolStat<-merge(schoolStat, schoolAvgFullyFunded, all.x=T)
  
  #calculate the new variable school Project Average Cost
  schoolStat$schoolProjAvgCost<-schoolStat$school_Proj_Total_Cost/schoolStat$School_Proj_Count
  
  #clean up data before plotting
  schoolStat<-schoolStat[!is.na(schoolStat$School_Proj_Count)]
  schoolStat<-schoolStat[!is.na(schoolStat$Avg_Quantity)]
  schoolStat<-schoolStat[!is.na(schoolStat$Avg_UnitPrice)]
  
  #using plot function to graph
  #Relationship between school total project count and school total project cost
  plot(schoolStat, schoolStat$School_Proj_Count, schoolStat$school_Proj_Total_Cost) + geom_point() + ggtitle("Project counts and Projects total cost for each School") + theme(plot.title = element_text(hjust = 0.5))+xlab("Project Total Count per School")+ylab("Project Total Cost per School")
  ggsave("Count_vs_Cost.pdf")
  #Relationship between school Project avgerage cost and average unit price from resources
  plot(schoolStat, schoolStat$schoolProjAvgCost, schoolStat$Avg_UnitPrice) + geom_point() + ggtitle("Project Average cost and Resource Average unit Price for each School") + theme(plot.title = element_text(hjust = 0.5))+xlab("Project Average Cost per School")+ylab("Resource Average Unit Price per School")
  ggsave("AvgCost_vs_AvgUnitPrice.pdf")
  #Relationship between shcool Project total cost and average quantity of resources for schools
  plot(schoolStat, schoolStat$school_Proj_Total_Cost, schoolStat$Avg_Quantity) + geom_point() + ggtitle("shcool Project total cost and average quantity of resources for each School") + theme(plot.title = element_text(hjust = 0.5))+xlab("Project Total Cost per School")+ylab("Resource Average Quantity per School")
  ggsave("TotalCost_vs_AvgQuantity")
}

main()
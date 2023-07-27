# ---------------- Change Point Modelling on Highfield Campus ----------------

# Author: Jamie Williams & Karla Gonzalez
# Last edited: Wednesday, 26/07/2023 @ 14:55pm
# Version: 1.0


# ---------------- **** User Input **** ----------------

# Input Data.
# *** Enter the location of the input data.
regData <- read.csv("./data/Raw_Data/Example_Data.csv", header = TRUE)


# *** Enter the balance Points to test.
BP_trial <- seq(14, 16, by = 0.5)


# *** Enter the rows to be considered in each Time Period and their names.

Split_1 <- 1:12
Title_1 <- "Year 1"

Split_2 <- 13:24
Title_2 <- "Year 2"

Split_3 <- 25:36
Title_3 <- "Year 3"

# -------------------------------------------------------





# -------- Package Setup --------

# Cleaner installation of the packages.
wanted_packages <- c("fBasics", "dplyr", "gtools", "knitr", "boot", "lm.beta", "pROC", "car", "DAAG", "nortest", "MLmetrics", "Metrics", "dLagM")

missing_packages <- wanted_packages[!wanted_packages %in% rownames(installed.packages())]

if (length(missing_packages) > 0) {
    install.packages(missing_packages)
}

lapply(wanted_packages, require, character.only = TRUE)

# Setup for the Comparison Table.
Comparison_Table <- data.frame()

# Setup for the Final List.
Final_List <- data.frame()



# -------- Assessing the data to be looped --------

# number of rows in the csv.
nData <- nrow(regData)

# Arranging k separate sets for the 48 separate buildings.
rowNumbers <- 1:nData
kSets <- max(na.omit(regData$K.SETS))

# Number of Balance points that need to be trialed.
nBP <- length(BP_trial)



# -------- Begin Looping --------

# Loop through the dataset 3 times.
for (x in 1:3) {
    if (x == 1) {
        Current_Rows <- Split_1
        Period <- Title_1
    }
    if (x == 2) {
        Current_Rows <- Split_2
        Period <- Title_2
    }
    if (x == 3) {
        Current_Rows <- Split_3
        Period <- Title_3
    }

    # Setup for Best Model List.
    Best_Model_List <- data.frame("ID", "Building Name", "Balance Point", "Base", "Intercept", "Slope", "RMSE")

    # For each building 'i' in the dataset.
    for (i in 1:kSets) {
        # -------- Data selection --------

        # Select the set rows which correspond to the current building 'i'.
        trainSet <- subset(rowNumbers, regData$K.SETS == i)

        # Selects the data from the csv for modelling, according to the training rows.
        trainData <- regData[trainSet, ]

        # Select the correct years of data only.
        Current_Set <- trainData[Current_Rows, ]

        # Length of the training set.
        nTrain <- length(Current_Set)
        

        # For each Balance Point 'j' that we are testing.
        for (j in 1:nBP) {
            # -------- Dummy Variables --------
            # Selects the temperature column.
            Temperatures <- Current_Set$Temperature.C

            # Assigns the current Balance Point that needs to be tested.
            Balance_Point <- BP_trial[j]

            # Compares values against the Balance point.
            # If a value is below the balance point, returns a 1,
            # Else, returns a 0.
            Dummy_Variables <- ifelse(Temperatures <= Balance_Point, 1, 0)

            # Creates the "modified temperature list", i.e., the temperature list with
            # zeros in place of temperatures greater than the balance point.
            Dummy_Temp <- Temperatures * Dummy_Variables

            # Adds the Dummy Variables and Dummy*Temp list from the current Balance Point
            # to this the Training Data set.
            Current_Set <- cbind(Current_Set, Dummy_Variables, Dummy_Temp)




            # -------- Regression Analysis --------

            # Creates the linear Regression models.
            regModel <- lm(Energy.Signature ~ Dummy_Temp + Dummy_Variables, data = Current_Set)

            # Creating the Coefficient Matrix.
            coeffMatrix <- cbind(summary.lm(regModel)$coefficients)



            # -------- Goodness of Fit --------

            # List of Modelling Coefficients.
            Base <- coeffMatrix[1, 1]
            Slope <- coeffMatrix[2, 1]
            Intercept <- coeffMatrix[3, 1]

            # Energy Signature Prediction.
            Sig_Pred <- Base + (Slope * Dummy_Temp) + (Intercept * Dummy_Variables)

            # Hours in a given Month.
            Hours_Month <- Current_Set$Days.in.the.Month * 24

            # Energy Prediction.
            Energy_Pred <- Sig_Pred * Hours_Month

            # Energy Measurements.
            Energy_Measured <- Current_Set$Energy.Signature * Hours_Month

            # Calculates the Energy Residuals.
            Residuals <- Energy_Measured - Energy_Pred

            # Variance (Sample).
            Var <- var(Energy_Measured)

            # Calculating RMSE, (the 3 represents the degrees of freedom).
            RMSE <- (sum(Residuals^2) / (nTrain - 3))^0.5

            # Coefficient of Variation of Root Mean Square Error.
            CV_RMSE <- 100 * (nTrain * RMSE) / sum(Energy_Measured)

            # Coefficient of Determination R^2.
            R2 <- 100 * (1 - ((sum(Residuals^2)) / (nTrain * Var)))

            # Normalised mean bias error (NMBE).
            NMBE <- 100 * ((sum(Residuals) * nTrain) / ((nTrain - 3) * sum(Energy_Measured)))
            
            # Saves data in Comparison_Table for each Balance_Point.
            Comparison_Table[j, 1:10] <- c(
                Current_Set$id[j], Current_Set$Building.Name[j], Balance_Point,
                Base, Intercept, Slope, RMSE, CV_RMSE, R2, NMBE
            )

            # Removes the Dummy columns before the next loop.
            Current_Set <- Current_Set[, -13:-14]

       
        } # End of Temperature Looping.
        
        # Identify the minimum RMSE.
        n <- which.min(Comparison_Table$V7) 
        
        # Selecting the best fitting values from the Comparison Table and store them in a Final List.
        Best_Model_List[i, 1:10] <- Comparison_Table[n, c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10")]
        


        #-------- Plotting --------
        # Recalculating Dummy Variables and Dummy*Temp.
        Dv <- ifelse(Temperatures <= as.numeric(Best_Model_List$X.Balance.Point.[i]), 1, 0)
        DTemp <- Temperatures * Dv

        # Energy Signature Predictions, for plotting.
        Opt_pred <- as.numeric(Best_Model_List$X.Base.[i]) + (as.numeric(Best_Model_List$X.Intercept.[i]) * Dv) + (as.numeric(Best_Model_List$X.Slope.[i]) * DTemp)


        # *** File path.
        my_path <- "./data/Raw_Graphs_CHP/"
        all_paths <- paste0(my_path, "Building_ID_", i, "_Time_Period_", x, ".png")


        # Graph Plotting.

        name <- c(paste0("CHP Linear Model: ", Best_Model_List$X.Building.Name.[i]), "", paste(Period))
        png(all_paths, width = 3000, height = 3000, res = 500, pointsize = 9)

        plot(Current_Set$Temperature.C, Opt_pred,
            pch = 21, bg = "black", col = "black",
            cex = 1.5, main = name, ylab = "CHP [kW]", xlab = "Temperatures [C]", grid(), cex.lab = 1.25, cex.main = 1.5)
        points(Current_Set$Temperature.C, Current_Set$Energy.Signature, col = "orange", pch = 19, cex = 1.5)

        legend("topright",
            legend = c("Predicted", "Measured"),
            col = c("black", "orange"), cex = 1.25,
            inset = 0.025, box.lty = 0, pch = (16))

        dev.off()
    } # End of building Looping.

    # Write a new column to include the Time Period.
    Times <- rep(Period, times = kSets)

    # Add the Time Period to the Best Model List and then save the data into the Final List.
    Best_Model_List <- cbind(Best_Model_List[1:2], Times, Best_Model_List[3:10])
    Final_List <- rbind(Final_List, Best_Model_List)

} # End of Time Period Looping.


# Clarify the Column heading in "Final_List".
colnames(Final_List) <- c("ID", "Building Name", "Time Period", "Best Balance Point", "Base", "Intercept", "Slope", "RMSE", "CV(RMSE)", "R2", "NMBE")


# Rearranging the Final_List in ascending order of ID.
Final_List$ID <- as.numeric(as.character(Final_List$ID))
Final_List <- arrange(Final_List, ID)
rownames(Final_List) <- NULL

# Convert the specific columns to numeric
Final_List[, 5:11] <- lapply(Final_List[, 5:11], function(x) as.numeric(as.character(x)))

# Round the numeric columns to 2 decimal places
Final_List[, 5:11] <- round(Final_List[, 5:11], digits = 4)
# Write a .csv file containing the best fitting building models and their statistical indicators.

write.csv(Final_List, "Best_Models_CHP.csv")

head(Final_List)

# ---------- End of Script ----------

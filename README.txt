Firstly, thank you for downloading this project!
Below is an outline of the steps you should take to use this project for your own dataset.

1. Inside the "data" folder and then the "Raw_Data" subfolder, place a .csv file containing your dataset.
An example dataset* has been placed in this folder to demonstate how your dataset should be formatted.
Please ensure that you have the column headings labelled exactly in the same way.
*The example data provided is for demonstration purposes only, the numbers shown have been made up
and likely do not replicate building behaviour. 

2. Create 2 new subfolders within the data folder labelled "Raw_Graphs_CHP" and "Final_Graphs_CHP".
Alternatively, after step 4 you can define your own file path within the code at line 210 in R,
and lines 20-21 in python.

3. It is recommended that you use the RStudio IDE to interact with this project. Firstly open the R Project file named "Building Energy Modelling". In your command terminal you can write "getwd()" to verify the working directory is correct.
If the working directory is incorrect, you can use the command "setwd("filepath")", to correct this.

4. Edit the "input data" settings between lines 12 and 28. 
**Importantly**, If your data includes more or less split points than used in the example, you should add/remove an extra "if statement" between lines 74 and 86. Also be sure to change the for loop from "1:3" to "1:x".

5. Run the code, in RStudio you can do this simply with ctrl + shift + enter.

6. To combine images for direct comparison, you can simply run the "Image_Concatenate" python file.


If you encounter any issues, please view the full code breakdown at bookdown.org/jamwills/energymodelling/.

Many thanks!

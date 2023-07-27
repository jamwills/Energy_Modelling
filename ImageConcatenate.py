"""
Highfield Regression Image Concatenate
Date: 25/07/2023
Time: 14:48
Authors: Jamie Williams & Karla Gonzalez
"""
import os
import PIL
from PIL import Image

# For testing the number of files in the directory.
count = 0

# Number of time periods assessed.
Time_Periods = 3

working_Directory = str(os.getcwd())

# *** Input the path to the folder containing the images created in R ***.
Source_folder_path = working_Directory + "\\data\\Raw_Graphs_CHP\\"
Output_folder_path = working_Directory + "\\data\\Final_Graphs_CHP\\"


# Checks the amount of files to be processed
for path in os.listdir(Source_folder_path):
    # check if current path is a file
    if os.path.isfile(os.path.join(Source_folder_path, path)):
        count += 1

# Loops through the number of buildings by using count / time periods.
# This is generalised incase future work uses more/less buildings or time periods.
for i in range(1, int((count/Time_Periods)+1)):

  # The Three image paths to be combined.
  T1 = Source_folder_path + "Building_ID_" + str(i) + "_Time_Period_1.png"
  T2 = Source_folder_path + "Building_ID_" + str(i) + "_Time_Period_2.png"
  T3 = Source_folder_path + "Building_ID_" + str(i) + "_Time_Period_3.png"
 
  # Open the images.
  images = [Image.open(x) for x in [T1, T2, T3]]
  widths, heights = zip(*(i.size for i in images))

  # Formatting.
  total_width = sum(widths)
  max_height = max(heights)
  new_im = Image.new('RGB', (total_width, max_height))

  # Combining the images.
  x_offset = 0
  for im in images:
    new_im.paste(im, (x_offset,0))
    x_offset += im.size[0]

  # Naming the file.
  filename = "Building_" + str(i) + "_Combined" + ".png"

  # Saving the final Image.
  new_im.save(Output_folder_path + filename, "PNG")

print("----End of Script!----")
#downloading all data

library(fs)
library(purrr)

dir_create("data/raw") #although created earlier

base <- "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/" 

#2017 to 2020 full set in one

files <- list(
  c("2017/DataFiles/P_DEMO.xpt",  "data/raw/P_DEMO.xpt"),
  c("2017/DataFiles/P_BPXO.xpt",  "data/raw/P_BPXO.xpt"),
  c("2017/DataFiles/P_TCHOL.xpt", "data/raw/P_TCHOL.xpt"),
  c("2017/DataFiles/P_HDL.xpt",   "data/raw/P_HDL.xpt"),
  c("2017/DataFiles/P_TRIGLY.xpt","data/raw/P_TRIGLY.xpt")
)

walk(files, function(f) {
  if (!file_exists(f[2])) { #will not download if file already exists
    message("Downloading ", basename(f[2]))
    download.file(paste0(base, f[1]), f[2], mode = "wb", quiet = TRUE) #the entire URL made by pasting the base and the suffix URL and the destination folder specified
  } else {
    message("File exists: ", basename(f[2])) 
  }
})

walk(dir_ls("data/raw"), \(f) message(sprintf("  %-20s %s", basename(f), file_size(f)))) #check file size for sanity

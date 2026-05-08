library(fs)
library(purrr)

dir_create("data/raw") #although created earlier

base <- "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/" 

files <- list(
  c("2017/DataFiles/P_DEMO.xpt",  "data/raw/P_DEMO.xpt"), #2017-20 full set in one. 
  c("2017/DataFiles/P_BPXO.xpt",   "data/raw/P_BPXO.xpt"),
  c("2017/DataFiles/P_TCHOL.xpt", "data/raw/P_TCHOL.xpt")
)

walk(files, function(f) {
  if (!file_exists(f[2])) { #will not download if file already exists
    message("Downloading ", basename(f[2]))
    download.file(paste0(base, f[1]), f[2], mode = "wb", quiet = TRUE) #the entire URL made by pasting the base and the suffix URL and the destination folder specified
  } else {
    message("File exists: ", basename(f[2])) 
  }
})

message("Done. Files:")
walk(dir_ls("data/raw"), \(f) message(sprintf("  %-20s %s", basename(f), file_size(f)))) #check file size for sanity
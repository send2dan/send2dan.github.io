#example of here() file location 
data <- readxl::read_excel(here::here("02_data", "2021_11_13_salter_data.xlsx"),
                                col_types = c("date", "text", "numeric", 
                                              "numeric", "numeric", "numeric", 
                                              "skip", "skip"), skip = 4)

#data import



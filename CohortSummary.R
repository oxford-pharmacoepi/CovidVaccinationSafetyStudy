library(UpSetR)

# Summary of exposure cohorts
db <- dbConnect(RPostgreSQL::PostgreSQL(),
                dbname = "p20_000211_cdm_aurum",
                port = 5432,
                host = "163.1.64.2", 
                user = "eburn", 
                password = "eburn")

# link to db tables -----
person_db<-tbl(db, sql(paste0("SELECT * FROM ",
                              cdm_database_schema,
                              ".person")))
observation_period_db<-tbl(db, sql(paste0("SELECT * FROM ",
                                          cdm_database_schema,
                                          ".observation_period")))
visit_occurrence_db<-tbl(db, sql(paste0("SELECT * FROM ",
                                        cdm_database_schema,
                                        ".visit_occurrence")))
condition_occurrence_db<-tbl(db, sql(paste0("SELECT * FROM ",
                                            cdm_database_schema,
                                            ".condition_occurrence")))
drug_exposure_db<-tbl(db, sql(paste0("SELECT * FROM ",
                                     cdm_database_schema,
                                     ".drug_exposure")))
concept_ancestor_db<-tbl(db, sql(paste0("SELECT * FROM ",
                                        cdm_database_schema,
                                        ".concept_ancestor")))

VaxCohorts_db<-tbl(db, sql(paste0("SELECT * FROM ",
                   results_database_schema,
                   ".diagCovVaxCohorts")))



###
# Create Pop df ----  
Cohorts<-person_db %>% 
  inner_join(VaxCohorts_db %>% 
               select(cohort_definition_id,subject_id,cohort_start_date) %>% 
               rename("person_id"="subject_id")) %>% 
  select(person_id,gender_concept_id, 
         year_of_birth, month_of_birth, day_of_birth,
         cohort_start_date,
         cohort_definition_id)  %>% 
  collect()

# add age and gender -----
Cohorts$age<- NA
if(sum(is.na(Cohorts$day_of_birth))==0 & sum(is.na(Cohorts$month_of_birth))==0){
  # if we have day and month 
  Cohorts<-Cohorts %>%
    mutate(age=floor(as.numeric((ymd(cohort_start_date)-
                                   ymd(paste(year_of_birth,
                                             month_of_birth,
                                             day_of_birth, sep="-"))))/365.25))
} else { 
  Cohorts<-Cohorts %>% 
    mutate(age= year(cohort_start_date)-year_of_birth)
}

Cohorts<-Cohorts %>% 
  mutate(age_gr=ifelse(age<20,  "<20",
                       ifelse(age>=20 &  age<=44,  "20-44",
                              ifelse(age>=45 & age<=54,  "45-54",
                                     ifelse(age>=55 & age<=64,  "55-64",
                                            ifelse(age>=65 & age<=74, "65-74", 
                                                   ifelse(age>=75 & age<=84, "75-84",      
                                                          ifelse(age>=85, ">=85",
                                                                 NA)))))))) %>% 
  mutate(age_gr= factor(age_gr, 
                        levels = c("<20", "20-44","45-54", "55-64",
                                   "65-74", "75-84",">=85")))
# wider age groups
Cohorts<-Cohorts %>% 
  mutate(age_gr2=ifelse(age<=44,  "<=44",
                        ifelse(age>=45 & age<=64,  "45-64",    
                               ifelse(age>=55, ">=65",
                                      NA)))) %>% 
  mutate(age_gr2= factor(age_gr2, 
                         levels = c("<=44", "45-64",">=65")))

# another alternative set of age groups
Cohorts<-Cohorts %>% 
  mutate(age_gr3=ifelse(age<20,  "<20",
                        ifelse(age>=20 &  age<=29,  "20-29",
                               ifelse(age>=30 &  age<=39,  "30-39",
                                      ifelse(age>=40 &  age<=49,  "40-49",
                                             ifelse(age>=50 &  age<=59,  "50-59",
                                                    ifelse(age>=60 & age<=69,  "60-69",
                                                           ifelse(age>=70 & age<=79,  "70-79",      
                                                                  ifelse(age>=80, ">=80",
                                                                         NA))))))))) %>% 
  mutate(age_gr3= factor(age_gr3, 
                         levels = c("<20", "20-29","30-39","40-49", "50-59",
                                    "60-69", "70-79",">=80")))



# gender
#8507 male
#8532 female
Cohorts<-Cohorts %>% 
  mutate(gender= ifelse(gender_concept_id==8507, "Male",
                        ifelse(gender_concept_id==8532, "Female", NA ))) %>% 
  mutate(gender= factor(gender, 
                        levels = c("Male", "Female")))


# if missing age or gender, drop
Cohorts<-Cohorts %>% 
  filter(!is.na(age))

Cohorts<-Cohorts %>% 
  filter(!is.na(gender))


# exclusions ----
Cohorts<-Cohorts %>% 
  # filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
  # filter(cohort_start_date<=as.Date("2021-02-27")) %>% 
  filter(age>=30)

# Cohorts %>% 
#   filter(cohort_start_date<=as.Date("2020-12-08")) %>% 
#   filter(cohort_definition_id=="20") %>% 
#   tally()
# 
# Cohorts %>% 
#   filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
#   filter(cohort_definition_id=="19") %>% 
#   tally()
# Cohorts %>% 
#   filter(cohort_definition_id=="19") %>% 
#   filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
#   filter(cohort_start_date<=as.Date("2021-03-06")) %>% 
#   tally()
# Cohorts %>% 
#   filter(cohort_definition_id=="19") %>% 
#   filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
#   filter(cohort_start_date<=as.Date("2021-02-27")) %>% 
#   tally()
# 
# Cohorts %>% 
#   filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
#   filter(cohort_definition_id=="20") %>% 
#   tally()
# Cohorts %>% 
#   filter(cohort_definition_id=="20") %>% 
#   filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
#   filter(cohort_start_date<=as.Date("2021-03-06")) %>% 
#   tally()
# Cohorts %>% 
#   filter(cohort_definition_id=="20") %>% 
#   filter(cohort_start_date>=as.Date("2020-12-08")) %>% 
#   filter(cohort_start_date<=as.Date("2021-02-27")) %>% 
#   tally()


# names ----
Cohorts<-Cohorts %>% 
  mutate(cohort.name=if_else(cohort_definition_id=="19", "Vaccinated with AstraZeneca",
                     if_else(cohort_definition_id=="20", "Vaccinated with Pfizer-Biontech", 
                      "Vax")))
Cohorts %>% 
  group_by(cohort.name) %>% 
  group_by(age_gr, cohort_definition_id) %>% 
  tally()
# plot/ summarise cohort intersection ------
## Intersection between cohorts ------
# upset.data<-Cohorts %>% 
#   select(person_id, cohort.name)%>%
#   mutate(seen=1)  %>%
#   distinct() %>% 
#   pivot_wider(names_from = cohort.name, values_from = seen,
#               values_fill = 0)
# upset.data<-as.data.frame(upset.data)
# 
# upset.plot<-upset(upset.data,
#                   order.by = "freq",
#                   text.scale=1.85,
#                   mainbar.y.label="Intersection",
#                   sets.bar.color = "black",main.bar.color ="black",
#                   matrix.color = "red",set_size.show = FALSE,
#                   sets.x.label = "Total")
# 
# 
# png(file=here("updated.upset.plot.png") ,
#     width =1000 , height = 550) 
# upset.plot
# dev.off()










# plot cohort entry over time ------
sum<-Cohorts  %>%  
  filter(cohort_definition_id %in% c("19", "20")) %>% 
  group_by(cohort_start_date, cohort.name,age_gr,gender) %>% 
  tally()
  
sum %>%  
  ggplot()+
  facet_grid(age_gr ~gender, switch="y")+
  geom_col(aes(cohort_start_date,n,  fill=cohort.name), 
           colour="black")+
  theme_bw()+ 
  theme(panel.spacing.x = unit(0.2, "lines"),
        legend.title = element_blank(),
        axis.text=element_text(size=14),
        strip.text = element_text(size=14, face="bold"),
        strip.text.y.left = element_text(angle = 0),
        strip.background = element_rect( fill="#f7f7f7"),
        axis.title = element_blank(),
        legend.text=element_text(size=14), 
        legend.position = "top")+
  scale_y_continuous(label=label_comma(accuracy= 1), position = "right")+
  scale_fill_manual(values=c("Vaccinated with AstraZeneca" = "#e41a1c",
                              "Vaccinated with Pfizer-Biontech" = "#377eb8"))

sum<-Cohorts  %>%  
  filter(cohort_definition_id %in% c("19", "20")) %>% 
  group_by(cohort_start_date, cohort.name,age_gr2,gender) %>% 
  tally()

sum %>%  
  ggplot()+
  facet_grid(age_gr2 ~gender, switch="y")+
  geom_col(aes(cohort_start_date,n,  fill=cohort.name), 
           colour="black")+
  theme_bw()+ 
  theme(panel.spacing.x = unit(0.2, "lines"),
        legend.title = element_blank(),
        axis.text=element_text(size=14),
        strip.text = element_text(size=14, face="bold"),
        strip.text.y.left = element_text(angle = 0),
        strip.background = element_rect( fill="#f7f7f7"),
        axis.title = element_blank(),
        legend.text=element_text(size=14), 
        legend.position = "top")+
  scale_y_continuous(label=label_comma(accuracy= 1), position = "right")+
  scale_fill_manual(values=c("Vaccinated with AstraZeneca" = "#e41a1c",
                             "Vaccinated with Pfizer-Biontech" = "#377eb8"))

sum<-Cohorts  %>%  
  filter(cohort_definition_id %in% c("19", "20")) %>% 
  group_by(cohort_start_date, cohort.name,age_gr3,gender) %>% 
  tally()

sum %>%  
  ggplot()+
  facet_grid(age_gr3 ~gender, switch="y")+
  geom_col(aes(cohort_start_date,n,  fill=cohort.name), 
           colour="black")+
  theme_bw()+ 
  theme(panel.spacing.x = unit(0.2, "lines"),
        legend.title = element_blank(),
        axis.text=element_text(size=14),
        strip.text = element_text(size=14, face="bold"),
        strip.text.y.left = element_text(angle = 0),
        strip.background = element_rect( fill="#f7f7f7"),
        axis.title = element_blank(),
        legend.text=element_text(size=14), 
        legend.position = "top")+
  scale_y_continuous(label=label_comma(accuracy= 1), position = "right")+
  scale_fill_manual(values=c("Vaccinated with AstraZeneca" = "#e41a1c",
                             "Vaccinated with Pfizer-Biontech" = "#377eb8"))
# library(tsibble)
# plot.data<-as_tsibble(sum, 
#                       key = c(cohort.name, age_gr, gender), index = cohort_start_date)
# plot.data<-plot.data %>% 
#   fill_gaps(.full = TRUE) %>%
#   mutate(n= ifelse(is.na(n), 0, n)) 
# 
# # add rolling weekly average
# plot.data<-data.frame(plot.data) %>% 
#   group_by(cohort.name, age_gr, gender ) %>% 
#   mutate(n.slide = slider::slide_dbl(n, mean, .before = 1, .after = 1,
#                                      .complete = TRUE)) %>% 
#   filter(!is.na(n.slide))
# 
# 
# tibble(plot.data) %>%  
#   ggplot()+
#   facet_grid(age_gr ~gender, switch="y")+
#   geom_col(aes(cohort_start_date,n.slide,  fill=cohort.name) 
#            , colour="black")+
#   theme_bw()+ 
#   theme(panel.spacing = unit(0, "lines"),
#         legend.title = element_blank(),
#         axis.text=element_text(size=14),
#         strip.text = element_text(size=14, face="bold"),
#         strip.text.y.left = element_text(angle = 0),
#         strip.background = element_rect( fill="#f7f7f7"),
#         axis.title = element_blank(),
#         legend.text=element_text(size=14), 
#         legend.position = "top")+
#   scale_y_continuous(label=label_comma(accuracy= 1), position = "right")+
#   scale_fill_manual(values=c("Vaccinated with AstraZeneca" = "#e41a1c",
#                              "Vaccinated with Pfizer-Biontech" = "#377eb8"))
# 


# 
# Cohorts %>%  
#   filter(cohort_definition_id %in% c("19", "20")) %>% 
#   ggplot()+
#   facet_grid(age_gr ~gender, switch="y")+
#   geom_histogram(aes(cohort_start_date,  fill=cohort.name), 
#            colour="black", binwidth = 7)+
#   theme_bw()+ 
#   theme(panel.spacing = unit(0.6, "lines"),
#         legend.title = element_blank(),
#         axis.text=element_text(size=14),
#         strip.text = element_text(size=14, face="bold"),
#         strip.text.y.left = element_text(angle = 0),
#         strip.background = element_rect( fill="#f7f7f7"),
#         axis.title = element_blank(),
#         legend.text=element_text(size=14), 
#         legend.position = "top")+
#   scale_y_continuous(label=label_comma(accuracy= 1), position = "right")+
#   scale_fill_manual(values=c("Vaccinated with AstraZeneca" = "#e41a1c",
#                              "Vaccinated with Pfizer-Biontech" = "#377eb8"))






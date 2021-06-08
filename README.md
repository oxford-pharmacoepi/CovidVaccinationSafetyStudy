CovCoagBackgroundIncidence- Background incidence of coagulopathy outcomes
========================================================================================================================================================

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Results Available">

- Type: **Characterisation**
- Results explorer: **[ShinyApp](https://livedataoxford.shinyapps.io/CovCoagBackgroundIncidence/)**
- Protocol: ** **
- Publications: ** **

## Running the analysis
1) Download this entire repository (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 
2) Open the project <i>CovCoagBackgroundIncidence.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session)
3) Open the <i>CodeToRun.R</i> file which should be the only file that you need to interact with
<li> Run <i>renv::activate()</i> and <i>renv::restore()</i> to bring in the required packages to be used</li> 
<li> <i>outputFolder <- "...."</i>: the path to a folder (that exists) where the results from this analysis will be saved</li> 
<li> <i>connectionDetails <- createConnectionDetails(".........")</i>: These are the connection details for the 
<a href="http://ohdsi.github.io/DatabaseConnector">OHDSI DatabaseConnector</a> package.Note, this is v4.0.0 of DatabaseConnector and so you will need to have downloaded the relevant drivers (see <a href="http://ohdsi.github.io/DatabaseConnector/articles/UsingDatabaseConnector.html">here</a> for more details) and pass the <i>pathToDriver</i> argument to the <i>createConnectionDetails</i> command.</li>
  <li>targetDialect <-".....": This is your sql dialect used with the OHDSI <a href="https://ohdsi.github.io/SqlRender/articles/UsingSqlRender.html">SqlRender</a> package</li> 
<li><i>cdm_database_schema <-"....."</i>: This is the name of the schema that contains the OMOP CDM with patient-level data </li> 
<li><i>results_database_schema <-"....."</i>: This is the name of the schema where a results table will be created </li> 
<li><i>cohortDatabaseSchema <-"....."</i>: This is the name of the schema where a results table will be created </li>
<li><i>cohortTableExposures<-"diagCovCoagIncExposures", cohortTableOutcomes <-"diagCovCoagIncOutcomes", cohortTableProfiles<-"diagCovCoagIncProfiles"</i>:  These are the tables to be created in your results schema for this analysis. Note, any existing tables in your results schema with the same name will be overwritten</li> 
<li>db <- dbConnect("........."): This is a connection to your database with the <a href="https://rdrr.io/cran/DBI/man/dbConnect.html">DBI</a> package. Database specific information for how to create this connection can be found <a href="https://db.rstudio.com/databases">here</a> </li>  
<li><i>db.name <-"....."</i>: This is the short name/ acronym for your database</li>  
<li><i>test.run<-FALSE</i>: If you want to to quckly (well, relatively) check that the package works, set this to TRUE and the code will run for one exposure population, one baseline commorbidity, one baseline medication, and one outcome of interest. If that works, then change back to TRUE and re-run for the full analysis</li> 
<li>After running you should then have a zip folder with results to share in your output folder. This contains three RData files, which contain aggregated statistics on patient characteristics and incidence rates.</li> 

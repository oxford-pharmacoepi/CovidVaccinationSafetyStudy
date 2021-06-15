CovidVaccinationSafetyStudy
========================================================================================================================================================

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Results Available">

- Results explorer: **[ShinyApp](https://livedataoxford.shinyapps.io/CovidVaccinationSafetyStudy/)**

## Running the analysis
1) Download this entire repository (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 
2) Open the project <i>CovCoagBackgroundIncidence.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session)
3) Open the <i>CodeToRun.R</i> file which should be the only file that you need to interact with, comments with instructions are in that file but here are some further things to note:
<li> Run <i>renv::activate()</i> and <i>renv::restore()</i> to bring in the required packages to be used</li> 
<li> <i>outputFolder <- "...."</i>: the path to a folder (that exists) where the results from this analysis will be saved</li> 
<li> <i>connectionDetails <- createConnectionDetails(".........")</i>: These are the connection details for the 
<a href="http://ohdsi.github.io/DatabaseConnector">OHDSI DatabaseConnector</a> package.Note, this is v4.0.0 of DatabaseConnector and so you will need to have downloaded the relevant drivers (see <a href="http://ohdsi.github.io/DatabaseConnector/articles/UsingDatabaseConnector.html">here</a> for more details) and pass the <i>pathToDriver</i> argument to the <i>createConnectionDetails</i> command.</li>
  <li>targetDialect <-".....": This is your sql dialect used with the OHDSI <a href="https://ohdsi.github.io/SqlRender/articles/UsingSqlRender.html">SqlRender</a> package</li> 
<li>db <- dbConnect("........."): This is a connection to your database with the <a href="https://rdrr.io/cran/DBI/man/dbConnect.html">DBI</a> package. Database specific information for how to create this connection can be found <a href="https://db.rstudio.com/databases">here</a> </li>  
<li>After running you should then have a zip folder with results in your output folder. </li> 

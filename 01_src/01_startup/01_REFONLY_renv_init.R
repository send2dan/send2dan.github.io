# renv script

# https://rstudio.github.io/renv/articles/renv.html

# explaining renv ---------------------------------------------------------

#https://rstudio.github.io/renv/articles/renv.html#collaboration
#Collaboration
#One of the reasons to use renv is to make it easier to share your code in such a way that everyone gets exactly the same package versions as you. As above, you’ll start by calling renv::init(). You’ll then need to commit renv.lock, .Rprofile, renv/settings.json and renv/activate.R to version control, ensuring that others can recreate your project environment. If you’re using git, this is particularly simple because renv will create a .gitignore for you, and you can just commit all suggested files3.
#Now when one of your collaborators opens this project, renv will automatically bootstrap itself, downloading and installing the appropriate version of renv. It will also ask them if they want to download and install all the packages it needs by running renv::restore().

#If you’d like to initialize a project without attempting dependency discovery and installation – that is, you’d prefer to manually install the packages your project requires on your own – you can use renv::init(bare = TRUE) to initialize a project with an empty project library.

# The renv package is a new effort to bring project-local R dependency management to your projects. 

library(renv)

# Underlying the philosophy of renv is that any of your existing workflows should just work as they did before – renv helps manage library paths (and other project-specific state) to help isolate your project’s R dependencies, and the existing tools you’ve used for managing R packages (e.g. install.packages(), remove.packages()) should work as they did before.

# Workflow
# The general workflow when working with renv is:
#   
#   Call renv::init() to initialize a new project-local environment with a private R library,

renv::init()

# fix project with restore then install then snapshot ---------------------
# 
# renv::restore()
# 
# renv::install()
# 
# renv::snapshot()

# 
# Work in the project as normal, installing and removing new R packages as they are needed in the project.

# 
# The renv::init() function attempts to ensure the newly-created project library includes all R packages currently used by the project. It does this by crawling R files within the project for dependencies with the renv::dependencies() function. 

# renv::dependencies()

# While useful, this approach is not 100% reliable in detecting the packages required by your project. If you find that renv’s dependency discovery is failing to discover one or more packages used in your project, one escape hatch is to include a file called _dependencies.R with code of the form:
  
  # library(<pkg>)

# The discovered packages are then installed into the project library with the renv::hydrate() function, which will also attempt to save time by copying packages from your user library (rather than reinstalling from CRAN) as appropriate.

# renv::hydrate()

# renv/activate.R ensures that the project library is made active for newly launched R sessions. It is automatically sourced via a call to source("renv/activate.R"), which is inserted into the project .Rprofile when renv::init() or renv::activate() is called. This ensures that any new R processes launched within the project directory will use the project library, and hence are isolated from the regular user library.

renv::activate()

#
# Calling renv::init() will also write out the infrastructure necessary to automatically load and use the private library for new R sessions launched from the project root directory. This is accomplished by creating (or amending) a project-local .Rprofile with the necessary code to load the project when the R session is started.
# 

# For development and collaboration, the .Rprofile, renv.lock and renv/activate.R files should be committed to your version control system; the renv/library directory should normally be ignored. Note that renv::init() will attempt to write the requisite ignore statements to the project .gitignore.

# In addition, be aware that package installation may fail if a package was originally installed through a CRAN-available binary, but that binary is no longer available. renv will attempt to install the package from sources in this situation, but attempts to install from source can (and often do) fail due to missing system prerequisites for compilation of a package. The renv::equip() function may be useful in these scenarios, especially on Windows: it will download external software commonly used when compiling R packages from sources, and instruct R to use that software during compilation.

renv::equip()

# A salient example of this is the rmarkdown package, as it relies heavily on the pandoc command line utility. However, because pandoc is not bundled with the rmarkdown package (it is normally provided by RStudio, or installed separately by the user), simply restoring an renv project using rmarkdown may not be sufficient – one also needs to ensure the project is run in a environment with the correct version of pandoc available.

# If you’d like to initialize a project without attempting dependency discovery and installation – that is, you’d prefer to manually install the packages your project requires on your own – you can use renv::init(bare = TRUE) to initialize a project with an empty project library.

# renv::init(bare = TRUE)

# 
# Call renv::snapshot() to save the state of the project library to the lockfile (called renv.lock),
# 
# Continue working on your project, installing and updating R packages as needed.
# 
# Call renv::snapshot() again to save the state of your project library if your attempts to update R packages were successful

renv::snapshot()

# ... or call renv::restore() to revert to the previous state as encoded in the lockfile if your attempts to update packages introduced some new problems.

renv::restore()

# 
# Reproducibility
# Using renv, it’s possible to “save” and “load” the state of your project library. More specifically, you can use:
#   
# renv::snapshot() to save the state of your project to renv.lock; and
# 
# renv::restore() to restore the state of your project from renv.lock.
# 
# For each package used in your project, renv will record the package version, and (if known) the external source from which that package can be retrieved. renv::restore() uses that information to retrieve and reinstall those packages in your project.

# Collaborating
# When sharing a project with other collaborators, you may want to ensure everyone is working with the same environment – otherwise, code in the project may unexpectedly fail to run because of changes in behavior between different versions of the packages in use. renv can help to make such collaboration easier – see vignette("collaborating", package = "renv") for more details

vignette("collaborating", package = "renv")

# Upgrading renv
# After initializing a project with renv, that project will then be ‘bound’ to the particular version of renv that was used to initialize the project. If you need to upgrade (or otherwise change) the version of renv associated with a project, you can use renv::upgrade(). This will install the latest-available version of renv from your declared package repositories. Alternatively, if you’re currently using a development version of renv as installed from GitHub in your project, then renv will install the latest-available version of renv from GitHub.

renv::upgrade()

# Cache
# One of renv’s primary features is the use of a global package cache, which is shared across all projects using renv. The renv package cache provides two primary benefits:
#   
#   Future calls to renv::restore() and renv::install() will become much faster, as renv will be able to find and re-use packages already installed in the cache.
# 
# Because it is not necessary to have duplicate versions of your packages installed in each project, the renv cache should also help you save disk space relative to an approach with project-specific libraries without a global cache.

# Package installation is requested via e.g. install.packages(), or renv::install(), or as part of renv::restore().

renv::install()

# If renv is able to find the requested version of the package in the cache, then that package is linked into the project library, and installation is complete.
# 
# Otherwise, the package is downloaded and installed into the project library.
# 
# After installation of the package has successfully completed, the package is then copied into the global package cache, and then linked back into the project library.

# By default, renv generates its cache in the following folders: Windows	%LOCALAPPDATA%/renv

# You can also force a package to be re-installed and re-cached with the following functions:
  
  # restore packages from the lockfile, bypassing the cache
  renv::restore(rebuild = TRUE)
  
  # re-install a package
  renv::install("<package>", rebuild = TRUE)
  
  # rebuild all packages in the project
  renv::rebuild()
  
# Uninstalling renv
#   If you find renv isn’t the right fit for your project, deactivating and uninstalling it is easy.
#   
#   To deactivate renv in a project, use renv::deactivate(). This removes the renv auto-loader from the project .Rprofile, but doesn’t touch any other renv files used in the project. If you’d like to later re-activate renv, you can do so with renv::activate().
#   
#   To completely remove renv from a project, call renv::deactivate(clean = TRUE). If you later want to use renv for this project, you’ll need to start from scratch with renv::init().
#   
#   If you want to stop using renv for all your projects, you’ll also want to remove renv's global infrastructure with the following R code6:
# 
# root <- renv::paths$root()
# unlink(root, recursive = TRUE)
# You can then uninstall the renv package with utils::remove.packages("renv").
  

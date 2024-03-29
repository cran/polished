% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/profile_module.R
\name{profile_module_ui}
\alias{profile_module_ui}
\title{Profile Module UI}
\usage{
profile_module_ui(id, other_lis = NULL)
}
\arguments{
\item{id}{the Shiny module id.}

\item{other_lis}{additional \code{<li>} HTML tags to place between the email address
and the Sign out button in the user profile dropdown.  This is often used to
add a user "My Account" page/app where the user can set their account settings.}
}
\value{
the UI to create the profile dropdown.
}
\description{
Generates the UI for a user profile dropdown button to be used with the
\code{shinydashboard} package.
}

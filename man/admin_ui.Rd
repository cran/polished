% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/admin_app.R
\name{admin_ui}
\alias{admin_ui}
\title{The UI for the "Admin Panel" dashboard}
\usage{
admin_ui(options = default_admin_ui_options())
}
\arguments{
\item{options}{list of HTML elements to customize branding of "Admin Panel".  Valid
list element names are \code{title}, \code{sidebar_branding}, and \code{browser_tab_icon}.  See
\code{\link{default_admin_ui_options}} for an example.}
}
\value{
the UI for the "Admin Panel"
}
\description{
The \code{shiny} module UI for the \code{polished} Admin Panel, accessible to Admin users.
}

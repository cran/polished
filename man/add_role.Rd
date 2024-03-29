% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_04_roles.R
\name{add_role}
\alias{add_role}
\title{Polished API - Add a Role}
\usage{
add_role(role_name, api_key = get_api_key())
}
\arguments{
\item{role_name}{a role name.}

\item{api_key}{your Polished API key.  Set your polished api key using \code{\link{set_api_key}()}
so that you do not need to supply this argument with each function call.}
}
\value{
an object of class \code{polished_api_res}.  When successful, the \code{content} of the
\code{polished_api_res} is \code{list(message = "success")}.  In the case of an error, the
content is \code{list(error = "<error message>")}.
}
\description{
Polished API - Add a Role
}
\seealso{
\code{\link[=get_roles]{get_roles()}} \code{\link[=delete_role]{delete_role()}}
}

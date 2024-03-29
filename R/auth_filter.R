#' Auth filter for a Plumber API
#'
#' @param method The authentication method.  Valid options are "basic" and/or "cookie".  If
#' "basic" is set, the filter will authenticate the request using basic auth.  If
#' "cookie", the filter will authenticate the request using the cookie.  If both
#' "cookie" and "basic" are set, then the filter will first attempt to authenticate
#' using the cookie, and, if that fails, it will attempt to authenticate using basic
#' auth.  If you use cookie based auth, and you want to send requests directly from the browser,
#' then be sure to set your Plumber API to allow for cookies.  See
#' \url{https://polished.tech/blog/polished-plumber} for details.
#' @param api_key Your polished API key
#'
#' @return a Plumber API filter function
#'
#' @export
#'
auth_filter <- function(method = c("basic", "cookie"), api_key = get_api_key()) {




  method <- sort(method)
  if (identical(length(method), 1L)) {
    if (!(method %in% c("basic", "cookie"))) {
      stop("invalid `method` argument", call. = FALSE)
    }
  } else {
    if (!identical(method, c("basic", "cookie"))) {
      stop("invalid `method` argument", call. = FALSE)
    }
  }



  function(req, res) {

    err_msg <- NULL
    req$polished_session <- NULL

    # attempt to find session based on cookie

    polished_cookie <- req$cookies$polished
    if ("cookie" %in% method) {

      tryCatch({

        if (is.null(polished_cookie)) {
          res$status <- 401L # unauthorized
          stop("polished cookie not provided", call. = FALSE)
        }

        # hash the cookie if sent unhashed
        if (grepl("p0.", polished_cookie, fixed = TRUE)) {
          polished_cookie <- digest::digest(polished_cookie)
        }

        r <- httr::GET(
          url = paste0(.polished$api_url, "/sessions"),
          query = list(
            hashed_cookie = polished_cookie,
            app_uid = .polished$app_uid,
            session_started = FALSE
          ),
          httr::authenticate(
            user = api_key,
            password = ""
          ),
          encode = "json"
        )


        sc <- httr::status_code(r)
        rc <- jsonlite::fromJSON(
          httr::content(r, "text", encoding = "UTF-8")
        )
        if (!identical(sc, 200L)) {
          res$status <- sc
          stop(rc$error, call. = FALSE)
        } else {

          if (identical(length(rc), 0L)) {
            res$status <- 401L
            stop("session not found", call. = FALSE)
          }

          req$polished_session <- rc

        }


        plumber::forward()
        return(NULL)

      }, error = function(err) {


        err_msg <<- conditionMessage(err)
        warning(err_msg)

        if ("basic" %in% method) {
          # set error back to null to check basic auth
          err_msg <<- NULL
          res$status <- 200L

        } else {

          if (identical(res$status, 200L)) {

            res$status <- 500L

          }
        }

        invisible(NULL)
      })

      if (!is.null(err_msg)) {
        return(list(
          error = jsonlite::unbox(err_msg)
        ))
      }
    }

    # check basic auth and attempt to sign in
    auth_header <- req[["HTTP_AUTHORIZATION"]]

    if ("basic" %in% method) {

      if (is.null(auth_header)) {
        if (identical(length(method), 1L)) {
          res$status <- 401L # unauthorized
          return(list(
            error = jsonlite::unbox("API key not provided in HTTP_AUTHORIZATION header")
          ))
        }

      } else {

        tryCatch({

          credentials_encoded <- strsplit(auth_header, " ")[[1]][2]
          credentials <- rawToChar(base64enc::base64decode(credentials_encoded))
          credentials <- strsplit(credentials, ":", fixed = TRUE)[[1]]

          if (is.null(polished_cookie)) {
            polished_cookie <- paste0("api-", uuid::UUIDgenerate())
            polished_cookie <- digest::digest(polished_cookie)
          } else if (grepl("p0.", polished_cookie, fixed = TRUE)) {
            # hash the cookie if sent unhashed

            polished_cookie <- digest::digest(polished_cookie)

          }



          r2 <- httr::POST(
            url = paste0(.polished$api_url, "/sign-in-email"),
            body = list(
              app_uid = .polished$app_uid,
              email = credentials[1],
              password = credentials[2],
              hashed_cookie = polished_cookie,
              is_invite_required = .polished$is_invite_required
            ),
            encode = "json",
            httr::authenticate(
              user = api_key,
              password = ""
            )
          )


          sc2 <- httr::status_code(r2)
          rc2 <- jsonlite::fromJSON(
            httr::content(r2, "text", encoding = "UTF-8")
          )
          if (!identical(sc2, 200L)) {
            res$status <- sc2
            stop(rc2$error, call. = FALSE)
          }


          r3 <- httr::GET(
            url = paste0(.polished$api_url, "/sessions"),
            query = list(
              hashed_cookie = polished_cookie,
              app_uid = .polished$app_uid,
              session_started = FALSE
            ),
            httr::authenticate(
              user = api_key,
              password = ""
            ),
            encode = "json"
          )

          sc3 <- httr::status_code(r3)
          rc3 <- jsonlite::fromJSON(
            httr::content(r3, "text", encoding = "UTF-8")
          )
          if (!identical(sc3, 200L)) {
            res$status <- sc3
            stop(rc3$error, call. = FALSE)
          } else {

            if (identical(length(rc3), 0L)) {
              res$status <- 401L
              stop("session not found", call. = FALSE)
            } else {
              req$polished_session <- rc3
            }

          }

        }, error = function(err) {

          warning("basic auth error")

          err_msg <<- conditionMessage(err)
          warning(err_msg)

          if (identical(res$status, 200L)) {
            res$status <- 500L
          }


          invisible(NULL)
        })

        if (!is.null(err_msg)) {
          return(list(
            error = jsonlite::unbox(err_msg)
          ))
        } else {
          plumber::forward()
        }
      }
    }


  }
}

#' add_auth_to_spec
#'
#' Add authentication to the openapi plumber spec so that you can use the swagger
#' documentation with the `auth_filter()`.
#'
#' @details This minimal API example \url{https://github.com/Tychobra/polished_example_apps/blob/master/11_plumber/api/00_start.R}
#' shows how you can add this function to your API.
#'
#' @param method the authentication method(s)
#'
#' @return a function to update the openapi spec.
#'
#' @export
#'
add_auth_to_spec <- function(method = c("basic", "cookie")) {

  method <- sort(method)
  if (identical(length(method), 1L)) {
    if (!(method %in% c("basic", "cookie"))) {
      stop("invalid `method` argument", call. = FALSE)
    }
  } else {
    if (!identical(method, c("basic", "cookie"))) {
      stop("invalid `method` argument", call. = FALSE)
    }
  }

  function(x) {
    schemes <- list()
    security <- list()
    if ("basic" %in% method) {
      schemes[["basicAuth"]] <- list(
        "type" = "http",
        "scheme" = "basic"
      )

      security <- append(security, list(list("basicAuth" = vector())))
    }

    if ("cookie" %in% method) {
      schemes[["cookieAuth"]] <- list(
        "type" = "apiKey",
        "in" = "cookie",
        "name" = "JSESSIONID"
      )

      security <- append(security, list(list("cookieAuth" = vector())))
    }

    # Adds the components element to openapi (specifies auth method)
    x[["components"]] <- list(
      securitySchemes = schemes
    )

    x[["security"]] <- security

    return(x)
  }
}
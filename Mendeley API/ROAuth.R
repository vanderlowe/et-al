# This supposedly takes care of the OAuth authorization, but I haven't been able to get it to work.
# However, this may not be necessary, as there appears to be ready-made code for python for Mendeley API

require(ROAuth)

reqURL <- "http://api.mendeley.com/oauth/request_token/"
accessURL <- "http://api.mendeley.com/oauth/access_token/"
authURL <- "http://api.mendeley.com/oauth/authorize/"

cKey <- Sys.getenv("MENDELEY_KEY") # Add the actual key to .Rprofile.site file as a environment variable
cSecret <- Sys.getenv("MENDELEY_SECRET") # Add the actual secret to .Rprofile.site file as a environment variable

testURL <- "http://api.mendeley.com/oapi/documents/search/author:keltner/"

credentials <- OAuthFactory$new(consumerKey=cKey,
                                consumerSecret=cSecret,
                                accessURL=accessURL,
                                authURL=authURL,
                                requestURL=reqURL,
                                needsVerifier = FALSE)
credentials$handshake()

## the GET isn’t strictly necessary as that’s the default
credentials$OAuthRequest(testURL, "GET")
## End(Not run)
require('RCurl')
require('RJSONIO')

# https://raw.github.com/alfredas/neo4j-R/master/neo4j.R
query <- function(querystring) {
  h = basicTextGatherer()
  curlPerform(url="http://localhost:7474/db/data/ext/CypherPlugin/graphdb/execute_query",
              postfields=paste('query',curlEscape(querystring), sep='='),
              writefunction = h$update,
              verbose = FALSE
  )
  
  result <- fromJSON(h$value())
  
  data <- data.frame(t(sapply(result$data, unlist)))
  #names(data) <- result.json$columns
  junk <- c("outgoing_relationships","traverse", "all_typed_relationships","property","self","properties","outgoing_typed_relationships","incoming_relationships","create_relationship","paged_traverse","all_relationships","incoming_typed_relationships")
  data <- data[,!(names(data) %in% junk)] 
  data
}

q <-"START j = node(*)
MATCH j-[:wrote]->b<-[:wrote]-c
WHERE j.type? = 'author'
RETURN j.name, c.name"
coauthors <- query(q)

g <- simplify(graph.data.frame(d = coauthors, directed = T))

plot(g,
     layout=layout.kamada.kawai,
     vertex.size = 3,
     vertex.label = V(g)$name,
     vertex.label.cex = .5,
     vertex.label.family = "sans",
     edge.arrow.size = .05
)

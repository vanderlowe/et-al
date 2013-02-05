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

q <-"START i = node(*)
MATCH i-[:wrote]->b<-[:wrote]-j
WHERE i.type? = 'author'
RETURN i.name, j.name"
coauthors <- query(q)
write.csv(coauthors, row.names = F)
g <- simplify(graph.data.frame(d = coauthors, directed = T))

plot(g,
     layout=layout.kamada.kawai,
     vertex.size = 3,
     vertex.label = V(g)$name,
     vertex.label.cex = .5,
     vertex.label.family = "sans",
     edge.arrow.size = .05
)

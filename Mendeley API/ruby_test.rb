# This is a "Hello worl" API test
# Mendeley gem for Ruby from
# https://github.com/rweald/mendeley

require "rubygems"
require "mendeley"
require "neography"

$neo = Neography::Rest.new
Mendeley.consumer_key = "3a3d8c0c3bf45bf99bf2c1b82c0768f605106c484"

class Author
	# An object to represent an author from Mendeley API.
	# Mendeley API only provides forename and surname fields.
	attr_accessor :name, :forename, :surname

	def initialize(mendeley_author)
		@forename = mendeley_author["forename"]
		@surname = mendeley_author["surname"]
		@name = [self.forename, self.surname].join(" ")
		self.save
	end # initialize

	def node
		Neography::Node.find("authors", "name", self.name)
	end	# node

	def save
		if self.node.nil?
	 		# New author; add to graph and authors index
	 		thisAuthor = Neography::Node.create(
	 			"name" => self.name, 
	 			"forename" => self.forename, 
	 			"surname" => self.surname, 
	 			"type" => "author")
	 		$neo.add_node_to_index("authors", "name", self.name, thisAuthor)
 		end # self.node.nil?
	end # save

	def write(article)
		Neography::Relationship.create(:wrote, self.node, article.node)
	end # write

end # Class Author

class Journal
	attr_accessor :name

	def initialize(journal_name)
		@name = journal_name
		self.save
	end # initialize

	def node
		Neography::Node.find("journals", "name", self.name)
	end # node

	def save
		if self.node.nil?
	 		thisJournal = Neography::Node.create(
	 			"name" => self.name,
	 			"type" => "journal")
	 		$neo.add_node_to_index("journals", "name", self.name, thisJournal)
 		end # self.node.nil?
	end # save

	def publish(article)
		Neography::Relationship.create(:published, self.node, article.node)
	end # publish
end # Class Journal

class Article
	attr_accessor :id, :journal, :title, :year

	def initialize(mendeley_article)
		@id = mendeley_article["uuid"]
		@year = mendeley_article["year"]
		@title = mendeley_article["title"]
		@journal = mendeley_article["publication_outlet"]
		self.save
	end # initialize

	def node
		Neography::Node.find("articles", "id", self.id)
	end # node

	def save
		if self.node.nil?
	 		thisArticle = Neography::Node.create(
	 			"title" => self.title,
	 			"year" => self.year,
	 			"type" => "article")
	 		$neo.add_node_to_index("articles", "id", self.id, thisArticle)
 		end # self.node.nil?
	end # save
end # CLass Article


# START SCRIPT

seedPeople = ["June Gruber", "Christopher Oveis", "Dacher Keltner", "Paul Ekman", "Laura Saslow", "Jonathan Haidt", "Sarah Algoe", "Simone Schnall"]

seedPeople.each {|seed_person|
	article_query = Mendeley::API::Documents.authored_by(seed_person)

	article_query["documents"].each {|article|
		thisArticle = Article.new(article)
		puts thisArticle.title

		Journal.new(thisArticle.journal).publish(thisArticle)

		article["authors"].each {|person|
			Author.new(person).write(thisArticle)
		}
	}
}

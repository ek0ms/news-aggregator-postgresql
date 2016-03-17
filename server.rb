require "sinatra"
require "pg"
require "pry"
require_relative "./app/models/article"

set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/articles' do
  @articles = db_connection { |conn| conn.exec("SELECT * FROM articles") }
  erb :index
end

get '/articles/new' do
  erb :submit
end

post '/articles/new' do
  description = params['description']
  title = params['title']
  url = params['url']

  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (title, URL, description) VALUES ($1,
     $2, $3)", [title, url, description])
  end

  redirect '/articles'
end

get '/' do
  redirect '/articles'
end

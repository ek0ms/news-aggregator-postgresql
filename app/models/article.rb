def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

class Article
  def initialize (data = {})
    @data = data
  end

  def title
    @data['title']
  end

  def url
    @data['url']
  end

  def description
    @data['description']
  end

  def self.all
    articles_array = []
    articles = db_connection { |conn| conn.exec("SELECT * FROM articles") }
    articles.each do |article|
      articles_array << Article.new(article)
    end
    articles_array
  end

  def errors
    @errors = []
    @data.each do |key, value|
      if value.empty? || value.nil?
        @errors << "Please completely fill out form"
        break
      end
    end
    @errors
  end

  def valid?
    @data.each do |key, value|
      if value.empty? || value.nil?
        return false
      else
        return true
      end
    end
  end
end

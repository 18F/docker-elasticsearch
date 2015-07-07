# spec/Dockerfile_spec.rb

require 'serverspec'
require 'docker'
require 'elasticsearch'

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.build_from_dir('.')

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, @image.id

  end
  describe "running it as a container" do
      before(:all) do
          id = `docker run -e "ES_USERNAME=username" -e "ES_PASSWORD=password" -d -p 9200:9200 #{@image.id}`.chomp
          @container = Docker::Container.get(id)
      end
  
      it "should accept connection to the default port" do
        sleep(10)
        client = Elasticsearch::Client.new host: 'http://username:password@localhost:9200', log: true
        client.index index: 'my-index', type: 'my-document', id: 1, body: { title: 'Test' }
        client.indices.refresh index: 'my-index'
        client.search index: 'my-index', body: { query: { match: { title: 'test' } } }
      end
  
      after(:all) do
          @container.kill
      end
  end
end

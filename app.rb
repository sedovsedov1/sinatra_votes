require 'sinatra'
require 'yaml/store'

CHOICES = {
	'HAM' => 'Гамбургер',
	'PIZ' => 'Пицца',
	'CUR' => 'Карри',
	'NOO' => 'Лапша'
}

get '/' do
	@title = 'Добро пожаловать в мой ресторан'
	erb :index
end

post '/cast' do                              # обработка post-запроса
	@title = 'Спасибо за ваш выбор'            # @title = заголовок страницы
	@vote = params['vote']                     # @vote = параметр, который пришел из формы
	@store = YAML::Store.new 'votes.yml'       # @store = хранилище Yaml
	@store.transaction do                      # проводим защищенную транзакцию к хранилище
		@store['votes'] ||= {}                   # 1) если хранилище пустое, то создаем его как пустой ассоциативный массив
		@store['votes'][@vote] ||= 0             # 2) если такого параметра нет, то присваиваем ему 0
		@store['votes'][@vote] += 1              # 3) если такой параметр есть, то присваиваем ему значение +1
	end                                        # конец защищенной транзкции
	erb :cast                                  # вызвать вьюху cast (ссылка на результат + инфо о сохранении выбора)
end

get '/results' do                                  # обработка "показ результатов"
	@title = 'Результаты:'                           # @title = заголовок страницы
	@store = YAML::Store.new 'votes.yml'             # @store = хранилище Yaml
	@votes = @store.transaction { @store['votes'] }  # @votes = ассоциативный массив всех записей  
	erb :results                                     # вызвать вьюху results (показать результаты выборов)
end
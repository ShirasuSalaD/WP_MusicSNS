require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before '/home' do
  if current_user.nil?
    redirect '/'
  end
end

get '/' do
  # 投稿の一覧表示機能が出来ているか (index.erb)
  erb:index
end

get '/signup' do
  # ユーザーの新規登録フォームの表示(sign_up.erb)
  erb:sign_up
end

get '/signin' do
  erb:sign_in
end

post '/signup' do
#  ユーザーの新規登録機能ができているか
#  画像のアップロードができているか
#  アップロードした画像URLを保存できているか
  user=User.create(name:params[:name],password:params[:password],password_confirmation:params[:password_confirmation])
  if user.persisted?
    session[:user]=user.id
  end
  redirect '/'
end

post '/signin' do
#  ユーザーのログイン機能ができているか(session)
#  /topと/homeはログインしていない場合、/sing_upへリダイレクトするようになっているか
#  helperを使ってユーザーのログイン状態の管理をしているか
  user=User.find_by(name:params[:name])
  if user&&user.authenticate(params[:password])
    session[:user]=user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user]=nil
  redirect '/'
end

get '/search' do
  # 検索フォームと検索一覧の表示(search.erb)
  uri = URI("https://itunes.apple.com/search?")
  uri.query = URI.encode_www_form({
    method: "GET",
    country: "JP",
    media: "music",
    term: params[:term]
  })
  res = Net::HTTP.get_response(uri)
  json = JSON.parse(res.body)
  @tracks = json["artistName"]["trackViewUrl"]
  erb :search
end

post '/search' do
  # iTunesAPIを使った検索・jsonの操作
  redirect '/'
end

post '/new' do
#  投稿の新規作成機能が出来ているか
end

get '/home' do
#  ユーザーに紐づいた投稿が表示されているか(home.erb)
  erb :home
end

get '/edit/:id' do
#  投稿の編集フォームが表示できているか(edit.erb)
  erb :edit
end

post '/update/:id' do
#  投稿の更新機能が出来ているか
end

get '/delete/:id' do
#  投稿の削除機能が出来ているか
end




post '/tasks' do
  date=params[:due_date].split('-')#展開されたくないからシングルクオーテーション
  list=List.find(params[:list])
  if(Date.valid_date?(date[0].to_i,date[1].to_i,date[2].to_i))
    current_user.tasks.create(title:params[:title],due_date:Date.parse(params[:due_date]),list_id:list.id)
    redirect '/'
  else
    redirect '/tasks/new'
  end
end

get '/tasks/new' do
  erb:new
end

post '/tasks/:id/done'do
  task=Task.find(params[:id])
  task.completed=true
  task.save
  redirect '/'
end

get '/tasks/:id/star'do
  task=Task.find(params[:id])
  task.star=!task.star
  task.save
  redirect '/'
end

post '/tasks/:id/delete'do
  task=Task.find(params[:id])
  task.destroy
  redirect '/'
end

get '/tasks/:id/edit' do
  @task=Task.find(params[:id])
  erb:edit
end

post '/tasks/:id' do #編集
  task=Task.find(params[:id])
  list=List.find(params[:list])
  date=params[:due_date].split('-')#展開されたくないからシングルクオーテーション
  if(Date.valid_date?(date[0].to_i,date[1].to_i,date[2].to_i))
    task.title=CGI.escapeHTML(params[:title])
    task.due_date=params[:due_date]
    task.list_id=list.id
    task.save
    redirect '/'
  else
    redirect "tasks/#{task.id}/edit"
  end
end

get '/tasks/over' do
  @lists=List.all
  @tasks=current_user.tasks.due_over
  erb:index
end

get '/tasks/done' do
  @lists=List.all
  @tasks=current_user.tasks.where(completed:true)
  erb:index
end

get '/tasks/star' do
  @lists=List.all
  @tasks=current_user.tasks.where(star:true)
  erb:index
end
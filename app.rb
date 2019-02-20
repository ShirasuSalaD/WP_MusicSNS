require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'open-uri'
require 'net/http'

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
  user=User.create(
    name:params[:name],
    password:params[:password],
    password_confirmation:params[:password_confirmation]
    )
  if user.persisted?
    session[:user]=user.id
    redirect '/'
  else
    redirect '/signup'
  end
end

post '/signin' do
#  ユーザーのログイン機能ができているか(session)
#  /topと/homeはログインしていない場合、/sing_upへリダイレクトするようになっているか
#  helperを使ってユーザーのログイン状態の管理をしているか
  user=User.find_by(
    name:params[:name]
    )
  if user&&user.authenticate(params[:password])
    session[:user]=user.id
    redirect '/'
  else
    redirect '/signin'
  end
end

get '/signout' do
  session[:user]=nil
  redirect '/'
end

get '/search' do
  # 検索フォームと検索一覧の表示(search.erb)
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({
    method: "GET",
    country: "JP",
    media: "music",
    limit: 30,
    term: params[:term]
  })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  @musics = returned_json['results']
  erb :search
end

# post '/search' do
#   # iTunesAPIを使った検索・jsonの操作
#   redirect '/'
# end

# post '/new' do
# #  投稿の新規作成機能が出来ているか
# end

# get '/home' do
# #  ユーザーに紐づいた投稿が表示されているか(home.erb)
#   erb :home
# end

# get '/edit/:id' do
# #  投稿の編集フォームが表示できているか(edit.erb)
#   erb :edit
# end

# post '/update/:id' do
# #  投稿の更新機能が出来ているか
# end

# get '/delete/:id' do
# #  投稿の削除機能が出来ているか
# end
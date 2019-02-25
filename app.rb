require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'open-uri'
require 'net/http'
require 'json'
require 'rubygems'
require 'sinatra/json'

Dotenv.load

# # loggerの導入
# require 'logger'

# logger = Logger.new('sinatra.log')

# post '/new' do
#   http_headers = request.env.select { |k, v| k.start_with?('HTTP_') }
#   logger.info http_headers
#   logger.info params['key1']
# end


enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before '/home' do
    if current_user.nil?
        redirect '/signup'
    end
end

get '/' do
  # 投稿の一覧表示機能が出来ているか (index.erb)
  # if !@posts.nil?
    @posts = Post.all.order('updated_at DESC')
  # end
  erb:index
end


get '/signup' do
  # ユーザーの新規登録フォームの表示(sign_up.erb):DONE
  erb:sign_up
end

post '/signup' do
  #  ユーザーの新規登録機能ができているか:DONE
  #  画像のアップロードができているか
  #  アップロードした画像URLを保存できているか

  # if !params[:icon_url].nil?
  @tempfile = params[:icon_url][:tempfile] # <-ここにアップロードしたファイルの一時ファイルができる
  uploads ={}
  uploads[:fish] = Cloudinary::Uploader.upload(@tempfile.path)
  @url = uploads[:fish]['url']
  # end

  # if params[:file]
  #   tempfile = params[:file][:tempfile]
  #   filename = params[:file][:filename]
  #   uploadfile =  Cloudinary::Uploader.upload(tempfile.path)
  #   new_user = User.last
  #   new_user.update_attribute(:icon_url, uploadfile['url'])
  # end

  user=User.create(
  name: params[:name],
  password: params[:password],
  password_confirmation: params[:password_confirmation],
  icon_url: @url
  )

  if user.persisted?
    session[:user]=user.id
    redirect '/home'
  else
    # @error_message = ""
    redirect '/signup'
  end
end


get '/signin' do
  erb:sign_in
end

post '/signin' do
#  ユーザーのログイン機能ができているか(session):DONE
#  /topと/homeはログインしていない場合、/sing_upへリダイレクトするようになっているか
#  helperを使ってユーザーのログイン状態の管理をしているか:DONE
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    redirect '/search'
  end
  redirect '/'
end


get '/signout' do
  session[:user]=nil
  redirect '/'
end

get '/search' do
  # 検索フォームと検索一覧の表示(search.erb)
  erb :search
end

post '/search' do
  # iTunesAPIを使った検索・jsonの操作
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

post '/new' do
  #投稿の新規作成機能が出来ているか
  # unless current_user.posts.nil?
  current_user.posts.create(
    artist: params[:artist],
    album_title: params[:album_title],
    track_title: params[:track_title],
    track_img_url: params[:track_img_url],
    sample_url: params[:sample_url],
    comment: params[:comment],
    user_id: current_user.id
  )
  redirect '/home'
  # end
end

get '/home' do
#  ユーザーに紐づいた投稿が表示されているか(home.erb)
  # unless @user_posts.nil?
    @user_posts = Post.where(user_id: current_user).order('updated_at DESC')
  # end
  erb :home
end

get '/edit/:id' do
#  投稿の編集フォームが表示できているか(edit.erb)
  @user_posts =Post.find(params[:id])
  erb :edit
end

post '/edit/:id' do
  post = Post.find(params[:id])
  post.comment = CGI.escape_html(params[:comment])
  post.save
  redirect '/home'
end

post '/delete/:id' do
#  投稿の削除機能が出来ているか
  post = Post.find(params[:id])
  post.destroy
  redirect '/home'
end
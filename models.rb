require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password validations: true
  validates :name,  presence:true,  format:{with:/\A\w+\z/}
  validates :password,  length:{in:5..10}
  has_many :userposts
end
# セキュアなパスワードの実装は、has_secure_passwordというメソッドを呼び出すだけでほとんど終わってしまいます。
# ・セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存できるようになる。
# 2つのペアの仮想的な属性 (passwordとpassword_confirmation) が使えるようになる。また、存在性と値が一致するかどうかのバリデーションも追加される
# authenticateメソッドが使えるようになる (引数の文字列がパスワードと一致するとUserオブジェクトを、間違っているとfalseを返すメソッド)
#文字列の先頭\A 　単語を構成する文字の繰り返し\w+　文字列の末尾\z
#つまり文字の中に空白や改行とか無いよねってことができる \Zは末尾の改行を無視してしまうので小文字
#↑もるもるつおい

# class Userposts < ActiveRecord::Base
#   scope :due_over, -> {where('due_date<?',Date.today).where(completed:[nil,false])}
#   scope :had_by, -> (user){where(user_id:user.id)}
#   belongs_to :author
#   belongs_to :user_id
#   validates :comment ,presence:true
#   def remained_date
#     return (due_date-Date.today).to_i
#   end
# end

# class List<ActiveRecord::Base
#   has_many :tasks
# end
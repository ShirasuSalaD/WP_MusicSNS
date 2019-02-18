class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.references :user
      t.string :title
      t.timestamp null: false
    end
  end
end
#データベースの2つのテーブルを繋ぐidは外部キー(foreign key)と呼びます
#referencesでは、自動的にインデックスと外部キー参照付きのuser_idカラムが追加され、関連付けする下準備をしてくれます。
class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :artist
      t.string :album_title
      t.string :track_title
      t.string :track_img_url
      t.string :sample_url
      t.text :comment
      t.integer :user_id
      t.timestamps null: false
    end
  end
end

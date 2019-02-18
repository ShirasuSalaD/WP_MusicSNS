class AddListToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks,:list_id,:integer,default:1
  end
end

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :post_body
      t.integer :user_id
      t.datetime :when_posted, :null => false, :default => Time.now
    end
  end
end

class CreateComments < ActiveRecord::Migration
  def self.up
    create_table "comments", :force => true do |t|      
      t.column "comment", :text, :null => false      
      t.column "commentable_id", :integer, :null => false
      t.column "commentable_type", :string, :limit => 50, :null => false
      t.column "author_ip_address", :string, :null => false
      t.column "author_name", :string, :limit => 80, :null => false
      t.column "author_email", :string, :null => false
      t.column "author_website", :string, :default => '', :null => false
      t.timestamps
    end    
  end

  def self.down
    drop_table :comments
  end
end
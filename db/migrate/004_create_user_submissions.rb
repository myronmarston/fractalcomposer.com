require 'migration_helper'
class CreateUserSubmissions < ActiveRecord::Migration
  extend MigrationHelper
  
  def self.up
    create_table :user_submissions do |t|
      t.column :name, :string, :null => false
      t.column :email, :string, :null => false
      t.column :website, :string, :null => true
      t.column :title, :string, :null => false
      t.column :description, :string, :null => true
      t.column :generated_piece_id, :integer, :null => false
      t.timestamps
    end
    
    foreign_key(:user_submissions, :generated_piece_id, :generated_pieces)
  end

  def self.down
    drop_table :user_submissions
  end
end

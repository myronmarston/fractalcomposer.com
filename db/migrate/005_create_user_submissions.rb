require 'migration_helper'
#require File.dirname(__FILE__) + '/../../app/models/user_submission'
class CreateUserSubmissions < ActiveRecord::Migration
  extend MigrationHelper
  
  def self.up
    ActiveRecord::Base.create_ratings_table :with_rater => true
          
    create_table :user_submissions do |t|
      t.column :name, :string, :null => false
      t.column :email, :string, :null => false
      t.column :display_email, :boolean, :null => false, :default => false
      t.column :comment_notification, :boolean, :null => false, :default => true
      t.column :website, :string, :null => true
      t.column :title, :string, :null => false
      t.column :description, :string, :null => true            
      t.column :generated_piece_id, :integer, :null => false
      t.column :processing_began, :datetime, :null => true
      t.column :processing_completed, :datetime, :null => true
      t.column :piece_mp3_file, :string, :null => true
      t.column :piece_pdf_file, :string, :null => true
      t.column :piece_image_file, :string, :null => true
      t.column :germ_mp3_file, :string, :null => true
      t.column :germ_image_file, :string, :null => true                  
      
      ActiveRecord::Base.generate_ratings_columns t
      t.timestamps
    end
    
    foreign_key(:user_submissions, :generated_piece_id, :generated_pieces)
  end

  def self.down
    drop_table :user_submissions   
    ActiveRecord::Base.drop_ratings_table
  end
end

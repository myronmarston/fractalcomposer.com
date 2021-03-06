require 'migration_helper'

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
      t.column :comment_count, :integer, :null => false, :default => 0
      t.column :total_page_views, :integer, :null => false, :default => 0
      t.column :unique_page_views, :integer, :null => false, :default => 0
      
      ActiveRecord::Base.generate_ratings_columns t
      t.timestamps
    end
    
    create_table :user_submission_unique_page_views do |t|
      t.column :user_submission_id, :integer, :null => false
      t.column :ip_address, :string, :limit => 20, :null => false
      t.timestamps
    end
    
    foreign_key(:user_submissions, :generated_piece_id, :generated_pieces)
    foreign_key(:user_submission_unique_page_views, :user_submission_id, :user_submissions, 'fk_user_submission_unique_page_views')
  end

  def self.down
    drop_table :user_submission_unique_page_views
    drop_table :user_submissions   
    ActiveRecord::Base.drop_ratings_table
  end
end

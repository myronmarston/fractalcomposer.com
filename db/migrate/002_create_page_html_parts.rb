class CreatePageHtmlParts < ActiveRecord::Migration
  def self.up
    create_table :page_html_parts do |t|
      t.column :name, :string, :null => false
      t.column :content, :text, :null => true
      t.column :content_html, :text, :null => true      
      t.column :created_at, :datetime, :null => true
      t.column :updated_at, :datetime, :null => true    
    end
    
    execute "ALTER TABLE page_html_parts CHANGE COLUMN content content MEDIUMTEXT"
    execute "ALTER TABLE page_html_parts CHANGE COLUMN content_html content_html MEDIUMTEXT"
  end

  def self.down
    drop_table :page_html_parts
  end
end

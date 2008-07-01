class CreateGeneratedPieces < ActiveRecord::Migration
  def self.up
    create_table :generated_pieces do |t|
      t.column :user_ip_address, :string, :null => false
      t.column :fractal_piece, :text, :null => false
      t.column :generated_midi_file, :string, :null => false
      t.column :generated_guido_file, :string, :null => false
      t.timestamps
    end
    
    execute "ALTER TABLE generated_pieces CHANGE COLUMN fractal_piece fractal_piece MEDIUMTEXT"
  end

  def self.down
    drop_table :generated_pieces
  end
end

class CreateIpAddresses < ActiveRecord::Migration
  def self.up
    create_table :ip_addresses do |t|
      t.column :ip_address, :string, :null => false 
      t.timestamps
    end
    
    add_index(:ip_addresses, :ip_address)
  end

  def self.down
    drop_table :ip_addresses
  end
end

module MigrationHelper
  
  def foreign_key(from_table, from_column, to_table, constraint_name = nil)
    constraint_name ||= "fk_#{from_table}_#{from_column}_to_#{to_table}"
    execute "ALTER TABLE #{from_table} ADD CONSTRAINT #{constraint_name} FOREIGN KEY (#{from_column}) REFERENCES #{to_table}(id)"
  end
  
end
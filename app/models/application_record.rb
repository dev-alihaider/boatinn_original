class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.reset_autoincrement!
    with = self.count + 1
    self.connection.execute("ALTER SEQUENCE #{self.table_name}_id_seq RESTART WITH #{with}")
  end

end

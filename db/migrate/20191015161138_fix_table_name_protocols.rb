class FixTableNameProtocols < ActiveRecord::Migration[6.0]
  def change
    rename_table("procotols", "protocols")
  end
end

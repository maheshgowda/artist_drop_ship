class AddFieldToArtists < ActiveRecord::Migration
  def change
    add_column :spree_artists, :uin, :string
  end
end

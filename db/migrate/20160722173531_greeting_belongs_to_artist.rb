class GreetingBelongsToArtist < ActiveRecord::Migration
  def change
    add_column :spree_greetings, :artist_id, :integer
    add_index :spree_greetings, :artist_id
  end
end

class CreateSpreeArtistVariants < ActiveRecord::Migration
  def change
    create_table :spree_artist_variants do |t|
      t.belongs_to :artist, index: true
      t.belongs_to :variant, index: true
      t.decimal :cost

      t.timestamps
    end
    
    Spree::Greeting.where.not(artist_id: nil).each do |greeting|
      greeting.add_artist! greeting.artist_id
    end
    remove_column :spree_greetings, :artist_id
  end
end

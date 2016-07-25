class CreateSpreeArtistVariants < ActiveRecord::Migration
  def change
    create_table :spree_artist_variants do |t|
      t.belongs_to :artist, index: true
      t.belongs_to :variant, index: true
      t.decimal :cost

      t.timestamps
    end
    
    Spree::Artist.where.not(artist_id: nil).each do |artist|
      artist.add_artist! artist.artist_id
    end
    remove_column :spree_artists, :artist_id
  end
end

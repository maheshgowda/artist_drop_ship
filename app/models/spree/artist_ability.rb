module Spree
  class ArtistAbility
    include CanCan::Ability

    def initialize(user)
      user ||= Spree.user_class.new

      if user.artist
        # TODO: Want this to be inline like:
        # can [:admin, :read, :stock], Spree::Greeting, artists: { id: user.artist_id }
        # can [:admin, :read, :stock], Spree::Greeting, artist_ids: user.artist_id
        can [:admin, :read, :stock], Spree::Greeting do |greeting|
          greeting.artist_ids.include?(user.artist_id)
        end
        can [:admin, :index], Spree::Greeting
        can [:admin, :manage, :read, :ready, :ship], Spree::Shipment, order: { state: 'complete' }, stock_location: { artist_id: user.artist_id }
        can [:admin, :create, :update], :stock_items
        can [:admin, :manage], Spree::StockItem, stock_location_id: user.artist.stock_locations.pluck(:id)
        can [:admin, :manage], Spree::StockLocation, artist_id: user.artist_id
        can :create, Spree::StockLocation
        can [:admin, :manage], Spree::StockMovement, stock_item: { stock_location_id: user.artist.stock_locations.pluck(:id) }
        can :create, Spree::StockMovement
        can [:admin, :update], Spree::Artist, id: user.artist_id
      end

    end
  end
end

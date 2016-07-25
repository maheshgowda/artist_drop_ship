FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_artist_drop_ship/factories'
  
  factory :order_for_artist_drop_ship, parent: :order do
    bill_address
    ship_address

    ignore do
      line_items_count 5
    end

    after(:create) do |order, evaluator|
      artist = create(:artist)
      greeting = create(:greeting)
      greeting.add_artist! artist
      # greeting.stock_items.where(variant_id: greeting.master.id).first.adjust_count_on_hand(10)

      greeting_2 = create(:greeting)
      greeting_2.add_artist! create(:artist)

      create_list(:line_item, evaluator.line_items_count,
        order: order,
        variant: greeting_2.master
      )
      order.line_items.reload

      create(:shipment, order: order, stock_location: artist.stock_locations.first)
      order.shipments.reload

      order.update!
    end

    factory :completed_order_for_artist_drop_ship_with_totals do
      state 'complete'

      after(:create) do |order|
        order.refresh_shipment_rates
        order.update_column(:completed_at, Time.now)
      end

      factory :order_ready_for_artist_drop_ship do
        payment_state 'paid'
        shipment_state 'ready'

        after(:create) do |order|
          create(:payment, amount: order.total, order: order, state: 'completed')
          order.shipments.each do |shipment|
            shipment.inventory_units.each { |u| u.update_column('state', 'on_hand') }
            shipment.update_column('state', 'ready')
          end
          order.reload
        end

        factory :shipped_order_for_artist_drop_ship do
          after(:create) do |order|
            order.shipments.each do |shipment|
              shipment.inventory_units.each { |u| u.update_column('state', 'shipped') }
              shipment.update_column('state', 'shipped')
            end
            order.reload
          end
        end
      end
    end
    
    
    
  end

  factory :artist, :class => Spree::Artist do
    sequence(:name) { |i| "Big Store #{i}" }
    email { FFaker::Internet.email }
    url "http://example.com"
    address
    # Creating a stock location with a factory instead of letting the model handle it
    # so that we can run tests with backorderable defaulting to true.
    before :create do |artist|
      artist.stock_locations << build(:stock_location, name: artist.name, artist: artist)
    end

    factory :artist_with_commission do
      commission_flat_rate 0.5
      commission_percentage 10
    end
  end

  factory :artist_user, parent: :user do
    artist
  end

  factory :variant_with_artist, parent: :variant do
    after :create do |variant|
      variant.greeting.add_artist! create(:artist)
    end
  end

  
end

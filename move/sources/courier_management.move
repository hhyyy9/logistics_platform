module logistics_platform::courier_management {
    use std::string::String;
    use aptos_std::table::{Self, Table};
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::timestamp;
    use std::signer;

    friend logistics_platform::core;

    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_REGISTERED: u64 = 8;
    const E_INVALID_RATING: u64 = 9;
    const E_UNAUTHORIZED: u64 = 6;
    const E_COURIER_DEACTIVATED: u64 = 22;
    const E_ALREADY_RATED: u64 = 25;


    struct Courier has store {
        address: address,
        email: String,
        rating: u64,
        total_ratings: u64,
        completed_orders: u64,
        is_active: bool,
    }

    struct CourierStore has key {
        couriers: Table<address, Courier>,
        courier_updated_events: EventHandle<CourierUpdatedEvent>,
        courier_deactivated_events: EventHandle<CourierDeactivatedEvent>,
        rated_orders: Table<u64, bool>, // Track rated orders
    }

    #[event]
    struct CourierUpdatedEvent has drop, store {
        courier_address: address,
        new_email: String,
        timestamp: u64,
    }

    #[event]
    struct CourierDeactivatedEvent has drop, store {
        courier_address: address,
        timestamp: u64,
    }

    public(friend) fun initialize(admin: &signer) {
        move_to(admin, CourierStore {
            couriers: table::new(),
            courier_updated_events: account::new_event_handle<CourierUpdatedEvent>(admin),
            courier_deactivated_events: account::new_event_handle<CourierDeactivatedEvent>(admin),
            rated_orders: table::new(), // Initialize the rated_orders table
        });
    }

    /// Register a new courier
    public entry fun register_courier(courier: &signer, email: String) acquires CourierStore {
        let courier_store = borrow_global_mut<CourierStore>(@logistics_platform);
        let courier_address = signer::address_of(courier);
        
        assert!(!table::contains(&courier_store.couriers, courier_address), E_ALREADY_REGISTERED);
        
        let new_courier = Courier {
            address: courier_address,
            email,
            rating: 5 * 100, // 5 stars, using 100 as multiplier for precision
            total_ratings: 1,
            completed_orders: 0,
            is_active: true,
        };
        
        table::add(&mut courier_store.couriers, courier_address, new_courier);
    }

    /// Update courier info
    public entry fun update_courier_info(courier: &signer, new_email: String) acquires CourierStore {
        let courier_store = borrow_global_mut<CourierStore>(@logistics_platform);
        let courier_address = signer::address_of(courier);
        
        assert!(table::contains(&courier_store.couriers, courier_address), E_UNAUTHORIZED);
        let courier_info = table::borrow_mut(&mut courier_store.couriers, courier_address);
        assert!(courier_info.is_active, E_COURIER_DEACTIVATED);
        
        if (courier_info.email != new_email) {
            courier_info.email = new_email;

            event::emit_event(&mut courier_store.courier_updated_events, CourierUpdatedEvent {
                courier_address,
                new_email,
                timestamp: timestamp::now_seconds(),
            });
        }
    }

    public entry fun deactivate_courier(admin: &signer, courier_address: address) acquires CourierStore {
        assert!(signer::address_of(admin) == @logistics_platform, E_UNAUTHORIZED);
        
        let courier_store = borrow_global_mut<CourierStore>(@logistics_platform);
        assert!(table::contains(&courier_store.couriers, courier_address), E_UNAUTHORIZED);
        
        let courier_info = table::borrow_mut(&mut courier_store.couriers, courier_address);
        courier_info.is_active = false;

        event::emit_event(&mut courier_store.courier_deactivated_events, CourierDeactivatedEvent {
            courier_address,
            timestamp: timestamp::now_seconds(),
        });
    }

    /// Assert that the courier is active
    public(friend) fun assert_courier_active(courier_address: address) acquires CourierStore {
        let courier_store = borrow_global<CourierStore>(@logistics_platform);
        assert!(table::contains(&courier_store.couriers, courier_address), E_UNAUTHORIZED);
        let courier_info = table::borrow(&courier_store.couriers, courier_address);
        assert!(courier_info.is_active, E_COURIER_DEACTIVATED);
    }

    /// Get courier stats
    public(friend) fun get_courier_stats(courier_address: address): (u64, u64) acquires CourierStore {
        let courier_store = borrow_global<CourierStore>(@logistics_platform);
        let courier = table::borrow(&courier_store.couriers, courier_address);
        (courier.rating / courier.total_ratings, courier.completed_orders)
    }

    /// Update completed orders
    public(friend) fun update_completed_orders(courier_address: address) acquires CourierStore {
        let courier_store = borrow_global_mut<CourierStore>(@logistics_platform);
        let courier = table::borrow_mut(&mut courier_store.couriers, courier_address);
        courier.completed_orders = courier.completed_orders + 1;
    }

    /// Rate a courier
    public(friend) fun rate_courier(order_id: u64, courier_address: address, rating: u8) acquires CourierStore {
        assert!(rating >= 1 && rating <= 5, E_INVALID_RATING);
        
        let courier_store = borrow_global_mut<CourierStore>(@logistics_platform);
        // Check if the order has already been rated
        assert!(!table::contains(&courier_store.rated_orders, order_id), E_ALREADY_RATED);
    
        let courier = table::borrow_mut(&mut courier_store.couriers, courier_address);
        
        // Update courier's overall rating
        courier.rating = courier.rating + ((rating as u64) * 100);
        courier.total_ratings = courier.total_ratings + 1;

        // Mark the order as rated
        table::add(&mut courier_store.rated_orders, order_id, true);
    }
}
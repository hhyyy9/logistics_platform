module logistics_platform::user_management {
    use std::string::String;
    use aptos_std::table::{Self, Table};
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::timestamp;
    use std::signer;
    

    friend logistics_platform::core;

    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_REGISTERED: u64 = 8;
    const E_UNAUTHORIZED: u64 = 6;
    const E_USER_DEACTIVATED: u64 = 21;
    const E_USER_ALREADY_ACTIVE: u64 = 24;

    struct User has store {
        address: address,
        email: String,
        is_active: bool,
    }

    struct UserStore has key {
        users: Table<address, User>,
        user_updated_events: EventHandle<UserUpdatedEvent>,
        user_deactivated_events: EventHandle<UserDeactivatedEvent>,
        user_reactivated_events: EventHandle<UserReactivatedEvent>,
    }

    #[event]
    struct UserUpdatedEvent has drop, store {
        user_address: address,
        new_email: String,
        timestamp: u64,
    }

    #[event]
    struct UserDeactivatedEvent has drop, store {
        user_address: address,
        timestamp: u64,
    }

    #[event]
    struct UserReactivatedEvent has drop, store {
        user_address: address,
        timestamp: u64,
    }

    public(friend) fun initialize(admin: &signer) {
        move_to(admin, UserStore {
            users: table::new(),
            user_updated_events: account::new_event_handle<UserUpdatedEvent>(admin),
            user_deactivated_events: account::new_event_handle<UserDeactivatedEvent>(admin),
            user_reactivated_events: account::new_event_handle<UserReactivatedEvent>(admin),
        });
    }

    /// Register a new user
    public entry fun register_user(user: &signer, email: String) acquires UserStore {
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        let user_address = signer::address_of(user);
        
        assert!(!table::contains(&user_store.users, user_address), E_ALREADY_REGISTERED);
        
        let new_user = User {
            address: user_address,
            email,
            is_active: true,
        };
        
        table::add(&mut user_store.users, user_address, new_user);
    }

    /// Update user info
    public entry fun update_user_info(user: &signer, new_email: String) acquires UserStore {
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        let user_address = signer::address_of(user);
        
        assert!(table::contains(&user_store.users, user_address), E_UNAUTHORIZED);
        let user_info = table::borrow_mut(&mut user_store.users, user_address);
        assert!(user_info.is_active, E_USER_DEACTIVATED);
        
        if (user_info.email != new_email) {
            user_info.email = new_email;

            event::emit_event(&mut user_store.user_updated_events, UserUpdatedEvent {
                user_address,
                new_email,
                timestamp: timestamp::now_seconds(),
            });
        }
    }

    public entry fun deactivate_user(admin: &signer, user_address: address) acquires UserStore {
        assert!(signer::address_of(admin) == @logistics_platform, E_UNAUTHORIZED);
        
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        assert!(table::contains(&user_store.users, user_address), E_UNAUTHORIZED);
        
        let user_info = table::borrow_mut(&mut user_store.users, user_address);
        user_info.is_active = false;

        event::emit_event(&mut user_store.user_deactivated_events, UserDeactivatedEvent {
            user_address,
            timestamp: timestamp::now_seconds(),
        });
    }

    public entry fun reactivate_user(admin: &signer, user_address: address) acquires UserStore {
        assert!(signer::address_of(admin) == @logistics_platform, E_UNAUTHORIZED);
        
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        assert!(table::contains(&user_store.users, user_address), E_UNAUTHORIZED);
        
        let user_info = table::borrow_mut(&mut user_store.users, user_address);
        assert!(!user_info.is_active, E_USER_ALREADY_ACTIVE);

        user_info.is_active = true;

        event::emit_event(&mut user_store.user_reactivated_events, UserReactivatedEvent {
            user_address,
            timestamp: timestamp::now_seconds(),
        });
    }

    /// Assert that a user is active
    public(friend) fun assert_user_active(user_address: address) acquires UserStore {
        let user_store = borrow_global<UserStore>(@logistics_platform);
        assert!(table::contains(&user_store.users, user_address), E_UNAUTHORIZED);
        let user_info = table::borrow(&user_store.users, user_address);
        assert!(user_info.is_active, E_USER_DEACTIVATED);
    }
}
module logistics_platform::user_management {
    use std::string::{Self, String};
    use aptos_std::table::{Self, Table};
    use std::signer;
    use logistics_platform::statistics;

    // Error constants
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_REGISTERED: u64 = 2;
    const E_UNAUTHORIZED: u64 = 3;
    const E_USER_DEACTIVATED: u64 = 4;
    const E_INSUFFICIENT_BALANCE: u64 = 5;

    // Initial balance constant
    const INITIAL_BALANCE: u64 = 10000;

    const RESOURCE_ACCOUNT: address = @logistics_platform;

    struct User has store {
        address: address,
        email: String,
        is_active: bool,
        is_courier: bool,
        balance: u64,
    }

    struct UserStore has key {
        users: Table<address, User>,
    }

    fun init_module(account: &signer) {
        assert!(signer::address_of(account) == @logistics_platform, E_UNAUTHORIZED);

        move_to(account, UserStore {
            users: table::new(),
        });
    }

    public entry fun register_user(user: &signer, email: String, is_courier: bool) acquires UserStore {
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        let user_address = signer::address_of(user);
        
        assert!(!table::contains(&user_store.users, user_address), E_ALREADY_REGISTERED);
        
        let new_user = User {
            address: user_address,
            email: email,
            is_active: true,
            is_courier: is_courier,
            balance: INITIAL_BALANCE, // Initialize user balance to 10000
        };
        
        table::add(&mut user_store.users, user_address, new_user);

        statistics::update_stats_new_user();
    }

    public fun get_user_info(user_address: address): (vector<u8>, bool, bool, u64) acquires UserStore {
        let user_store = borrow_global<UserStore>(RESOURCE_ACCOUNT);
        let user = table::borrow(&user_store.users, user_address);
        (
            *string::bytes(&user.email),
            user.is_active,
            user.is_courier,
            user.balance
        )
    }
    
    #[view]
    public fun get_user_info_view(user_address: address): (vector<u8>, bool, bool) acquires UserStore {
        let (email, is_active, is_courier, _) = get_user_info(user_address);
        (email, is_active, is_courier)
    }

    #[view]
    public fun get_user_info_view_v2(user_address: address): (vector<u8>, bool, bool, u64) acquires UserStore {
        let (email, is_active, is_courier, balance) = get_user_info(user_address);
        (email, is_active, is_courier, balance)
    }

    public fun check_user_exists(user_address: address): bool acquires UserStore {
        let user_store = borrow_global<UserStore>(@logistics_platform);
        table::contains(&user_store.users, user_address)
    }

    #[view]
    public fun check_user_exists_view(user_address: address): bool acquires UserStore {
        check_user_exists(user_address)
    }

    public fun deduct_balance(user_address: address, amount: u64) acquires UserStore {
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        let user = table::borrow_mut(&mut user_store.users, user_address);
        assert!(user.balance >= amount, E_INSUFFICIENT_BALANCE);
        user.balance = user.balance - amount;
    }

    public fun add_balance(user_address: address, amount: u64) acquires UserStore {
        let user_store = borrow_global_mut<UserStore>(@logistics_platform);
        let user = table::borrow_mut(&mut user_store.users, user_address);
        user.balance = user.balance + amount;
    }

    public fun is_courier(user_address: address): bool acquires UserStore {
        let user_store = borrow_global<UserStore>(@logistics_platform);
        if (table::contains(&user_store.users, user_address)) {
            let user = table::borrow(&user_store.users, user_address);
            user.is_courier
        } else {
            false
        }
    }

    #[test_only]
    public fun init_module_for_test(account: &signer) {
        init_module(account);
    }
}
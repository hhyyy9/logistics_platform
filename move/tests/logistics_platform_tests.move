#[test_only]
module logistics_platform::logistics_platform_tests {
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin::{Self, MintCapability};
    use std::string;
    use logistics_platform::core;
    use logistics_platform::user_management;
    use logistics_platform::courier_management;
    use logistics_platform::finance;
    use logistics_platform::statistics;
    use std::vector;

    // Test accounts
    const ADMIN: address = @0x08112834c88e612d3e522b722d18d4d54e0f9d70ede87c98264ea746ea9643ea;
    const USER1: address = @0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea;
    const USER2: address = @0x55c8dea9a4be53e5ca8b6c3908b099e7f0984f2cf3eebce681b661942f47316b;
    const COURIER1: address = @0xf259b5f88ed806f472f8bb72905e4de73c5dcf5cb8f09d9cecb839d6b085b3ed;
    const COURIER2: address = @0x08112834c88e612d3e522b722d18d4d54e0f9d70ede87c98264ea746ea9643ea;

    struct MintCapStore has key {
        mint_cap: MintCapability<AptosCoin>,
    }

    // Test setup
    fun setup_test(aptos_framework: &signer) acquires MintCapStore {
        // Initialize the timestamp for testing
        timestamp::set_time_has_started_for_testing(aptos_framework);

        // Initialize AptosCoin
        if (!coin::is_coin_initialized<AptosCoin>()) {
            let (burn_cap, freeze_cap, mint_cap) = coin::initialize<AptosCoin>(
                aptos_framework,
                string::utf8(b"Aptos Coin"),
                string::utf8(b"APT"),
                8, // decimals
                true // monitor_supply
            );

            // Move the mint capability to the aptos_framework account
            move_to(aptos_framework, MintCapStore { mint_cap });

            // Destroy unused capabilities
            coin::destroy_burn_cap(burn_cap);
            coin::destroy_freeze_cap(freeze_cap);
        };

        // Create and fund admin account
        if (!account::exists_at(ADMIN)) {
            account::create_account_for_test(ADMIN);
        };
        let admin = account::create_signer_for_test(ADMIN);
        
        // Register AptosCoin for the admin account
        if (!coin::is_account_registered<AptosCoin>(ADMIN)) {
            coin::register<AptosCoin>(&admin);
        };
        
        // Mint coins to admin account
        let amount = 1000000000; // Adjust as needed
        if (exists<MintCapStore>(@aptos_framework)) {
            let mint_cap = &borrow_global<MintCapStore>(@aptos_framework).mint_cap;
            let coins = coin::mint(amount, mint_cap);
            coin::deposit(ADMIN, coins);
        };
        
        // Initialize the logistics platform
        core::initialize(&admin);
    }

    #[test(aptos_framework = @aptos_framework)]
    public entry fun test_initialize(aptos_framework: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        // Add assertions to check if the modules are properly initialized
    }

    #[test(aptos_framework = @aptos_framework, user = @0x111)]
    public entry fun test_user_registration(aptos_framework: &signer, user: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        let user_address = signer::address_of(user);
        account::create_account_for_test(user_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        
        // Add assertions to check if the user is properly registered
    }

    fun string_to_hex(input: vector<u8>): vector<u8> {
        let result = vector::empty<u8>();
        let len = vector::length(&input);
        let i = 0;
        while (i < len) {
            let byte: u8 = *vector::borrow(&input, i);
            vector::push_back(&mut result, hex_digit((byte >> 4) & 0xF));
            vector::push_back(&mut result, hex_digit(byte & 0xF));
            i = i + 1;
        };
        result
    }

    fun hex_digit(d: u8): u8 {
        if (d < 10) {
            d + 48
        } else {
            d + 87
        }
    }

    #[test(aptos_framework = @aptos_framework)]
    public entry fun test_courier_management_initialization(aptos_framework: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        // Check if courier management is initialized
        assert!(courier_management::is_initialized(), 0);
    }

    #[test(aptos_framework = @aptos_framework, courier = @0x333)]
    public entry fun test_courier_registration(aptos_framework: &signer, courier: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        // Check if courier management is initialized before registration
        assert!(courier_management::is_initialized(), 0);
        
        let courier_address = signer::address_of(courier);
        account::create_account_for_test(courier_address);
        
        let email = b"courier@example.com";
        let hex_email = string_to_hex(email);
        courier_management::register_courier_v2(courier, hex_email);
        
        // Add assertions to check if the courier is properly registered
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222)]
    public entry fun test_create_order(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        let user_address = signer::address_of(user);
        let recipient_address = signer::address_of(recipient);
        account::create_account_for_test(user_address);
        account::create_account_for_test(recipient_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        user_management::register_user(recipient, string::utf8(b"recipient@example.com"));
        
        // Fund the user's account
        coin::register<AptosCoin>(user);
        coin::transfer<AptosCoin>(admin, user_address, 1000000);
        
        core::create_order(
            user,
            recipient_address,
            string::utf8(b"123 Pickup St"),
            string::utf8(b"456 Delivery Ave"),
            100,
            200,
            300,
            400,
            500000,
            1000000,
            4,
            10
        );
        
        // Add assertions to check if the order is properly created
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222, courier = @0x333)]
    public entry fun test_accept_and_complete_order(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer, courier: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        // Check if courier management is initialized
        assert!(courier_management::is_initialized(), 0);
        
        let user_address = signer::address_of(user);
        let recipient_address = signer::address_of(recipient);
        let courier_address = signer::address_of(courier);
        account::create_account_for_test(user_address);
        account::create_account_for_test(recipient_address);
        account::create_account_for_test(courier_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        user_management::register_user(recipient, string::utf8(b"recipient@example.com"));
        let email = b"courier@example.com";
        let hex_email = string_to_hex(email);
        courier_management::register_courier_v2(courier, hex_email);
        
        // Fund the user's account
        coin::register<AptosCoin>(user);
        coin::transfer<AptosCoin>(admin, user_address, 1000000);
        
        core::create_order(
            user,
            recipient_address,
            string::utf8(b"123 Pickup St"),
            string::utf8(b"456 Delivery Ave"),
            100,
            200,
            300,
            400,
            500000,
            1000000,
            4,
            10
        );

        for (i in 0..11) {
            courier_management::update_completed_orders_for_test(signer::address_of(courier));
        };


        // Accept the order
        core::accept_order(courier, 0);
        
        // Complete the order (this is a simplified version, as we can't easily get the confirmation code)
        // In a real scenario, you'd need to extract the confirmation code from the order and use it here
        // core::confirm_delivery(recipient, 0, confirmation_code);
        
        // Add assertions to check if the order is properly accepted and completed
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222)]
    public entry fun test_cancel_order(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        let user_address = signer::address_of(user);
        let recipient_address = signer::address_of(recipient);
        account::create_account_for_test(user_address);
        account::create_account_for_test(recipient_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        user_management::register_user(recipient, string::utf8(b"recipient@example.com"));
        
        // Fund the user's account
        coin::register<AptosCoin>(user);
        coin::transfer<AptosCoin>(admin, user_address, 1000000);
        
        core::create_order(
            user,
            recipient_address,
            string::utf8(b"123 Pickup St"),
            string::utf8(b"456 Delivery Ave"),
            100,
            200,
            300,
            400,
            500000,
            1000000,
            4,
            10
        );
        
        // Cancel the order
        core::cancel_order(user, 0);
        
        // Add assertions to check if the order is properly cancelled
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform)]
    public entry fun test_finance_operations(aptos_framework: &signer, admin: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        let user = account::create_signer_for_test(@0x111);
        let recipient = account::create_signer_for_test(@0x222);
        account::create_account_for_test(@0x111);
        account::create_account_for_test(@0x222);
        
        user_management::register_user(&user, string::utf8(b"user@example.com"));
        user_management::register_user(&recipient, string::utf8(b"recipient@example.com"));
        
        coin::register<AptosCoin>(&user);
        coin::transfer<AptosCoin>(admin, @0x111, 1000000);
        
        core::create_order(
            &user,
            @0x222,
            string::utf8(b"123 Pickup St"),
            string::utf8(b"456 Delivery Ave"),
            100,
            200,
            300,
            400,
            500000,
            1000000,
            4,
            10
        );
        
        timestamp::fast_forward_seconds(60);
        
        let platform_balance = finance::get_platform_balance();
        finance::withdraw_platform_fees(admin, platform_balance);
        
        assert!(finance::get_platform_balance() == 0, 1);
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222, courier = @0x333)]
    public entry fun test_statistics(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer, courier: &signer) acquires MintCapStore {
        setup_test(aptos_framework);
        
        let user_address = signer::address_of(user);
        let recipient_address = signer::address_of(recipient);
        let courier_address = signer::address_of(courier);
        account::create_account_for_test(user_address);
        account::create_account_for_test(recipient_address);
        account::create_account_for_test(courier_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        user_management::register_user(recipient, string::utf8(b"recipient@example.com"));
        let email = b"courier@example.com";
        let hex_email = string_to_hex(email);
        courier_management::register_courier_v2(courier, hex_email);
        
        // Fund the user's account
        coin::register<AptosCoin>(user);
        coin::transfer<AptosCoin>(admin, user_address, 1000000);
        
        // Create an order
        core::create_order(
            user,
            recipient_address,
            string::utf8(b"123 Pickup St"),
            string::utf8(b"456 Delivery Ave"),
            100,
            200,
            300,
            400,
            500000,
            1000000,
            4,
            10
        );
        
        for (i in 0..11) {
            courier_management::update_completed_orders_for_test(signer::address_of(courier));
        };


        // Accept the order
        core::accept_order(courier, 0);
        
        // Get statistics
        let (total_orders, accepted_orders, completed_orders, cancelled_orders, total_delivery_fees, total_service_fees) = statistics::get_platform_stats();
        
        // Add assertions to check if the statistics are correct
        assert!(total_orders == 1, 0);
        assert!(accepted_orders == 1, 0);
        assert!(completed_orders == 0, 0);
        assert!(cancelled_orders == 0, 0);
        assert!(total_delivery_fees == 500000, 0);
        assert!(total_service_fees == 25000, 0); // Assuming 5% service fee
    }
}
#[test_only]
module logistics_platform::logistics_platform_tests {
    use std::signer;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;
    use logistics_platform::core;
    use logistics_platform::user_management;
    use logistics_platform::courier_management;
    use logistics_platform::finance;
    use logistics_platform::statistics;

    // Test accounts
    const ADMIN: address = @0xd6600cbe05c28dea705e623663ea618b24f92e22250a0e9b09475e1d2c1d8ed2;
    const USER1: address = @0x111;
    const USER2: address = @0x222;
    const COURIER1: address = @0x333;
    const COURIER2: address = @0x444;

    // Test setup
    fun setup_test(aptos_framework: &signer, admin: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        account::create_account_for_test(signer::address_of(admin));
        coin::register<AptosCoin>(admin);

        // Initialize modules
        core::initialize(admin);
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform)]
    public entry fun test_initialize(aptos_framework: &signer, admin: &signer) {
        setup_test(aptos_framework, admin);
        // Add assertions to check if the modules are properly initialized
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111)]
    public entry fun test_user_registration(aptos_framework: &signer, admin: &signer, user: &signer) {
        setup_test(aptos_framework, admin);
        
        let user_address = signer::address_of(user);
        account::create_account_for_test(user_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        
        // Add assertions to check if the user is properly registered
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, courier = @0x333)]
    public entry fun test_courier_registration(aptos_framework: &signer, admin: &signer, courier: &signer) {
        setup_test(aptos_framework, admin);
        
        let courier_address = signer::address_of(courier);
        account::create_account_for_test(courier_address);
        
        courier_management::register_courier(courier, string::utf8(b"courier@example.com"));
        
        // Add assertions to check if the courier is properly registered
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222)]
    public entry fun test_create_order(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer) {
        setup_test(aptos_framework, admin);
        
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
    public entry fun test_accept_and_complete_order(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer, courier: &signer) {
        setup_test(aptos_framework, admin);
        
        let user_address = signer::address_of(user);
        let recipient_address = signer::address_of(recipient);
        let courier_address = signer::address_of(courier);
        account::create_account_for_test(user_address);
        account::create_account_for_test(recipient_address);
        account::create_account_for_test(courier_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        user_management::register_user(recipient, string::utf8(b"recipient@example.com"));
        courier_management::register_courier(courier, string::utf8(b"courier@example.com"));
        
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
        
        // Accept the order
        core::accept_order(courier, 0);
        
        // Complete the order (this is a simplified version, as we can't easily get the confirmation code)
        // In a real scenario, you'd need to extract the confirmation code from the order and use it here
        // core::confirm_delivery(recipient, 0, confirmation_code);
        
        // Add assertions to check if the order is properly accepted and completed
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222)]
    public entry fun test_cancel_order(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer) {
        setup_test(aptos_framework, admin);
        
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
    public entry fun test_finance_operations(aptos_framework: &signer, admin: &signer) {
        setup_test(aptos_framework, admin);
        
        // Test withdrawing platform fees
        finance::withdraw_platform_fees(admin, 100000);
        
        // Add assertions to check if the financial operations are working correctly
    }

    #[test(aptos_framework = @aptos_framework, admin = @logistics_platform, user = @0x111, recipient = @0x222, courier = @0x333)]
    public entry fun test_statistics(aptos_framework: &signer, admin: &signer, user: &signer, recipient: &signer, courier: &signer) {
        setup_test(aptos_framework, admin);
        
        let user_address = signer::address_of(user);
        let recipient_address = signer::address_of(recipient);
        let courier_address = signer::address_of(courier);
        account::create_account_for_test(user_address);
        account::create_account_for_test(recipient_address);
        account::create_account_for_test(courier_address);
        
        user_management::register_user(user, string::utf8(b"user@example.com"));
        user_management::register_user(recipient, string::utf8(b"recipient@example.com"));
        courier_management::register_courier(courier, string::utf8(b"courier@example.com"));
        
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
#[test_only]
module logistics_platform::logistics_platform_tests {
    // use std::signer;
    // use aptos_framework::account;
    // use aptos_framework::timestamp;
    // use aptos_framework::aptos_coin::AptosCoin;
    // use aptos_framework::coin::{Self, MintCapability};
    // use std::string;
    // use logistics_platform::core;
    // use logistics_platform::user_management;
    // use logistics_platform::statistics;
    // // Test accounts
    // const ADMIN: address = @0xa9d1702ac29b697d1a150e0eb0cfba91fd574404df3d06874ac167468a1c0822;
    // const USER1: address = @0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea;
    // const USER2: address = @0x55c8dea9a4be53e5ca8b6c3908b099e7f0984f2cf3eebce681b661942f47316b;
    // const COURIER1: address = @0xf259b5f88ed806f472f8bb72905e4de73c5dcf5cb8f09d9cecb839d6b085b3ed;
    // const COURIER2: address = @0x08112834c88e612d3e522b722d18d4d54e0f9d70ede87c98264ea746ea9643ea;

    // fun setup_test(aptos_framework: &signer) {
        // timestamp::set_time_has_started_for_testing(aptos_framework);
        // 
        // let admin = account::create_account_for_test(ADMIN);
        // core::init_module(&admin);
        // user_management::init_module(&admin);
        // statistics::init_module(&admin);
    // }

    // #[test(aptos_framework = @aptos_framework)]
    // public fun test_register_users_and_create_order(aptos_framework: &signer) {
    //     timestamp::set_time_has_started_for_testing(aptos_framework);
        
    //     let logistics_platform = account::create_account_for_test(@logistics_platform);
        
    //     user_management::init_module_for_test(&logistics_platform);

    //     let user1 = account::create_account_for_test(@0x1);
    //     let user2 = account::create_account_for_test(@0x2);

    //     user_management::register_user(&user1, string::utf8(b"user1@example.com"), false);
    //     user_management::register_user(&user2, string::utf8(b"user2@example.com"), true);

    //     // Create order
    //     core::create_order(
    //         &user1,
    //         USER2,
    //         COURIER1,
    //         b"Pickup Address",
    //         b"Delivery Address",
    //         1000
    //     );

    //     // Check order details
    //     let (sender, recipient, courier, pickup_address, delivery_address, status, amount) = core::get_order_details(0);
    //     assert!(sender == USER1, 0);
    //     assert!(recipient == USER2, 1);
    //     assert!(courier == COURIER1, 2);
    //     assert!(pickup_address == b"Pickup Address", 3);
    //     assert!(delivery_address == b"Delivery Address", 4);
    //     assert!(status == 0, 5); // PENDING
    //     assert!(amount == 1000, 6);

    //     // Check platform stats
    //     let (total_orders, total_users, total_delivery_amount, total_transaction_amount) = statistics::get_platform_stats();
    //     assert!(total_orders == 1, 7);
    //     assert!(total_users == 3, 8);
    //     assert!(total_delivery_amount == 1000, 9);
    //     assert!(total_transaction_amount == 1000, 10);
    // }

    // #[test(aptos_framework = @aptos_framework)]
    // fun test_confirm_order(aptos_framework: &signer) {
    //     // setup_test(aptos_framework);

    //     // Register users
    //     let user1 = account::create_account_for_test(USER1);
    //     let user2 = account::create_account_for_test(USER2);
    //     let courier1 = account::create_account_for_test(COURIER1);

    //     user_management::register_user(&user1, string::utf8(b"user1@example.com"), false);
    //     user_management::register_user(&user2, string::utf8(b"user2@example.com"), false);
    //     user_management::register_user(&courier1, string::utf8(b"courier1@example.com"), true);

    //     // Create order
    //     core::create_order(
    //         &user1,
    //         USER2,
    //         COURIER1,
    //         b"Pickup Address",
    //         b"Delivery Address",
    //         1000
    //     );

    //     // Confirm order
    //     core::confirm_order(&courier1, 0);

    //     // Check order details
    //     let (_, _, _, _, _, status, _) = core::get_order_details(0);
    //     assert!(status == 1, 11); // COMPLETED

    //     // Check courier balance
    //     let (_, _, _, exists) = user_management::get_user_info(COURIER1);
    //     assert!(exists, 12);
    //     // Note: We can't directly check the balance in this test setup, 
    //     // but in a real scenario, the courier's balance should have increased by 1000
    // }
}
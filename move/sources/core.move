module logistics_platform::core {
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::timestamp;
    use aptos_std::table::{Self, Table};
    use std::signer;
    use std::vector;
    use std::option;
    use logistics_platform::user_management;
    use logistics_platform::statistics;

    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_INVALID_ORDER_STATUS: u64 = 3;
    const E_UNAUTHORIZED: u64 = 4;
    const E_INSUFFICIENT_BALANCE: u64 = 5;
    const E_NOT_A_COURIER: u64 = 6;
    const E_RECIPIENT_NOT_FOUND: u64 = 7;
    const E_ORDER_NOT_FOUND: u64 = 8;

    struct DeliveryOrder has store, drop, copy {
        order_id: u64,
        sender: address,
        recipient: address,
        courier: address,
        pickup_address: vector<u8>,
        delivery_address: vector<u8>,
        status: u8,
        created_at: u64,
        amount: u64,
    }

    struct PlatformAccount has key {
        orders: Table<address, vector<DeliveryOrder>>,
        next_order_id: u64,
        order_created_events: EventHandle<OrderCreatedEvent>,
        order_confirmed_events: EventHandle<OrderConfirmedEvent>,
        order_confirm_events: EventHandle<OrderConfirmEvent>,
    }

    struct OrderCreatedEvent has drop, store {
        order_id: u64,
        sender: address,
        recipient: address,
        courier: address,
        pickup_address: vector<u8>,
        delivery_address: vector<u8>,
        amount: u64,
        created_at: u64,
    }

    struct OrderConfirmedEvent has drop, store {
        order_id: u64,
        confirmed_at: u64,
    }

    struct OrderConfirmEvent has drop, store {
        order_id: u64,
        courier: address,
        recipient: address,
        amount: u64,
        timestamp: u64,
    }

    fun init_module(account: &signer) {
        assert!(!exists<PlatformAccount>(signer::address_of(account)), E_ALREADY_INITIALIZED);

        move_to(account, PlatformAccount {
            orders: table::new(),
            next_order_id: 1,
            order_created_events: account::new_event_handle<OrderCreatedEvent>(account),
            order_confirmed_events: account::new_event_handle<OrderConfirmedEvent>(account),
            order_confirm_events: account::new_event_handle<OrderConfirmEvent>(account),
        });
    }

    public entry fun confirm_order(courier: &signer, order_id: u64, recipient_address: address) acquires PlatformAccount {
        let courier_address = signer::address_of(courier);
        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        
        // Verify that the recipient address exists
        assert!(table::contains(&platform_account.orders, recipient_address), E_RECIPIENT_NOT_FOUND);
        
        // Get the recipient's order list
        let recipient_orders = table::borrow_mut(&mut platform_account.orders, recipient_address);
        
        // Find the specified order
        let order_index = option::none();
        let index = 0;
        while (index < vector::length(recipient_orders)) {
            let order = vector::borrow(recipient_orders, index);
            if (order.order_id == order_id) {
                order_index = option::some(index);
                break
            };
            index = index + 1;
        };
        
        assert!(option::is_some(&order_index), E_ORDER_NOT_FOUND);
        let order_index = option::extract(&mut order_index);
        
        // Get and check the order
        let order = vector::borrow_mut(recipient_orders, order_index);
        assert!(order.status == 0, E_INVALID_ORDER_STATUS); // PENDING
        assert!(order.courier == courier_address, E_UNAUTHORIZED);
        
        // Update order status
        order.status = 1; // COMPLETED
        
        // Update courier balance
        user_management::add_balance(courier_address, order.amount);
        
        // Emit order confirmation event
        event::emit_event(
            &mut platform_account.order_confirm_events,
            OrderConfirmEvent {
                order_id,
                courier: courier_address,
                recipient: recipient_address,
                amount: order.amount,
                timestamp: timestamp::now_seconds(),
            }
        );
    }

    public entry fun confirm_order_v2(recipient: &signer, order_id: u64) acquires PlatformAccount {
        let recipient_address = signer::address_of(recipient);
        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        
        // Verify that the recipient address exists
        assert!(table::contains(&platform_account.orders, recipient_address), E_RECIPIENT_NOT_FOUND);
        
        // Get the recipient's order list
        let recipient_orders = table::borrow_mut(&mut platform_account.orders, recipient_address);
        
        // Find the specified order
        let order_index = option::none();
        let index = 0;
        while (index < vector::length(recipient_orders)) {
            let order = vector::borrow(recipient_orders, index);
            if (order.order_id == order_id) {
                order_index = option::some(index);
                break
            };
            index = index + 1;
        };
        
        assert!(option::is_some(&order_index), E_ORDER_NOT_FOUND);
        let order_index = option::extract(&mut order_index);
        
        // Get and check the order
        let order = vector::borrow_mut(recipient_orders, order_index);
        assert!(order.status == 0, E_INVALID_ORDER_STATUS); // PENDING
        
        // Update order status
        order.status = 1; // COMPLETED
        
        // Update courier balance
        user_management::add_balance(order.courier, order.amount);
        
        // Emit order confirmation event
        event::emit_event(
            &mut platform_account.order_confirm_events,
            OrderConfirmEvent {
                order_id,
                courier: order.courier,
                recipient: recipient_address,
                amount: order.amount,
                timestamp: timestamp::now_seconds(),
            }
        );
    }

    public entry fun create_order(
        sender: &signer,
        recipient: address,
        courier: address,
        pickup_address: vector<u8>,
        delivery_address: vector<u8>,
        amount: u64,
    ) acquires PlatformAccount {
        let sender_address = signer::address_of(sender);
        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        
        user_management::deduct_balance(sender_address, amount);
        
        assert!(user_management::check_user_exists(courier), E_UNAUTHORIZED);
        assert!(user_management::is_courier(courier), E_NOT_A_COURIER);
        
        let order_id = platform_account.next_order_id;
        platform_account.next_order_id = order_id + 1;

        let order = DeliveryOrder {
            order_id,
            sender: sender_address,
            recipient,
            courier,
            pickup_address: pickup_address,
            delivery_address: delivery_address,
            status: 0, // PENDING
            created_at: timestamp::now_seconds(),
            amount,
        };

        if (!table::contains(&platform_account.orders, sender_address)) {
            table::add(&mut platform_account.orders, sender_address, vector::empty<DeliveryOrder>());
        };
        let sender_orders = table::borrow_mut(&mut platform_account.orders, sender_address);
        vector::push_back(sender_orders, order);

        event::emit_event(&mut platform_account.order_created_events, OrderCreatedEvent {
            order_id,
            sender: sender_address,
            recipient,
            courier,
            pickup_address,
            delivery_address,
            amount,
            created_at: timestamp::now_seconds(),
        });

        statistics::update_stats_new_order(amount);
    }

    #[view]
    public fun get_user_orders(user_address: address): vector<DeliveryOrder> acquires PlatformAccount {
        let platform_account = borrow_global<PlatformAccount>(@logistics_platform);
        if (table::contains(&platform_account.orders, user_address)) {
            *table::borrow(&platform_account.orders, user_address)
        } else {
            vector::empty<DeliveryOrder>()
        }
    }
}
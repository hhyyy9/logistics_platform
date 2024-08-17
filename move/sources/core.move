module logistics_platform::core {
    use std::string::String;
    use aptos_framework::coin::{Self};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::timestamp;
    use aptos_std::table::{Self, Table};
    use aptos_std::hash;
    use aptos_framework::event::{Self, EventHandle};
    use std::signer;
    use std::vector;
    use std::bcs;

    use logistics_platform::user_management;
    use logistics_platform::courier_management;
    use logistics_platform::finance;
    use logistics_platform::statistics;

    // Constants
    const ADMIN_ADDRESS: address = @0xd6600cbe05c28dea705e623663ea618b24f92e22250a0e9b09475e1d2c1d8ed2; // Replace with actual admin address

    // Error codes
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_INVALID_ORDER_STATUS: u64 = 3;
    const E_UNAUTHORIZED: u64 = 6;
    const E_INVALID_CONFIRMATION_CODE: u64 = 7;
    const E_ORDER_ALREADY_ACCEPTED: u64 = 11;
    const E_ORDER_EXPIRED: u64 = 14;
    const E_INVALID_STATUS_TRANSITION: u64 = 20;
    const E_INSUFFICIENT_BALANCE: u64 = 23;
    const E_INVALID_ORDER: u64 = 26;

    // Structs
    struct Coordinate has copy, drop, store {
        latitude: u64,
        longitude: u64,
    }

    struct DeliveryOrder has store {
        order_id: u64,
        sender: address,
        recipient: address,
        courier: address,
        pickup_address: String,
        delivery_address: String,
        pickup_coordinate: Coordinate,
        delivery_coordinate: Coordinate,
        delivery_fee: u64,
        service_fee: u64,
        total_fee: u64,
        deadline: u64,
        min_rating: u8,
        min_completed_orders: u64,
        status: u8,
        confirmation_code: vector<u8>,
        created_at: u64,
    }

    struct PlatformAccount has key {
        orders: Table<u64, DeliveryOrder>,
        user_orders: Table<address, vector<u64>>,
        next_order_id: u64,
        service_fee_percentage: u64,
        signer_cap: SignerCapability,
        order_created_events: EventHandle<OrderCreatedEvent>,
        order_status_updated_events: EventHandle<OrderStatusUpdatedEvent>,
    }

    // Events
    struct OrderCreatedEvent has drop, store {
        order_id: u64,
        sender: address,
        recipient: address,
        pickup_coordinate: Coordinate,
        delivery_coordinate: Coordinate,
        delivery_fee: u64,
        service_fee: u64,
        total_fee: u64,
        confirmation_code: vector<u8>,
        deadline: u64,
        created_at: u64,
    }

    struct OrderStatusUpdatedEvent has drop, store {
        order_id: u64,
        old_status: u8,
        new_status: u8,
    }
    

    // Functions
    /// Initializes the platform
    public entry fun initialize(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == ADMIN_ADDRESS, 0);
        assert!(!exists<PlatformAccount>(admin_addr), E_ALREADY_INITIALIZED);

        let (resource_signer, resource_signer_cap) = account::create_resource_account(admin, vector::empty());

        move_to(admin, PlatformAccount {
            orders: table::new(),
            user_orders: table::new(),
            next_order_id: 0,
            service_fee_percentage: 5,
            signer_cap: resource_signer_cap,
            order_created_events: account::new_event_handle<OrderCreatedEvent>(&resource_signer),
            order_status_updated_events: account::new_event_handle<OrderStatusUpdatedEvent>(&resource_signer),
        });

        user_management::initialize(admin);
        courier_management::initialize(admin);
        finance::initialize(admin);
        statistics::initialize(admin);
    }

    /// Creates a new delivery order
    ///
    /// # Arguments
    ///
    /// * `sender` - The signer creating the order
    /// * `recipient` - The address of the recipient
    /// * `pickup_address` - The pickup address as a string
    /// * `delivery_address` - The delivery address as a string
    /// * `pickup_latitude` - The latitude of the pickup location
    /// * `pickup_longitude` - The longitude of the pickup location
    /// * `delivery_latitude` - The latitude of the delivery location
    /// * `delivery_longitude` - The longitude of the delivery location
    /// * `delivery_fee` - The fee to be paid to the courier
    /// * `deadline` - The deadline for the order completion (in seconds since UNIX epoch)
    /// * `min_rating` - The minimum rating required for a courier to accept this order
    /// * `min_completed_orders` - The minimum number of completed orders required for a courier to accept this order
    ///
    /// # Errors
    ///
    /// * `E_INSUFFICIENT_BALANCE` - If the sender doesn't have enough balance to cover the total fee
    /// * `E_USER_DEACTIVATED` - If either the sender or recipient is not an active user
    ///
    /// # Events
    ///
    /// Emits an `OrderCreatedEvent` upon successful creation of the order
    public entry fun create_order(
        sender: &signer,
        recipient: address,
        pickup_address: String,
        delivery_address: String,
        pickup_latitude: u64,
        pickup_longitude: u64,
        delivery_latitude: u64,
        delivery_longitude: u64,
        delivery_fee: u64,
        deadline: u64,
        min_rating: u8,
        min_completed_orders: u64
    ) acquires PlatformAccount {
        let sender_address = signer::address_of(sender);
        user_management::assert_user_active(sender_address);
        user_management::assert_user_active(recipient);

        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        
        let order_id = platform_account.next_order_id;
        platform_account.next_order_id = order_id + 1;

        let service_fee = (delivery_fee * platform_account.service_fee_percentage) / 100;
        let total_fee = delivery_fee + service_fee;

        // Check if sender has enough balance
        assert!(coin::balance<AptosCoin>(sender_address) >= total_fee, E_INSUFFICIENT_BALANCE);

        let confirmation_code = generate_confirmation_code(sender_address, recipient, order_id);

        let pickup_coordinate = Coordinate { latitude: pickup_latitude, longitude: pickup_longitude };
        let delivery_coordinate = Coordinate { latitude: delivery_latitude, longitude: delivery_longitude };

        let order = DeliveryOrder {
            order_id,
            sender: sender_address,
            recipient,
            courier: @0x0,
            pickup_address,
            delivery_address,
            pickup_coordinate,
            delivery_coordinate,
            delivery_fee,
            service_fee,
            total_fee,
            deadline,
            min_rating,
            min_completed_orders,
            status: 0, // PENDING
            confirmation_code,
            created_at: timestamp::now_seconds(),
        };

        table::add(&mut platform_account.orders, order_id, order);

        if (!table::contains(&platform_account.user_orders, sender_address)) {
            table::add(&mut platform_account.user_orders, sender_address, vector::empty<u64>());
        };
        let user_orders = table::borrow_mut(&mut platform_account.user_orders, sender_address);
        vector::push_back(user_orders, order_id);

        finance::process_order_payment(sender, total_fee);
        statistics::update_order_created(delivery_fee, service_fee);

        event::emit_event(&mut platform_account.order_created_events, OrderCreatedEvent {
            order_id,
            sender: sender_address,
            recipient,
            pickup_coordinate,
            delivery_coordinate,
            delivery_fee,
            service_fee,
            total_fee,
            confirmation_code,
            deadline,
            created_at: timestamp::now_seconds(),
        });
    }

    /// Accepts an order
    public entry fun accept_order(courier: &signer, order_id: u64) acquires PlatformAccount {
        let courier_address = signer::address_of(courier);
        courier_management::assert_courier_active(courier_address);

        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        let order = table::borrow_mut(&mut platform_account.orders, order_id);
        
        assert!(order.status == 0, E_INVALID_ORDER_STATUS); // PENDING
        assert!(order.courier == @0x0, E_ORDER_ALREADY_ACCEPTED);
        
        let (courier_rating, completed_orders) = courier_management::get_courier_stats(courier_address);
        assert!(courier_rating >= (order.min_rating as u64), 0);
        assert!(completed_orders >= order.min_completed_orders, 0);
        
        order.courier = courier_address;
        order.status = 1; // IN_PROGRESS

        // Update statistics
        statistics::update_order_accepted(order_id);

        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        event::emit_event(&mut platform_account.order_status_updated_events, OrderStatusUpdatedEvent {
            order_id,
            old_status: 0, // PENDING
            new_status: 1, // IN_PROGRESS
        });
    }

    /// Confirms the delivery of an order
    public entry fun confirm_delivery(recipient: &signer, order_id: u64, input_code: vector<u8>) acquires PlatformAccount {
        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        let order = table::borrow_mut(&mut platform_account.orders, order_id);
        
        assert!(signer::address_of(recipient) == order.recipient, E_UNAUTHORIZED);
        assert!(order.status == 1, E_INVALID_ORDER_STATUS); // IN_PROGRESS
        assert!(order.confirmation_code == input_code, E_INVALID_CONFIRMATION_CODE);
        
        // Check if the order has expired
        assert!(timestamp::now_seconds() <= order.deadline, E_ORDER_EXPIRED);
        
        order.status = 2; // COMPLETED
        
        finance::process_order_completion(&platform_account.signer_cap, order.courier, order.delivery_fee, order.service_fee);
        courier_management::update_completed_orders(order.courier);
        statistics::update_order_completed();

        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        event::emit_event(&mut platform_account.order_status_updated_events, OrderStatusUpdatedEvent {
            order_id,
            old_status: 1, // IN_PROGRESS
            new_status: 2, // COMPLETED
        });
    }

    /// Cancels an order
    public entry fun cancel_order(sender: &signer, order_id: u64) acquires PlatformAccount {
        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        let order = table::borrow_mut(&mut platform_account.orders, order_id);
        
        assert!(signer::address_of(sender) == order.sender, E_UNAUTHORIZED);
        assert!(order.status == 0 || order.status == 1, E_INVALID_STATUS_TRANSITION); // PENDING or IN_PROGRESS
        
        let old_status = order.status;
        order.status = 3; // CANCELLED
        
        finance::process_order_cancellation(&platform_account.signer_cap, order.sender, order.total_fee);
        statistics::update_order_cancelled(order.delivery_fee, order.service_fee);

        let platform_account = borrow_global_mut<PlatformAccount>(@logistics_platform);
        event::emit_event(&mut platform_account.order_status_updated_events, OrderStatusUpdatedEvent {
            order_id,
            old_status,
            new_status: 3, // CANCELLED
        });
    }

    /// Gets the details of an order
    public fun get_order_details(order_id: u64): (address, address, address, String, String, Coordinate, Coordinate, u64, u64, u64, u8) acquires PlatformAccount {
        let platform_account = borrow_global<PlatformAccount>(@logistics_platform);
        let order = table::borrow(&platform_account.orders, order_id);
        
        (order.sender, order.recipient, order.courier, order.pickup_address, order.delivery_address, 
         order.pickup_coordinate, order.delivery_coordinate, order.delivery_fee, order.service_fee, 
         order.total_fee, order.status)
    }

    /// Gets the orders placed by a user
    public fun get_user_orders(user_address: address): vector<u64> acquires PlatformAccount {
        let platform_account = borrow_global<PlatformAccount>(@logistics_platform);
        if (table::contains(&platform_account.user_orders, user_address)) {
            *table::borrow(&platform_account.user_orders, user_address)
        } else {
            vector::empty<u64>()
        }
    }

    /// Generates a confirmation code for an order
    fun generate_confirmation_code(sender: address, recipient: address, order_id: u64): vector<u8> {
        let input = vector::empty<u8>();
        vector::append(&mut input, bcs::to_bytes(&sender));
        vector::append(&mut input, bcs::to_bytes(&recipient));
        vector::append(&mut input, bcs::to_bytes(&order_id));
        vector::append(&mut input, bcs::to_bytes(&timestamp::now_microseconds()));
        
        hash::sha3_256(input)
    }

    public entry fun rate_courier(recipient: &signer, order_id: u64, rating: u8) acquires PlatformAccount {
        let platform_account = borrow_global<PlatformAccount>(@logistics_platform);
        assert!(table::contains(&platform_account.orders, order_id), E_INVALID_ORDER);
        
        let order = table::borrow(&platform_account.orders, order_id);
        assert!(order.recipient == signer::address_of(recipient), E_UNAUTHORIZED);
        assert!(order.status == 2, E_INVALID_ORDER_STATUS); // Ensure order is COMPLETED

        courier_management::rate_courier(order_id, order.courier, rating);
    }
}
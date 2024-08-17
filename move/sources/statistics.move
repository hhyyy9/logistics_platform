module logistics_platform::statistics {
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::timestamp;

    friend logistics_platform::core;

    struct PlatformStats has key {
        total_orders: u64,
        accepted_orders: u64,
        completed_orders: u64,
        cancelled_orders: u64,
        total_delivery_fees: u64,
        total_service_fees: u64,
    }

    struct OrderAcceptedEvent has drop, store {
        order_id: u64,
        timestamp: u64,
    }

    struct EventHandles has key {
        order_accepted_events: EventHandle<OrderAcceptedEvent>,
    }

    public(friend) fun initialize(admin: &signer) {
        move_to(admin, PlatformStats {
            total_orders: 0,
            accepted_orders: 0,
            completed_orders: 0,
            cancelled_orders: 0,
            total_delivery_fees: 0,
            total_service_fees: 0,
        });

        move_to(admin, EventHandles {
            order_accepted_events: account::new_event_handle<OrderAcceptedEvent>(admin),
        });
    }

    public(friend) fun update_order_created(delivery_fee: u64, service_fee: u64) acquires PlatformStats {
        let stats = borrow_global_mut<PlatformStats>(@logistics_platform);
        stats.total_orders = stats.total_orders + 1;
        stats.total_delivery_fees = stats.total_delivery_fees + delivery_fee;
        stats.total_service_fees = stats.total_service_fees + service_fee;
    }

    public(friend) fun update_order_accepted(order_id: u64) acquires PlatformStats, EventHandles {
        let stats = borrow_global_mut<PlatformStats>(@logistics_platform);
        stats.accepted_orders = stats.accepted_orders + 1;

        let event_handles = borrow_global_mut<EventHandles>(@logistics_platform);
        event::emit_event(&mut event_handles.order_accepted_events, OrderAcceptedEvent {
            order_id,
            timestamp: timestamp::now_seconds(),
        });
    }

    public(friend) fun update_order_completed() acquires PlatformStats {
        let stats = borrow_global_mut<PlatformStats>(@logistics_platform);
        stats.completed_orders = stats.completed_orders + 1;
    }

    public(friend) fun update_order_cancelled(delivery_fee: u64, service_fee: u64) acquires PlatformStats {
        let stats = borrow_global_mut<PlatformStats>(@logistics_platform);
        stats.cancelled_orders = stats.cancelled_orders + 1;
        stats.total_delivery_fees = stats.total_delivery_fees - delivery_fee;
        stats.total_service_fees = stats.total_service_fees - service_fee;
    }

    public fun get_platform_stats(): (u64, u64, u64, u64, u64, u64) acquires PlatformStats {
        let stats = borrow_global<PlatformStats>(@logistics_platform);
        (
            stats.total_orders,
            stats.accepted_orders,
            stats.completed_orders,
            stats.cancelled_orders,
            stats.total_delivery_fees,
            stats.total_service_fees
        )
    }
}
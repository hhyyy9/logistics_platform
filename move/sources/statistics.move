module logistics_platform::statistics {
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};

    friend logistics_platform::user_management;
    friend logistics_platform::core;

    struct PlatformStats has key, store {
        total_orders: u64,
        total_users: u64,
        total_delivery_amount: u64,
        total_transaction_amount: u64,
    }

    struct StatsStore has key {
        stats: PlatformStats,
        stats_updated_events: EventHandle<StatsUpdatedEvent>,
    }

    #[event]
    struct StatsUpdatedEvent has drop, store {
        total_orders: u64,
        total_users: u64,
        total_delivery_amount: u64,
        total_transaction_amount: u64,
    }

    fun init_module(account: &signer) {
        move_to(account, StatsStore {
            stats: PlatformStats {
                total_orders: 0,
                total_users: 0,
                total_delivery_amount: 0,
                total_transaction_amount: 0,
            },
            stats_updated_events: account::new_event_handle<StatsUpdatedEvent>(account),
        });
    }

    public(friend) fun update_stats_new_order(amount: u64) acquires StatsStore {
        let stats_store = borrow_global_mut<StatsStore>(@logistics_platform);
        let stats = &mut stats_store.stats;
        stats.total_orders = stats.total_orders + 1;
        stats.total_delivery_amount = stats.total_delivery_amount + amount;
        stats.total_transaction_amount = stats.total_transaction_amount + amount;

        emit_stats_updated_event(stats_store);
    }

    public(friend) fun update_stats_new_user() acquires StatsStore {
        let stats_store = borrow_global_mut<StatsStore>(@logistics_platform);
        let stats = &mut stats_store.stats;
        stats.total_users = stats.total_users + 1;

        emit_stats_updated_event(stats_store);
    }

    fun emit_stats_updated_event(stats_store: &mut StatsStore) {
        event::emit_event(&mut stats_store.stats_updated_events, StatsUpdatedEvent {
            total_orders: stats_store.stats.total_orders,
            total_users: stats_store.stats.total_users,
            total_delivery_amount: stats_store.stats.total_delivery_amount,
            total_transaction_amount: stats_store.stats.total_transaction_amount,
        });
    }

    #[view]
    public fun get_platform_stats(): (u64, u64, u64, u64) acquires StatsStore {
        let stats_store = borrow_global<StatsStore>(@logistics_platform);
        let stats = &stats_store.stats;
        (stats.total_orders, stats.total_users, stats.total_delivery_amount, stats.total_transaction_amount)
    }
}
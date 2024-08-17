module logistics_platform::finance {
    use std::signer;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event::{Self, EventHandle};

    friend logistics_platform::core;

    const E_UNAUTHORIZED: u64 = 6;
    // Error constants
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_NOT_AUTHORIZED: u64 = 3;
    const E_INSUFFICIENT_BALANCE: u64 = 23;

    struct FinanceStore has key {
        platform_balance: Coin<AptosCoin>,
        platform_fees_withdrawn_events: EventHandle<PlatformFeesWithdrawnEvent>, // Add this line
    }

    #[event]
    struct PlatformFeesWithdrawnEvent has drop, store {
        amount: u64,
        admin_address: address,
    }

    public(friend) fun initialize(admin: &signer) {
        move_to(admin, FinanceStore {
            platform_balance: coin::zero<AptosCoin>(),
            platform_fees_withdrawn_events: account::new_event_handle<PlatformFeesWithdrawnEvent>(admin), // Add this line
        });
    }

    /// Processes the payment for an order
    public(friend) fun process_order_payment(payer: &signer, amount: u64) acquires FinanceStore {
        let finance_store = borrow_global_mut<FinanceStore>(@logistics_platform);
        let payment = coin::withdraw<AptosCoin>(payer, amount);
        coin::merge(&mut finance_store.platform_balance, payment);
    }

    /// Processes the completion of an order
    public(friend) fun process_order_completion(
        cap: &SignerCapability,
        courier: address,
        delivery_fee: u64,
        _service_fee: u64
    ) acquires FinanceStore {
        let finance_store = borrow_global_mut<FinanceStore>(@logistics_platform);
        let _ = account::create_signer_with_capability(cap);
        
        let courier_payment = coin::extract(&mut finance_store.platform_balance, delivery_fee);
        coin::deposit(courier, courier_payment);
    }

    /// Processes the cancellation of an order
    public(friend) fun process_order_cancellation(
        cap: &SignerCapability,
        refund_address: address,
        refund_amount: u64
    ) acquires FinanceStore {
        let finance_store = borrow_global_mut<FinanceStore>(@logistics_platform);
        let _ = account::create_signer_with_capability(cap);
        
        let refund = coin::extract(&mut finance_store.platform_balance, refund_amount);
        coin::deposit(refund_address, refund);
    }

    /// Withdraws platform fees
    public entry fun withdraw_platform_fees(admin: &signer, amount: u64) acquires FinanceStore {
        assert!(signer::address_of(admin) == @logistics_platform, E_NOT_AUTHORIZED);
        
        let finance_store = borrow_global_mut<FinanceStore>(@logistics_platform);
        assert!(amount <= coin::value(&finance_store.platform_balance), E_INSUFFICIENT_BALANCE);

        let withdrawal = coin::extract(&mut finance_store.platform_balance, amount);
        coin::deposit(signer::address_of(admin), withdrawal);

        // Use emit_event instead of emit
        event::emit_event(
            &mut finance_store.platform_fees_withdrawn_events,
            PlatformFeesWithdrawnEvent {
                amount,
                admin_address: signer::address_of(admin),
            }
        );
    }

    /// Returns the current platform balance
    public fun get_platform_balance(): u64 acquires FinanceStore {
        let finance_store = borrow_global<FinanceStore>(@logistics_platform);
        coin::value(&finance_store.platform_balance)
    }
}
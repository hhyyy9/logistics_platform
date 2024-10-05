import { types, flow, Instance, cast } from 'mobx-state-tree';
import { message } from 'antd';
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import { InputTransactionData } from '@aptos-labs/wallet-adapter-core';

export const Order = types.model("Order", {
    orderId: types.number,
    sender: types.string,
    recipient: types.string,
    courier: types.string,
    pickupAddress: types.string,
    deliveryAddress: types.string,
    status: types.number,
    createdAt: types.number,
    amount: types.number
});

export const OrderStore = types
    .model('OrderStore', {
        userOrders: types.array(Order),
        isLoading: types.boolean,
    })
    .actions((self) => {
        const setLoading = (loading: boolean) => {
            self.isLoading = loading;
        };

        const createOrder = flow(function* (
            recipient: string,
            courier: string,
            pickupAddress: string,
            deliveryAddress: string,
            amount: number,
            signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>
        ) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::core::create_order`,
                        typeArguments: [],
                        functionArguments: [
                            recipient, 
                            courier, 
                            Array.from(new TextEncoder().encode(pickupAddress)),
                            Array.from(new TextEncoder().encode(deliveryAddress)),
                            amount.toString()  // Convert amount to string
                        ],
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('Order created successfully');
            } catch (error) {
                console.error('Error occurred while creating order', error);
                if (error instanceof Error) {
                    message.error(`Failed to create order: ${error.message}`);
                } else {
                    message.error('Failed to create order');
                }
            }
        });

        const getUserOrders = flow(function* (address: string) {
            self.isLoading = true;
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const config = new AptosConfig({ network: Network.DEVNET });
                const aptos = new Aptos(config);

                const response = yield aptos.view({
                    payload: {
                        function: `${moduleAddress}::core::get_user_orders`,
                        typeArguments: [],
                        functionArguments: [address]
                    },
                });

                console.log("Raw response:", response);

                if (Array.isArray(response) && response.length > 0 && Array.isArray(response[0])) {
                    const orders = response[0];
                    self.userOrders = cast(orders.map((order: any) => {
                        console.log("Processing order:", order);
                        return Order.create({
                            orderId: Number(order.order_id) || 0,
                            sender: order.sender || '',
                            recipient: order.recipient || '',
                            courier: order.courier || '',
                            pickupAddress: decodeAddress(order.pickup_address),
                            deliveryAddress: decodeAddress(order.delivery_address),
                            status: Number(order.status) || 0,
                            amount: Number(order.amount) || 0,
                            createdAt: Number(order.created_at) || 0,
                        });
                    }));
                } else {
                    console.error("Unexpected response format:", response);
                    self.userOrders.clear();
                }
            } catch (error) {
                console.error('Failed to get user orders:', error);
                message.error('Failed to get user orders');
                self.userOrders.clear();
            } finally {
                self.isLoading = false;
            }
        });

        // Helper function to safely decode address
        function decodeAddress(address: any): string {
            if (typeof address === 'string') {
                // If address is a hexadecimal string, return it directly
                return address;
            } else if (Array.isArray(address)) {
                // If address is a byte array, try to decode it
                try {
                    return new TextDecoder().decode(new Uint8Array(address));
                } catch (error) {
                    console.error('Failed to decode address:', error);
                    return '';
                }
            } else {
                console.error('Unknown address format:', address);
                return '';
            }
        }

        const confirmOrder = flow(function* (
            orderId: number,
            signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>
        ) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::core::confirm_order_v2`,
                        typeArguments: [],
                        functionArguments: [orderId.toString()],
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('Order confirmed successfully');
            } catch (error) {
                console.error('Error confirming order:', error);
                if (error instanceof Error) {
                    message.error(`Failed to confirm order: ${error.message}`);
                } else {
                    message.error('Failed to confirm order');
                }
            }
        });

        return {
            setLoading,
            createOrder,
            getUserOrders,
            confirmOrder,
        };
    });

export type IOrderStore = Instance<typeof OrderStore>;
import { types, flow, Instance } from 'mobx-state-tree';
import { message } from 'antd';
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import { InputTransactionData } from '@aptos-labs/wallet-adapter-core';

export const User = types.model('User', {
    address: types.string,
    email: types.string,
    isActive: types.boolean,
    isCourier: types.boolean,
    balance: types.number,
    timestamp: types.number // Added timestamp field
});

export const UserStore = types
    .model('UserStore', {
        currentUser: types.maybe(User),
        isLoading: types.boolean,
    })
    .actions((self) => {
        const setCurrentUser = (user: typeof User.Type | undefined) => {
            self.currentUser = user;
        };

        const setLoading = (loading: boolean) => {
            self.isLoading = loading;
        };

        const registerUser = flow(function* (email: string, isCourier: boolean, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::user_management::register_user`,
                        typeArguments: [],
                        functionArguments: [email, isCourier], // Directly pass boolean value
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('User registration successful');
                // May need to update user list here
                // yield fetchUsers(client, moduleAddress);
            } catch (error) {
                console.error('Error during registration', error);
                if (error instanceof Error) {
                    message.error(`User registration failed: ${error.message}`);
                } else {
                    message.error('User registration failed');
                }
            }
        });

        const getUserInfo = flow(function* (address: string) {
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
                        function: `${moduleAddress}::user_management::get_user_info_view_v2`,
                        typeArguments: [],
                        functionArguments: [address]
                    },
                });

                const [emailHex, isActive, isCourier, balance] = response;
                
                let email;
                if (typeof emailHex === 'string' && emailHex.startsWith('0x')) {
                    const bytes = new Uint8Array(emailHex.slice(2).match(/.{1,2}/g)!.map(byte => parseInt(byte, 16)));
                    email = new TextDecoder().decode(bytes);
                }
                
                return User.create({
                    address,
                    email: email || '',
                    isActive,
                    isCourier,
                    balance: Number(balance), // Convert balance to number
                    timestamp: Date.now() // Use current timestamp as contract doesn't return this information
                });
            } catch (error) {
                console.error('Failed to get user information:', error);
                message.error('Failed to get user information');
                return undefined;
            } finally {
                self.isLoading = false;
            }
        });

        return {
            setCurrentUser,
            setLoading,
            registerUser,
            getUserInfo,
        };
    });

export type IUserStore = Instance<typeof UserStore>;
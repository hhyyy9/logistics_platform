import { types, flow, Instance } from 'mobx-state-tree';
import { message } from 'antd';
import { InputTransactionData } from '@aptos-labs/wallet-adapter-core';
import { AptosClient } from 'aptos';

const User = types.model({
    address: types.string,
    email: types.string,
    isActive: types.boolean
});

export const UserStore = types
    .model({
        users: types.array(User),
        totalUsers: types.number,
        activeUsers: types.number
    })
    .views((self) => ({
        get averageActiveRate() {
            return self.totalUsers > 0 ? self.activeUsers / self.totalUsers : 0;
        },
    }))
    .actions((self) => {
        const setUsers = (users: Instance<typeof User>[]) => {
            self.users.replace(users);
            self.totalUsers = users.length;
            self.activeUsers = users.filter((user) => user.isActive).length;
        };

        const addUser = (user: Instance<typeof User>) => {
            self.users.push(user);
            self.totalUsers += 1;
            if (user.isActive) self.activeUsers += 1;
        };

        const updateUser = (address: string, email: string, isActive: boolean) => {
            const user = self.users.find((u) => u.address === address);
            if (user) {
                if (user.isActive !== isActive) {
                    self.activeUsers += isActive ? 1 : -1;
                }
                user.email = email;
                user.isActive = isActive;
            }
        };

        const fetchUsers = flow(function* (client: AptosClient, moduleAddress: string) {

        });

        const registerUser = flow(function* (email: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::user_management::register_user`,
                        typeArguments: [],
                        functionArguments: [email],
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('用户注册成功');
                // 这里可能需要更新用户列表
                // yield fetchUsers(client, moduleAddress);
            } catch (error) {
                console.error('注册过程中出错', error);
                if (error instanceof Error) {
                    message.error(`用户注册失败: ${error.message}`);
                } else {
                    message.error('用户注册失败');
                }
            }
        });

        const updateUserInfo = flow(function* (newEmail: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::user_management::update_user_info`,
                        typeArguments: [],
                        functionArguments: [newEmail],
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('用户信息更新成功');
                // 这里可能需要更新本地用户信息
                // yield fetchUsers(client, moduleAddress);
            } catch (error) {
                message.error('用户信息更新失败');
                console.error(error);
            }
        });

        const deactivateUser = flow(function* (address: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::user_management::deactivate_user`,
                        typeArguments: [],
                        functionArguments: [address],
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('用户已停用');
                updateUser(address, self.users.find(u => u.address === address)?.email || '', false);
            } catch (error) {
                message.error('用户停用失败');
                console.error('停用用户时出错:', error);
            }
        });

        const reactivateUser = flow(function* (address: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
            try {
                const moduleAddress = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
                if (!moduleAddress) {
                    throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
                }

                const payload: InputTransactionData = {
                    data: {
                        function: `${moduleAddress}::user_management::reactivate_user`,
                        typeArguments: [],
                        functionArguments: [address],
                    },
                };
                yield signAndSubmitTransaction({ payload });
                message.success('用户已重新激活');
                updateUser(address, self.users.find(u => u.address === address)?.email || '', true);
            } catch (error) {
                message.error('用户重新激活失败');
                console.error('重新激活用户时出错:', error);
            }
        });

        return {
            setUsers,
            addUser,
            updateUser,
            fetchUsers,
            registerUser,
            updateUserInfo,
            deactivateUser,
            reactivateUser,
        };
    });

export interface IUserStore extends Instance<typeof UserStore> {}
export default UserStore;
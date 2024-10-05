import { types, flow, Instance } from 'mobx-state-tree';
import { message } from 'antd';
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

export const StatisticsStore = types
    .model('StatisticsStore', {
        totalOrders: types.number,
        totalUsers: types.number,
        totalDeliveryAmount: types.number,
        totalTransactionAmount: types.number,
        isLoading: types.optional(types.boolean, false),
    })
    .actions((self) => {
        const setStats = (stats: Partial<typeof self>) => {
            Object.assign(self, stats);
        };

        const fetchPlatformStats = flow(function* () {
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
                        function: `${moduleAddress}::statistics::get_platform_stats`,
                        typeArguments: [],
                        functionArguments: []
                    },
                });
                
                const [
                    totalOrders,
                    totalUsers,
                    totalDeliveryAmount,
                    totalTransactionAmount
                ] = response;

                setStats({
                    totalOrders: Number(totalOrders),
                    totalUsers: Number(totalUsers),
                    totalDeliveryAmount: Number(totalDeliveryAmount),
                    totalTransactionAmount: Number(totalTransactionAmount),
                });
            } catch (error) {
                console.error("Failed to fetch platform stats:", error);
                message.error('Failed to fetch platform statistics');
            } finally {
                self.isLoading = false;
            }
        });

        return {
            setStats,
            fetchPlatformStats,
        };
    });

export interface IStatisticsStore extends Instance<typeof StatisticsStore> {}
export default StatisticsStore;
import { types, flow, Instance } from 'mobx-state-tree'
import { UserStore } from './UserStore'
import { CourierStore } from './CourierStore'
import { OrderStore } from './OrderStore'
import { FinanceStore } from './FinanceStore'
import { StatisticsStore } from './StatisticsStore'
import { createContext, useContext } from 'react';
import { InputTransactionData } from '@aptos-labs/wallet-adapter-core';
import { message } from 'antd';

export const RootStore = types.model('RootStore', {
  isInitialized: types.optional(types.boolean, true), //TODO: set true by defult for testing
  userStore: types.optional(UserStore, { totalUsers: 0, activeUsers: 0 }),
  courierStore: types.optional(CourierStore, { totalCouriers: 0, activeCouriers: 0 }),
  orderStore: types.optional(OrderStore, { totalOrders: 0, completedOrders: 0 }),
  financeStore: types.optional(FinanceStore, { totalRevenue: 0, totalExpenses: 0 }),
  statisticsStore: types.optional(StatisticsStore, {
    totalOrders: 0,
    totalCouriers: 0,
    totalUsers: 0,
    totalRevenue: 0,
    acceptedOrders: 0,
    completedOrders: 0,
    cancelledOrders: 0,
    totalDeliveryFees: 0,
    totalServiceFees: 0
  })
})
.actions(self => ({
  connectWallet: flow(function* (connect, wallet, wallets) {
    console.log("Attempting to connect wallet");
    console.log("Available wallets:", wallets);
    console.log("Selected wallet:", wallet);

    if (!wallets || wallets.length === 0) {
      console.error('没有可用的钱包');
      return;
    }

    try {
      if (wallet) {
        yield connect(wallet.name);
      } else if (wallets.length > 0) {
        yield connect(wallets[0].name);
      } else {
        throw new Error("No wallet available");
      }
      console.log('钱包连接成功');
    } catch (error) {
      console.error("连接钱包时出错:", error);
    }
  }),

  initializeContract: flow(function* (signAndSubmitTransaction: (transaction: InputTransactionData) => Promise<any>) {
    const moduleAddress: string = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
    if (!moduleAddress) {
      throw new Error("REACT_APP_MOVE_MODULE_ADDRESS 未定义");
    }

    if (self.isInitialized) {
      console.log('合约已经初始化，跳过初始化步骤');
      return;
    }

    try {
      const payload: InputTransactionData = {
        data: {
          function: `${moduleAddress}::core::initialize`,
          typeArguments: [],
          functionArguments: [],
        },
      };
      console.log('准备初始化合约', JSON.stringify(payload, null, 2));
      
      try {
        const result = yield signAndSubmitTransaction(payload);
        console.log('合约初始化结果:', JSON.stringify(result, null, 2));
        self.isInitialized = true;
        message.success('合约初始化成功');
      } catch (txError) {
        throw txError;
      }
    } catch (error) {
      console.error('合约初始化过程中出错', error);
      if (error instanceof Error) {
        message.error(`合约初始化失败: ${error.message}`);
      } else {
        message.error('合约初始化失败');
      }
      throw error;
    }
  }),
}))

const RootStoreContext = createContext<Instance<typeof RootStore> | null>(null);

export const RootStoreProvider = RootStoreContext.Provider;

export function useRootStore() {
  const store = useContext(RootStoreContext);
  if (store === null) {
    throw new Error("Store cannot be null, please add a context provider");
  }
  return store;
}
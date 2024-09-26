import { types, Instance } from 'mobx-state-tree'
import { UserStore } from './UserStore'
import { CourierStore } from './CourierStore'
import { OrderStore } from './OrderStore'
import { FinanceStore } from './FinanceStore'
import { StatisticsStore } from './StatisticsStore'
import { createContext, useContext } from 'react';
import { AppStore } from './AppStore';

export const RootStore = types.model('RootStore', {
  userStore: types.optional(UserStore, { totalUsers: 0, activeUsers: 0 }),
  courierStore: types.optional(CourierStore, { totalCouriers: 0, activeCouriers: 0 }),
  orderStore: types.optional(OrderStore, { totalOrders: 0, completedOrders: 0   }),
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
  }),
  appStore: types.optional(AppStore, {}),
})

const RootStoreContext = createContext<Instance<typeof RootStore> | null>(null);

export const RootStoreProvider = RootStoreContext.Provider;

export function useRootStore() {
  const store = useContext(RootStoreContext);
  if (store === null) {
    throw new Error("Store cannot be null, please add a context provider");
  }
  return store;
}
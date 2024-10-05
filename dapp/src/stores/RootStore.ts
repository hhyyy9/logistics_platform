import { types, Instance } from 'mobx-state-tree'
import { createContext, useContext } from 'react'
import { UserStore } from './UserStore'
import { StatisticsStore } from './StatisticsStore'
import { OrderStore } from './OrderStore'
export const RootStore = types.model('RootStore', {
  userStore: types.optional(UserStore, {
    currentUser: undefined,
    isLoading: false
  }),
  statisticsStore: types.optional(StatisticsStore, {
    totalOrders: 0,
    totalUsers: 0,
    totalDeliveryAmount: 0,
    totalTransactionAmount: 0,
    isLoading: false
  }),
  orderStore: types.optional(OrderStore, {
    isLoading: false,
    userOrders: []
  }),
  currentUserAddress: types.optional(types.string, '')
})
.actions(self => ({
  setCurrentUserAddress(address: string) {
    self.currentUserAddress = address;
  }
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
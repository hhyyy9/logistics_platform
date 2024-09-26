import { types } from 'mobx-state-tree'

export const OrderStore = types.model('OrderStore', {
    totalOrders: types.number,
    completedOrders: types.number,
})
.views(self => ({
    get completionRate() {
        return self.completedOrders / self.totalOrders;
    }
}))
.actions(self => ({
    setTotalOrders(total: number) {
        self.totalOrders = total;
    },
    setCompletedOrders(completed: number) {
        self.completedOrders = completed;
    }
}))
.actions(self => ({
    fetchOrderStats() {
        // 在这里添加获取订单统计数据的逻辑
    }
}))
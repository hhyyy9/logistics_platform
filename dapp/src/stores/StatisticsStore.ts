import { types } from 'mobx-state-tree'

export const StatisticsStore = types.model('StatisticsStore', {
    totalOrders: types.number,
    totalCouriers: types.number,
    totalUsers: types.number,
    totalRevenue: types.number,
    acceptedOrders: types.number,
    completedOrders: types.number,
    cancelledOrders: types.number,
    totalDeliveryFees: types.number,
    totalServiceFees: types.number,
})
.views(self => ({
    // 这里可以添加计算属性
    get getTotalOrders() {
        return 100;
    },

}))
.actions(self => ({
    // 这里可以添加修改状态的操作
    fetchPlatformStats() {
        // 在这里添加你的fetchPlatformStats逻辑
    }
}))
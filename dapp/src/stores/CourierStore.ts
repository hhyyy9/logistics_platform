import { types } from 'mobx-state-tree'

export const CourierStore = types.model('CourierStore', {
    totalCouriers: types.number,
    activeCouriers: types.number,
})
.views(self => ({
    get averageActiveRate() {
        return self.activeCouriers / self.totalCouriers;
    }
}))
.actions(self => ({
    setTotalCouriers(total: number) {
        self.totalCouriers = total;
    },
    setActiveCouriers(active: number) {
        self.activeCouriers = active;
    }
}))
.actions(self => ({
    fetchCourierStats() {
        // 在这里添加获取快递员统计数据的逻辑
    }
}))
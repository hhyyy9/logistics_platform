import { types } from 'mobx-state-tree'

export const FinanceStore = types.model('FinanceStore', {
    totalRevenue: types.number,
    totalExpenses: types.number,
})
.views(self => ({
    get profit() {
        return self.totalRevenue - self.totalExpenses;
    }
}))
.actions(self => ({
    setTotalRevenue(revenue: number) {
        self.totalRevenue = revenue;
    },
    setTotalExpenses(expenses: number) {
        self.totalExpenses = expenses;
    }
}))
.actions(self => ({
    fetchFinanceStats() {
        // 在这里添加获取财务统计数据的逻辑
    }
}))
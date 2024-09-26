import { types } from 'mobx-state-tree'

export const UserStore = types.model('UserStore', {
    totalUsers: types.number,
    activeUsers: types.number,
})
.views(self => ({
    get averageActiveRate() {
        return self.activeUsers / self.totalUsers;
    }
}))
.actions(self => ({
    setTotalUsers(total: number) {
        self.totalUsers = total;
    },
    setActiveUsers(active: number) {
        self.activeUsers = active;
    },
    fetchUserStats() {
        // 在这里添加获取用户统计数据的逻辑
    }
}))
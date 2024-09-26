import React from 'react';
import { observer } from 'mobx-react-lite';
import { useRootStore } from '../stores/RootStore';

const UserManagement = observer(() => {
  const { userStore } = useRootStore();

  return (
    <div>
      <h1>用户管理</h1>
      <p>总用户数：{userStore.totalUsers}</p>
      <p>活跃用户数：{userStore.activeUsers}</p>
      <p>平均活跃率：{userStore.averageActiveRate.toFixed(2)}</p>
      {/* 这里添加更多用户管理相关的组件和功能 */}
    </div>
  );
});

export default UserManagement;
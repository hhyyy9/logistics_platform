import React from 'react';
import { observer } from 'mobx-react';
import { useRootStore } from '../stores/RootStore';

const CourierManagement = observer(() => {
  const { courierStore } = useRootStore();
    
    return (
      <div>
        <h1>快递员管理</h1>
        {/* 这里添加快递员管理相关的组件和功能 */}
      </div>
    );
  });

export default CourierManagement;
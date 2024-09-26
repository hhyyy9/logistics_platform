import React from 'react';
import { Typography } from 'antd';
import { ExclamationCircleOutlined } from '@ant-design/icons';

const WalletConnectionPrompt: React.FC = () => (
  <div style={{ textAlign: 'center', marginTop: '50px' }}>
    <Typography.Title level={3}>
      <ExclamationCircleOutlined style={{ marginRight: '8px', color: '#faad14' }} />
      请点击右上角连接您的钱包
    </Typography.Title>
  </div>
);

export default WalletConnectionPrompt;
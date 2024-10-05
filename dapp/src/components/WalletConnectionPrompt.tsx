import React from 'react';
import { Typography } from 'antd';
import { ExclamationCircleOutlined } from '@ant-design/icons';

const WalletConnectionPrompt: React.FC = () => (
  <div style={{ textAlign: 'center', marginTop: '50px' }}>
    <Typography.Title level={3}>
      <ExclamationCircleOutlined style={{ marginRight: '8px', color: '#faad14' }} />
      Please click the top right corner to connect your wallet
    </Typography.Title>
  </div>
);

export default WalletConnectionPrompt;
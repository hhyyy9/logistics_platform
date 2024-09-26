import React, { useEffect } from 'react';
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Button, Typography, Space, Avatar } from 'antd';
import { WalletOutlined, UserOutlined } from '@ant-design/icons';

const { Text } = Typography;

function WalletConnector() {
  const {
    connect,
    account,
    connected,
    wallet,
    wallets,
  } = useWallet();

  useEffect(() => {
    console.log("Wallet state:", { wallet, wallets, connected });
  }, [wallet, wallets, connected]);

  const handleConnect = async () => {
    console.log("Attempting to connect wallet");
    console.log("Available wallets:", wallets);
    console.log("Selected wallet:", wallet);

    if (!wallets || wallets.length === 0) {
      console.error('没有可用的钱包');
      return;
    }

    try {
      if (wallet) {
        await connect(wallet.name);
      } else if (wallets.length > 0) {
        await connect(wallets[0].name);
      } else {
        throw new Error("No wallet available");
      }
      console.log('钱包连接成功');
    } catch (error) {
      console.error("连接钱包时出错:", error);
    }
  };

  if (connected && account) {
    const shortAddress = `${account.address.slice(0, 6)}...${account.address.slice(-4)}`;
    return (
      <Space align="center">
        <Avatar 
          icon={<UserOutlined />} 
          style={{ backgroundColor: '#1890ff' }}
        />
        <div style={{ 
          background: '#f0f2f5', 
          padding: '4px 12px', 
          borderRadius: '16px',
          display: 'flex',
          alignItems: 'center'
        }}>
          <Text strong style={{ marginRight: '8px' }}>
            {wallet?.name || 'Wallet'}
          </Text>
          <Text 
            copyable={{ text: account.address }}
            style={{ 
              color: '#1890ff',
              cursor: 'pointer',
            }}
          >
            {shortAddress}
          </Text>
        </div>
      </Space>
    );
  }

  return (
    <Button 
      type="primary" 
      icon={<WalletOutlined />} 
      onClick={handleConnect}
      size="large"
    >
      连接钱包 {wallets ? `(${wallets.length})` : '(0)'}
    </Button>
  );
}

export default WalletConnector;
import React, { useEffect } from 'react';
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Button, Typography, Space, Avatar } from 'antd';
import { WalletOutlined, UserOutlined } from '@ant-design/icons';
import { useRootStore } from '../stores/RootStore';

const { Text } = Typography;

function WalletConnector() {
  const {
    connect,
    account,
    connected,
    wallet,
    wallets,
    signAndSubmitTransaction
  } = useWallet();

  const rootStore = useRootStore();

  useEffect(() => {
    console.log("Wallet status:", { wallet, wallets, connected });
    if (connected && account) {
      rootStore.setCurrentUserAddress(account.address);
    }
  }, [connected, wallet, wallets, signAndSubmitTransaction, rootStore, account]);

  const handleConnect = async () => {
    if (wallet) {
      await connect(wallet.name);
    } else if (wallets && wallets.length > 0) {
      await connect(wallets[0].name);
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
      Connect Wallet {wallets ? `(${wallets.length})` : '(0)'}
    </Button>
  );
}

export default WalletConnector;
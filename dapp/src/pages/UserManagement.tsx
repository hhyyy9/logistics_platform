import React, { useState } from 'react';
import { observer } from 'mobx-react-lite';
import { useRootStore } from '../stores/RootStore';
import { Form, Input, Button, Spin, Switch, Divider } from 'antd';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import WalletConnectionPrompt from '../components/WalletConnectionPrompt';
import { User } from '../stores/UserStore';
import { Instance } from 'mobx-state-tree';

const UserManagement = observer(() => {
  const { userStore } = useRootStore();
  const { account, signAndSubmitTransaction } = useWallet();
  const [userInfo, setUserInfo] = useState<Instance<typeof User> | undefined>(undefined);


  if (!account) {
    return <WalletConnectionPrompt />;
  }

  const handleRegister = async (values: { email: string, isCourier: boolean }) => {
    try {
      await userStore.registerUser(values.email, values.isCourier, ({ payload }) => signAndSubmitTransaction(payload));
    } catch (error) {
      console.error('Error during registration', error);
    }
  };

  const handleGetUserInfo = async (values: { address: string }) => {
    const info = await userStore.getUserInfo(values.address);
    setUserInfo(info);
  };

  return (
    <div>
      <h1>User Management</h1>
      
      {!userInfo && (
        <>
          <h2>Register User</h2>
          <Form onFinish={handleRegister}>
            <Form.Item name="email" rules={[{ required: true, message: 'Please enter email' }]}>
              <Input placeholder="Email" />
            </Form.Item>
            <Form.Item name="isCourier" valuePropName="checked" initialValue={false}>
              <Switch checkedChildren="Courier" unCheckedChildren="Regular User" />
            </Form.Item>
            <Form.Item>
              <Button type="primary" htmlType="submit">Register</Button>
            </Form.Item>
          </Form>
        </>
      )}
      <Divider />

      <h2>Get User Information</h2>
      <Form onFinish={handleGetUserInfo}>
        <Form.Item name="address" rules={[{ required: true, message: 'Please enter user address' }]}>
          <Input placeholder="User Address" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">Get Info</Button>
        </Form.Item>
      </Form>

      {userStore.isLoading ? (
        <Spin />
      ) : userInfo ? (
        <div>
          <h3>User Information</h3>
          <p>Address: {userInfo.address}</p>
          <p>Email: {userInfo.email}</p>
          <p>Status: {userInfo.isActive ? 'Active' : 'Inactive'}</p>
          <p>Type: {userInfo.isCourier ? 'Courier' : 'Regular User'}</p>
          <p>Balance: {userInfo.balance}</p>
          <p>Last Updated: {new Date(userInfo.timestamp).toLocaleString()}</p>
        </div>
      ) : (
        <p>User information not found</p>
      )}
    </div>
  );
});

export default UserManagement;
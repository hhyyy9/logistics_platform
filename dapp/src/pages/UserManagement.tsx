import React from 'react';
import { observer } from 'mobx-react-lite';
import { useRootStore } from '../stores/RootStore';
import { Form, Input, Button, List, message } from 'antd';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import WalletConnectionPrompt from '../components/WalletConnectionPrompt';

const UserManagement = observer(() => {
  const { userStore } = useRootStore();
  const { account, signAndSubmitTransaction } = useWallet();

  console.log('当前账户状态:', account);

  if (!account) {
    return <WalletConnectionPrompt />;
  }

  const handleRegister = async (values: { email: string }) => {
    try {
      await userStore.registerUser(values.email, ({ payload }) => signAndSubmitTransaction(payload));
      message.success('用户注册成功');
    } catch (error) {
      console.error('注册过程中出错', error);
      message.error('用户注册失败');
    }
  };

  const handleUpdateInfo = async (values: { email: string }) => {
    try {
      await userStore.updateUserInfo(values.email, ({ payload }) => signAndSubmitTransaction(payload));
      message.success('用户信息更新成功');
    } catch (error) {
      console.error('更新过程中出错', error);
      message.error('用户信息更新失败');
    }
  };

  const handleDeactivateUser = async (values: { address: string }) => {
    try {
      await userStore.deactivateUser(values.address, ({ payload }) => signAndSubmitTransaction(payload));
      message.success('用户已停用');
    } catch (error) {
      console.error('停用过程中出错', error);
      message.error('停用用户失败');
    }
  };

  const handleReactivateUser = async (values: { address: string }) => {
    try {
      await userStore.reactivateUser(values.address, ({ payload }) => signAndSubmitTransaction(payload));
      message.success('用户已重新激活');
    } catch (error) {
      console.error('重新激活过程中出错', error);
      message.error('重新激活用户失败');
    }
  };

  return (
    <div>
      <h1>用户管理</h1>
      
      <h2>注册用户</h2>
      <Form onFinish={handleRegister}>
        <Form.Item name="email" rules={[{ required: true, message: '请输入邮箱' }]}>
          <Input placeholder="邮箱" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">注册</Button>
        </Form.Item>
      </Form>

      <h2>更新用户信息</h2>
      <Form onFinish={handleUpdateInfo}>
        <Form.Item name="email" rules={[{ required: true, message: '请输入新邮箱' }]}>
          <Input placeholder="新邮箱" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">更新</Button>
        </Form.Item>
      </Form>

      <h2>停用用户</h2>
      <Form onFinish={handleDeactivateUser}>
        <Form.Item name="address" rules={[{ required: true, message: '请输入用户地址' }]}>
          <Input placeholder="用户地址" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">停用</Button>
        </Form.Item>
      </Form>

      <h2>重新激活用户</h2>
      <Form onFinish={handleReactivateUser}>
        <Form.Item name="address" rules={[{ required: true, message: '请输入用户地址' }]}>
          <Input placeholder="用户地址" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">重新激活</Button>
        </Form.Item>
      </Form>

      <h2>用户列表</h2>
      <List
        bordered
        dataSource={userStore.users}
        renderItem={user => (
          <List.Item>
            {user.address} - {user.email} - {user.isActive ? '活跃' : '已停用'}
          </List.Item>
        )}
      />
    </div>
  );
});

export default UserManagement;
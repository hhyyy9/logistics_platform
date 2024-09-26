import React from 'react';
import { observer } from 'mobx-react';
import { useRootStore } from '../stores/RootStore';
import { Form, Input, Button } from 'antd';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import WalletConnectionPrompt from '../components/WalletConnectionPrompt';

const CourierManagement = observer(() => {
  const { courierStore } = useRootStore();
  const { account, signAndSubmitTransaction } = useWallet();

  console.log('当前账户状态:', account);

  if (!account) {
    return <WalletConnectionPrompt />;
  }

  const registerCourier = async (values: { email: string }) => {
    console.log('registerCourier 被调用', values);
    try {
      await courierStore.registerCourier(values.email, ({ payload }) => signAndSubmitTransaction(payload));
      console.log('注册成功');
    } catch (error) {
      console.error('注册过程中出错', error);
    }
  };

  const updateCourierInfo = async (values: { email: string }) => {
    if (!account) return;
    await courierStore.updateCourierInfo(values.email, ({ payload }) => signAndSubmitTransaction(payload));
  };

  const deactivateCourier = async (values: { address: string }) => {
    if (!account) return;
    await courierStore.deactivateCourier(values.address, ({ payload }) => signAndSubmitTransaction(payload));
  };

  return (
    <div>
      <h1>快递员管理</h1>
      <h2>注册快递员</h2>
      <Form onFinish={registerCourier}>
        <Form.Item name="email" rules={[{ required: true, message: '请输入邮箱' }]}>
          <Input placeholder="邮箱" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">注册</Button>
        </Form.Item>
      </Form>

      <h2>更新快递员信息</h2>
      <Form onFinish={updateCourierInfo}>
        <Form.Item name="email" rules={[{ required: true, message: '请输入新邮箱' }]}>
          <Input placeholder="新邮箱" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">更新</Button>
        </Form.Item>
      </Form>

      <h2>停用快递员</h2>
      <Form onFinish={deactivateCourier}>
        <Form.Item name="address" rules={[{ required: true, message: '请输入快递员地址' }]}>
          <Input placeholder="快递员地址" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">停用</Button>
        </Form.Item>
      </Form>
    </div>
  );
});

export default CourierManagement;
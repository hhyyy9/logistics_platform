import React, { useState } from 'react';
import { observer } from 'mobx-react-lite';
import { useRootStore } from '../stores/RootStore';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import WalletConnectionPrompt from '../components/WalletConnectionPrompt';
import { List, Card, Tag, Typography, Space, Button, Descriptions } from 'antd';
import { ShoppingOutlined, EnvironmentOutlined, DollarOutlined, ClockCircleOutlined } from '@ant-design/icons';
import { Form, Input, InputNumber, Divider, Spin } from 'antd';

const OrderManagement = observer(() => {
  const { orderStore } = useRootStore();
  const { account, signAndSubmitTransaction } = useWallet();
  const [searchAddress, setSearchAddress] = useState('');


  if (!account) {
    return <WalletConnectionPrompt />;
  }

  const handleCreateOrder = async (values: {
    recipient: string;
    courier: string;
    pickupAddress: string;
    deliveryAddress: string;
    amount: number;
  }) => {
    try {
      await orderStore.createOrder(
        values.recipient,
        values.courier,
        values.pickupAddress,
        values.deliveryAddress,
        values.amount,
        ({ payload }) => signAndSubmitTransaction(payload)
      );
    } catch (error) {
      console.error('Error occurred while creating order', error);
    }
  };

  const handleSearchOrders = () => {
    if (searchAddress) {
      orderStore.getUserOrders(searchAddress);
    }
  };

  const handleConfirmOrder = async (orderId: number) => {
    try {
      await orderStore.confirmOrder(
        orderId,
        ({ payload }) => signAndSubmitTransaction(payload)
      );
      // Refresh order list
      handleSearchOrders();
    } catch (error) {
      console.error('Error occurred while confirming order', error);
    }
  };

  return (
    <div>
      <h1>Order Management</h1>
      
      <h2>Create Order</h2>
      <Form onFinish={handleCreateOrder}>
        <Form.Item name="recipient" rules={[{ required: true, message: 'Please enter recipient address' }]}>
          <Input placeholder="Recipient Address" />
        </Form.Item>
        <Form.Item name="courier" rules={[{ required: true, message: 'Please enter courier address' }]}>
          <Input placeholder="Courier Address" />
        </Form.Item>
        <Form.Item name="pickupAddress" rules={[{ required: true, message: 'Please enter pickup address' }]}>
          <Input placeholder="Pickup Address" />
        </Form.Item>
        <Form.Item name="deliveryAddress" rules={[{ required: true, message: 'Please enter delivery address' }]}>
          <Input placeholder="Destination Address" />
        </Form.Item>
        <Form.Item name="amount" rules={[{ required: true, message: 'Please enter amount' }]}>
          <InputNumber placeholder="Amount" />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit">Create Order</Button>
        </Form.Item>
      </Form>
      <Divider />

      <h2>Query Order List</h2>
      <div className="search-row">
        <Input
          placeholder="Enter address to query orders"
          value={searchAddress}
          onChange={(e) => setSearchAddress(e.target.value)}
          style={{ width: 600, marginRight: 10, marginBottom: 10 }}
        />
        <Button onClick={handleSearchOrders} type="primary">Search</Button>
      </div>
      
      {orderStore.isLoading ? (
        <Spin />
      ) : (
        <List
          grid={{ gutter: 16, column: 1 }}
          dataSource={orderStore.userOrders}
          renderItem={order => (
            <List.Item>
              <Card
                title={
                  <Space>
                    <ShoppingOutlined />
                    <Typography.Text strong>{`Order #${order.orderId}`}</Typography.Text>
                    <Tag color={order.status === 0 ? 'blue' : 'green'}>
                      {order.status === 0 ? 'Pending' : 'Completed'}
                    </Tag>
                  </Space>
                }
                extra={
                  order.status === 0 && (
                    <Button type="primary" onClick={() => handleConfirmOrder(order.orderId)}>
                      Confirm Order
                    </Button>
                  )
                }
              >
                <Descriptions column={2}>
                  <Descriptions.Item label="Recipient">{order.recipient}</Descriptions.Item>
                  <Descriptions.Item label="Courier">{order.courier}</Descriptions.Item>
                  <Descriptions.Item label={<><EnvironmentOutlined /> Pickup Address</>}>
                    {order.pickupAddress}
                  </Descriptions.Item>
                  <Descriptions.Item label={<><EnvironmentOutlined /> Delivery Address</>}>
                    {order.deliveryAddress}
                  </Descriptions.Item>
                  <Descriptions.Item label={<><DollarOutlined /> Amount</>}>
                    {order.amount}
                  </Descriptions.Item>
                  <Descriptions.Item label={<><ClockCircleOutlined /> Created At</>}>
                    {new Date(order.createdAt * 1000).toLocaleString()}
                  </Descriptions.Item>
                </Descriptions>
              </Card>
            </List.Item>
          )}
        />
      )}
    </div>
  );
});

export default OrderManagement;
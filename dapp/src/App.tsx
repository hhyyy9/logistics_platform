import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route, Routes, Link } from "react-router-dom";
import {
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  HomeOutlined,
  UserOutlined,
  ShoppingCartOutlined,
} from "@ant-design/icons";
import { Button, Layout, Menu, theme, Typography } from "antd";
import Home from "./pages/Home";
import UserManagement from "./pages/UserManagement";
import OrderManagement from "./pages/OrderManagement";
import WalletConnector from "./components/WalletConnector";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { Network } from '@aptos-labs/ts-sdk';
import { useLocation } from 'react-router-dom';

const { Header, Sider, Content } = Layout;
const { Title } = Typography;

const wallets = [new PetraWallet()];

const App: React.FC = () => {
  return (
    <AptosWalletAdapterProvider
      plugins={wallets}
      autoConnect={false}
      optInWallets={["Petra"]}
      dappConfig={{ network: Network.DEVNET, aptosConnectDappId: "test-dapp-id" }}
    >
      <Router>
        <AppContent />
      </Router>
    </AptosWalletAdapterProvider>
  );
};

const AppContent: React.FC = () => {
  const [collapsed, setCollapsed] = useState(false);
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  const menuItems = [
    {
      key: "1",
      icon: <HomeOutlined />,
      label: <Link to="/">Home</Link>,
    },
    {
      key: "2",
      icon: <UserOutlined />,
      label: <Link to="/user">User Management</Link>,
    },
    {
      key: "4",
      icon: <ShoppingCartOutlined />,
      label: <Link to="/order">Order Management</Link>,
    }
  ];

  const location = useLocation();
  const [selectedKey, setSelectedKey] = useState('1');

  useEffect(() => {
    const path = location.pathname;
    if (path === '/') setSelectedKey('1');
    else if (path === '/user') setSelectedKey('2');
    else if (path === '/order') setSelectedKey('4');
  }, [location]);

  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sider trigger={null} collapsible collapsed={collapsed}>
        <div
          style={{
            height: "64px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            background: "#001529",
            marginBottom: "16px",
          }}
        >
          <Title level={4} style={{ color: "#fff", margin: 0 }}>
            {collapsed ? "LS" : "Logistics System"}
          </Title>
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[selectedKey]}
          items={menuItems}
        />
      </Sider>
      <Layout>
        <Header
          style={{
            padding: 0,
            background: colorBgContainer,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <Button
            type="text"
            icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
            onClick={() => setCollapsed(!collapsed)}
            style={{
              fontSize: "16px",
              width: 64,
              height: 64,
            }}
          />
          <div style={{ marginRight: "24px" }}>
            <WalletConnector />
          </div>
        </Header>
        <Content
          style={{
            margin: "24px 16px",
            padding: 24,
            minHeight: 280,
            background: colorBgContainer,
            borderRadius: borderRadiusLG,
          }}
        >
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/user" element={<UserManagement />} />
            <Route path="/order" element={<OrderManagement />} />
          </Routes>
        </Content>
      </Layout>
    </Layout>
  );
};

export default App;

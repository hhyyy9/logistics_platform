import React, { useState } from "react";
import { BrowserRouter as Router, Route, Routes, Link } from "react-router-dom";
import {
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  HomeOutlined,
  UserOutlined,
  ShoppingCartOutlined,
  DollarOutlined,
} from "@ant-design/icons";
import { Button, Layout, Menu, theme, Typography } from "antd";
import Home from "./pages/Home";
import UserManagement from "./pages/UserManagement";
import CourierManagement from "./pages/CourierManagement";
import OrderManagement from "./pages/OrderManagement";
import Finance from "./pages/Finance";
import WalletConnector from "./components/WalletConnector";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { Network } from '@aptos-labs/ts-sdk';

const { Header, Sider, Content } = Layout;
const { Title } = Typography;

const wallets = [new PetraWallet()];

const App: React.FC = () => {
  const [collapsed, setCollapsed] = useState(false);
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  const menuItems = [
    {
      key: "1",
      icon: <HomeOutlined />,
      label: <Link to="/">首页</Link>,
    },
    {
      key: "2",
      icon: <UserOutlined />,
      label: <Link to="/user">用户管理</Link>,
    },
    {
      key: "3",
      icon: <UserOutlined />,
      label: <Link to="/courier">快递员管理</Link>,
    },
    {
      key: "4",
      icon: <ShoppingCartOutlined />,
      label: <Link to="/order">订单管理</Link>,
    },
    {
      key: "5",
      icon: <DollarOutlined />,
      label: <Link to="/finance">财务</Link>,
    },
  ];

  return (
    <AptosWalletAdapterProvider
      plugins={wallets}
      autoConnect={false}
      optInWallets={["Petra"]}
      dappConfig={{ network: Network.DEVNET, aptosConnectDappId: "test-dapp-id" }}
    >
      <Router>
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
                {collapsed ? "LMS" : "物流管理系统"}
              </Title>
            </div>
            <Menu
              theme="dark"
              mode="inline"
              defaultSelectedKeys={["1"]}
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
                <Route path="/courier/*" element={<CourierManagement />} />
                <Route path="/order" element={<OrderManagement />} />
                <Route path="/finance" element={<Finance />} />
              </Routes>
            </Content>
          </Layout>
        </Layout>
      </Router>
    </AptosWalletAdapterProvider>
  );
};

export default App;

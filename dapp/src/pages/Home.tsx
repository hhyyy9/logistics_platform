import React, { useEffect } from "react";
import { observer } from "mobx-react";
import { useRootStore } from "../stores/RootStore";
import { Card, Statistic, Row, Col, Spin } from "antd";

const Home = observer(() => {
  const { statisticsStore } = useRootStore();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        await statisticsStore.fetchPlatformStats();
      } catch (error) {
        console.error("Error fetching platform statistics:", error);
        // You can add user-friendly error messages here
      }
    };
    fetchStats();
  }, [statisticsStore]);

  if (statisticsStore.isLoading) {
    return <Spin size="large" />;
  }

  return (
    <div>
      <h1>Platform Statistics</h1>
      <Row gutter={16}>
        <Col span={6}>
          <Card>
            <Statistic title="Total Orders" value={statisticsStore.totalOrders} />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic title="Total Users" value={statisticsStore.totalUsers} />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic 
              title="Total Delivery Amount" 
              value={statisticsStore.totalDeliveryAmount} 
              precision={2}
              prefix="$"
            />
          </Card>
        </Col>
      </Row>
    </div>
  );
});

export default Home;

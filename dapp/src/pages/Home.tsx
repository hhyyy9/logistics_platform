import React, { useEffect } from "react";
import { observer } from "mobx-react";
import { useRootStore } from "../stores/RootStore";
import { Card, Statistic, Row, Col } from "antd";

const Home = observer(() => {
  const { statisticsStore } = useRootStore();

  useEffect(() => {

  }, [statisticsStore]);

  return (
    <div>
      <h1>物流平台统计</h1>
      <Row gutter={16}>
        <Col span={8}>
          <Card>
            <Statistic title="总订单数" value={statisticsStore.getTotalOrders} />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="已接受订单" value={statisticsStore.acceptedOrders} />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="已完成订单" value={statisticsStore.completedOrders} />
          </Card>
        </Col>
      </Row>
      <Row gutter={16} style={{ marginTop: 16 }}>
        <Col span={8}>
          <Card>
            <Statistic title="已取消订单" value={statisticsStore.cancelledOrders} />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="总配送费" value={statisticsStore.totalDeliveryFees} prefix="¥" />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="总服务费" value={statisticsStore.totalServiceFees} prefix="¥" />
          </Card>
        </Col>
      </Row>
    </div>
  );
});

export default Home;

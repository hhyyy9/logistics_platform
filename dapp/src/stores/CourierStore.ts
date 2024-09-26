import { types, flow } from 'mobx-state-tree';
import { message } from 'antd';
import { InputTransactionData } from '@aptos-labs/wallet-adapter-core';


export const CourierStore = types.model('CourierStore', {
    totalCouriers: types.number,
    activeCouriers: types.number,
})
.views(self => ({
    get averageActiveRate() {
        return self.activeCouriers / self.totalCouriers;
    }
}))
.actions(self => ({
    setTotalCouriers(total: number) {
        self.totalCouriers = total;
    },
    setActiveCouriers(active: number) {
        self.activeCouriers = active;
    }
}))
.actions(self => ({
    fetchCourierStats: flow(function* () {
        // 在这里添加获取快递员统计数据的逻辑
    }),

    registerCourier: flow(function* (email: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
        console.log('CourierStore.registerCourier 被调用', email);
        try {
            const moduleAddress: string = process.env.REACT_APP_MOVE_MODULE_ADDRESS;
            if (!moduleAddress) {
                throw new Error("REACT_APP_MOVE_MODULE_ADDRESS is not defined");
            }

            const payload: InputTransactionData = {
                data: {
                    function: `${moduleAddress}::courier_management::register_courier`,
                    typeArguments: [],
                    functionArguments: [email],
                },
            };
            console.log('准备提交交易', JSON.stringify(payload, null, 2));
            const result = yield signAndSubmitTransaction({ payload });
            console.log('交易提交结果:', JSON.stringify(result, null, 2));
            message.success('快递员注册成功');
            self.setTotalCouriers(self.totalCouriers + 1);
            self.setActiveCouriers(self.activeCouriers + 1);
        } catch (error) {
            console.error('注册过程中出错', error);
            if (error instanceof Error) {
                message.error(`快递员注册失败: ${error.message}`);
            } else {
                message.error('快递员注册失败');
            }
        }
    }),

    updateCourierInfo: flow(function* (email: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
        try {
            const payload: InputTransactionData = {
                data: {
                    function: `${process.env.REACT_APP_MOVE_MODULE_ADDRESS}::courier_management::update_courier_info`,
                    typeArguments: [],
                    functionArguments: [email],
                },
            };
            yield signAndSubmitTransaction({ payload });
            message.success('快递员信息更新成功');
        } catch (error) {
            message.error('快递员信息更新失败');
            console.error(error);
        }
    }),

    deactivateCourier: flow(function* (address: string, signAndSubmitTransaction: (transaction: { payload: InputTransactionData }) => Promise<any>) {
        try {
            const payload: InputTransactionData = {
                data: {
                    function: `${process.env.REACT_APP_MOVE_MODULE_ADDRESS}::courier_management::deactivate_courier`,
                    typeArguments: [],
                    functionArguments: [address],
                },
            };
            yield signAndSubmitTransaction({ payload });
            message.success('快递员已停用');
            self.setActiveCouriers(self.activeCouriers - 1);
        } catch (error) {
            message.error('快递员停用失败');
            console.error('停用快递员时出错:', error);
        }
    }),
}))
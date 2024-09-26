import { AptosClient } from "aptos";
import { types, flow } from 'mobx-state-tree';
import { Account, Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
// 移除 FaucetClient 的导入

 const NODE_URL = "https://fullnode.devnet.aptoslabs.com";
// const FAUCET_URL = "https://faucet.devnet.aptoslabs.com";

const client = new AptosClient(NODE_URL);
// const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

export const AppStore = types
  .model('AppStore', {
    isLoading: types.optional(types.boolean, false),
    error: types.optional(types.string, ''),
  })
  .actions(self => ({
    
  }));

// 如果需要，可以添加视图
// .views(self => ({
//   // 添加计算属性或派生状态
// }))

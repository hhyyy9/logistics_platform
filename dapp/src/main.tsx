import * as React from "react";
import * as ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { RootStore, RootStoreProvider } from './stores/RootStore';
import App from "./App";

const rootStore = RootStore.create({});


ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <RootStoreProvider value={rootStore}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </RootStoreProvider>
  </React.StrictMode>,
);
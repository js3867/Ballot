import React from 'react';
import { ChainId, DAppProvider } from '@usedapp/core';
import { Header } from "./components/Header"
import { Container } from "@material-ui/core";


function App() {
  return (
    // <div className="App"> replaced by:
    <DAppProvider config={{
      supportedChains: [ChainId.Kovan, ChainId.Rinkeby, 1337]
    }}>
      <Header />
      <Container maxWidth="md">
        <div>Hi!</div>
      </Container>
    </DAppProvider>
    /* </div> */
  )
}

export default App; // gets sent to index.tsx root.render

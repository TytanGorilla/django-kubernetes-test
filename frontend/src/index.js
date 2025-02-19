import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import AuthButtons from "./AuthButtons";

// Mount the main React app
ReactDOM.render(<App />, document.getElementById("root"));

// Use MutationObserver to wait for #react-auth-buttons to appear in the DOM
function mountAuthButtons() {
    const authContainer = document.getElementById("react-auth-buttons");
    if (authContainer) {
        ReactDOM.render(<AuthButtons />, authContainer);
        console.log("✅ AuthButtons successfully mounted!");
    } else {
        console.log("❌ `#react-auth-buttons` span not found. Waiting for it...");
        const observer = new MutationObserver(() => {
            const newAuthContainer = document.getElementById("react-auth-buttons");
            if (newAuthContainer) {
                ReactDOM.render(<AuthButtons />, newAuthContainer);
                console.log("✅ AuthButtons successfully mounted after waiting!");
                observer.disconnect(); // Stop observing once mounted
            }
        });
        // Start observing changes in the body for adding the element
        observer.observe(document.body, { childList: true, subtree: true });
    }
}

mountAuthButtons(); // Start the process

import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import AuthButtons from "./AuthButtons";

// Wait for the DOM to be ready
document.addEventListener("DOMContentLoaded", function () {
    // Only mount React if the #root div exists
    const root = document.getElementById("root");
    if (root) {
        ReactDOM.render(<App />, root);
        console.log("✅ React mounted on #root.");
    } else {
        console.log("✅ Skipping React mount: No #root found on this page.");
    }

    // Ensure AuthButtons mounts only if `#react-auth-buttons` exists
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
            observer.observe(document.body, { childList: true, subtree: true });
        }
    }

    mountAuthButtons(); // Start the process
});
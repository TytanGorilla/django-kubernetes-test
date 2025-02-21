import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import AuthButtons from "./AuthButtons";
import { BrowserRouter as Router } from "react-router-dom";

// Wait for DOM to be ready
document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ React script loaded");

    // Mount the main React app (Calendar)
    const root = document.getElementById("root");
    if (root) {
        ReactDOM.render(
            <Router>
                <App />
            </Router>,
            root
        );
        console.log("✅ React mounted on #root.");
    } else {
        console.log("✅ Skipping React mount: No #root found on this page.");
    }

    // Ensure AuthButtons mounts only if `#react-auth-buttons` exists
    function mountAuthButtons() {
        const authContainer = document.getElementById("react-auth-buttons");
        if (authContainer) {
            ReactDOM.render(
                <Router>
                    <AuthButtons />
                </Router>,
                authContainer
            );
            console.log("✅ AuthButtons successfully mounted!");
        } else {
            console.log("❌ `#react-auth-buttons` span not found. Waiting for it...");
            const observer = new MutationObserver(() => {
                const newAuthContainer = document.getElementById("react-auth-buttons");
                if (newAuthContainer) {
                    ReactDOM.render(
                        <Router>
                            <AuthButtons />
                        </Router>,
                        newAuthContainer
                    );
                    console.log("✅ AuthButtons successfully mounted after waiting!");
                    observer.disconnect(); // Stop observing once mounted
                }
            });
            observer.observe(document.body, { childList: true, subtree: true });
        }
    }

    // Delay mounting by 200ms to ensure Django template loads
    setTimeout(mountAuthButtons, 200);
});
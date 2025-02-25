import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import { BrowserRouter as Router } from "react-router-dom";

document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ DOM Loaded, checking for #root div...");
    
    setTimeout(() => {  // Delay in case scripts load late
        const root = document.getElementById("root");
        if (root) {
            console.log("✅ Mounting React in #root...");
            ReactDOM.render(
                <Router>
                    <App />
                </Router>,
                root
            );
        } else {
            console.error("❌ React mount failed: No #root found.");
        }
    }, 500);  // ⏳ Small delay to let scripts load
});
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
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
});
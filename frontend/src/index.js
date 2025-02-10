import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import AuthButtons from "./AuthButtons"; // ✅ Import AuthButtons

// ✅ Mount the main React app
ReactDOM.render(<App />, document.getElementById("root"));

// ✅ Mount AuthButtons inside the Django nav bar
document.addEventListener("DOMContentLoaded", () => {
    const authContainer = document.getElementById("react-auth-buttons");
    if (authContainer) {
        ReactDOM.render(<AuthButtons />, authContainer);
        console.log("✅ AuthButtons successfully mounted!");
    } else {
        console.error("❌ `#react-auth-buttons` span not found!");
    }
});
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import AuthButtons from "./AuthButtons";  // ✅ New component for login/logout

// Inject login/logout buttons into Django's navbar
ReactDOM.render(<AuthButtons />, document.getElementById("react-auth-buttons"));

// Render the main React app
ReactDOM.render(<App />, document.getElementById("root"));

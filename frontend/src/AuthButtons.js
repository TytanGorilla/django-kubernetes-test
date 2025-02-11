import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import ReactDOM from "react-dom";

const AuthButtons = () => {
  const navigate = useNavigate();
  const [token, setToken] = useState(localStorage.getItem("access_token"));

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    setToken(null);
    navigate("/login");
  };

  useEffect(() => {
    console.log("✅ React AuthButtons useEffect running...");

    const injectAuthButtons = () => {
      const authContainer = document.getElementById("react-auth-buttons");
      console.log("🔍 Found auth container:", authContainer);

      if (authContainer) {
        console.log("✅ Injecting React buttons into Django navbar...");
        authContainer.innerHTML = ""; // Clear previous content
        ReactDOM.render(
          token ? (
            <button onClick={handleLogout}>Logout</button>
          ) : (
            <Link to="/login">Login</Link>
          ),
          authContainer
        );
      } else {
        console.error("❌ Could not find #react-auth-buttons in DOM!");
      }
    };

    setTimeout(injectAuthButtons, 100); // ✅ Ensures Django fully loads before React injects
  }, [token]);

  return null; // 🚀 React doesn’t render anything itself, just injects into Django.
};

export default AuthButtons;
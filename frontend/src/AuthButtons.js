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
    const authContainer = document.getElementById("react-auth-buttons");
    if (authContainer) {
      ReactDOM.render(
        token ? (
          <button onClick={handleLogout}>Logout</button>
        ) : (
          <Link to="/login">Login</Link>
        ),
        authContainer
      );
    }
  }, [token]);

  return null; // ✅ Injects into Django's template, no React UI needed
};

export default AuthButtons;

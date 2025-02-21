import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";

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
  }, [token]);

  return (
    <div>
      {token ? (
        <button onClick={handleLogout}>Logout</button>
      ) : (
        <Link to="/login">Login</Link>
      )}
    </div>
  );
};

export default AuthButtons;
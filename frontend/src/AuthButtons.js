import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || "http://localhost:32212";

const AuthButtons = () => {
  const navigate = useNavigate();
  const token = localStorage.getItem("access_token");

  useEffect(() => {
    console.log("✅ AuthButtons Component Rendered!");
    console.log("🔑 Token in localStorage:", token);
  }, [token]);

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    window.location.href = "/login";  // ✅ Forces full page reload to login page
  };

  return (
    <span>
      {token ? (
        <button onClick={handleLogout}>Logout</button>
      ) : (
        <Link to="/login">Login</Link>
      )}
    </span>
  );
};

export default AuthButtons;
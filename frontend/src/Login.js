// src/Login.js

import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    // Get the backend URL from the environment variables
    const backendUrl = process.env.REACT_APP_BACKEND_URL;
    // Construct the JWT token endpoint URL
    const tokenEndpoint = `${backendUrl}/api/token/`;

    try {
      // Send a POST request to the JWT token endpoint with email and password
      const response = await axios.post(tokenEndpoint, {
        email,
        password,
      });
      
      // Save the tokens in localStorage (or you could use context/state as needed)
      localStorage.setItem("accessToken", response.data.access);
      localStorage.setItem("refreshToken", response.data.refresh);
      
      // Optionally, set the default Authorization header for future Axios requests
      axios.defaults.headers.common["Authorization"] = "Bearer " + response.data.access;
      
      // Redirect the user to the scheduler page after successful login
      navigate("/scheduler");
    } catch (err) {
      setError("Invalid credentials. Please try again.");
      console.error("Login failed:", err);
    }
  };

  return (
    <div className="login-container" style={{ maxWidth: "400px", margin: "0 auto", padding: "1rem" }}>
      <h2>Login</h2>
      {error && <p style={{ color: "red" }}>{error}</p>}
      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: "1rem" }}>
          <label>Email:</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            style={{ width: "100%", padding: "0.5rem" }}
          />
        </div>
        <div style={{ marginBottom: "1rem" }}>
          <label>Password:</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            style={{ width: "100%", padding: "0.5rem" }}
          />
        </div>
        <button type="submit" style={{ padding: "0.5rem 1rem" }}>Login</button>
      </form>
    </div>
  );
};

export default Login;

import { useState } from "react";
import axios from "axios";

// ✅ Dynamically determine backend URL
const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || "http://localhost:32212";

const Login = () => {
  const [formData, setFormData] = useState({ username: "", password: "" });
  const [error, setError] = useState("");

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
  
    try {
      const response = await axios.post(`${process.env.REACT_APP_BACKEND_URL}/api/token/`, formData);
  
      console.log("Login Response:", response.data);
  
      if (response.data.access && response.data.refresh) {
        localStorage.setItem("access_token", response.data.access);
        localStorage.setItem("refresh_token", response.data.refresh);
        console.log("Token saved to localStorage:", localStorage.getItem("access_token"));
      } else {
        console.error("Token missing in response!", response.data);
        setError("Authentication failed: No token received");
        return;
      }
  
      window.location.href = "/scheduler";  // Redirect user after login
  
    } catch (error) {
      console.error("Login error:", error.response?.data || error);
      setError("Invalid username or password");
    }
  };  

  return (
    <div>
      <h2>Login</h2>
      {error && <p style={{ color: "red" }}>{error}</p>}
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="username"
          placeholder="Username"
          value={formData.username}
          onChange={handleChange}
          required
        />
        <input
          type="password"
          name="password"
          placeholder="Password"
          value={formData.password}
          onChange={handleChange}
          required
        />
        <button type="submit">Login</button>
      </form>
    </div>
  );
};

export default Login;
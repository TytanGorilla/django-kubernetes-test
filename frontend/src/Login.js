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
      const response = await axios.post(`${BACKEND_URL}/api/token/`, formData, {
        headers: {
          "Content-Type": "application/json",
        },
        withCredentials: true, // ✅ Ensure cookies are sent if needed
      });

      localStorage.setItem("access_token", response.data.access);
      localStorage.setItem("refresh_token", response.data.refresh);

      console.log("✅ Login successful!", response.data);
      window.location.href = "/scheduler"; // Redirect after login

    } catch (error) {
      console.error("❌ Login error:", error);

      if (error.response) {
        console.error("Server Response:", error.response.data);
        setError(error.response.data.detail || "Invalid username or password");
      } else if (error.request) {
        console.error("No response from server.");
        setError("Unable to connect to the backend. Check your network.");
      } else {
        console.error("Request setup error:", error.message);
        setError("Something went wrong. Please try again.");
      }
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
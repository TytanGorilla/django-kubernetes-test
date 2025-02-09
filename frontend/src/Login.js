import { useState } from "react";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || "http://localhost:32212";

const Login = () => {
  const [formData, setFormData] = useState({ username: "", password: "" });
  const [error, setError] = useState("");
  const [showPassword, setShowPassword] = useState(false); // ✅ State for toggling password

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
  
    try {
      const response = await axios.post(`${BACKEND_URL}/api/token/`, formData);
  
      console.log("Login Response:", response.data);
  
      if (response.data.access && response.data.refresh) {
        localStorage.setItem("access_token", response.data.access);
        localStorage.setItem("refresh_token", response.data.refresh);
        console.log("Token saved to localStorage:", localStorage.getItem("access_token"));
      } else {
        setError("Authentication failed: No token received");
        return;
      }
  
      window.location.href = "/scheduler";  // Redirect user after login
  
    } catch (error) {
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
        
        <div style={{ display: "flex", alignItems: "center" }}>
          <input
            type={showPassword ? "text" : "password"} // ✅ Toggle visibility
            name="password"
            placeholder="Password"
            value={formData.password}
            onChange={handleChange}
            required
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            style={{
              marginLeft: "10px",
              backgroundColor: "transparent",
              border: "none",
              cursor: "pointer"
            }}
          >
            {showPassword ? "🙈 Hide" : "👁 Show"}
          </button>
        </div>

        <button type="submit">Login</button>
      </form>
    </div>
  );
};

export default Login;

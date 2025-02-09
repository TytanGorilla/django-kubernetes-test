import { useState, useEffect } from "react";

export default function Navbar() {
  const [token, setToken] = useState(null);

  useEffect(() => {
    // Check for token on mount
    const storedToken = localStorage.getItem("access_token");
    setToken(storedToken);
  }, []);

  const handleLogin = () => {
    const fakeToken = "your_jwt_token_here"; // Replace with real login logic
    localStorage.setItem("access_token", fakeToken);
    setToken(fakeToken);
  };

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    setToken(null);
  };

  return (
    <nav className="bg-gray-800 p-4 flex justify-between items-center">
      <h1 className="text-white text-xl">My App</h1>
      <div>
        {token ? (
          <button 
            onClick={handleLogout} 
            className="bg-red-500 text-white px-4 py-2 rounded">
            Logout
          </button>
        ) : (
          <button 
            onClick={handleLogin} 
            className="bg-blue-500 text-white px-4 py-2 rounded">
            Login
          </button>
        )}
      </div>
    </nav>
  );
}

import { Link, useNavigate } from "react-router-dom";

const Navbar = () => {
  const navigate = useNavigate();
  const token = localStorage.getItem("access_token");

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    navigate("/login"); // Redirect to login page
  };

  return (
    <nav style={{ display: "flex", justifyContent: "space-between", padding: "10px", backgroundColor: "#333", color: "white" }}>
      <div>
        <Link to="/scheduler" style={{ marginRight: "15px", color: "white", textDecoration: "none" }}>Scheduler</Link>
      </div>
      <div>
        {token ? (
          <button onClick={handleLogout} style={{ backgroundColor: "red", color: "white", border: "none", padding: "5px 10px" }}>Logout</button>
        ) : (
          <Link to="/login" style={{ color: "white", textDecoration: "none" }}>Login</Link>
        )}
      </div>
    </nav>
  );
};

export default Navbar;

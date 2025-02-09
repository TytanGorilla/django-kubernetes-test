import { BrowserRouter as Router, Route, Navigate, Routes } from "react-router-dom";
import CalendarUI from "./CalendarUI";
import Login from "./Login";
import Navbar from "./Navbar"; // ✅ Import the Navbar component

const PrivateRoute = ({ element }) => {
  const token = localStorage.getItem("access_token");
  return token ? element : <Navigate to="/login" />;
};

const App = () => {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/scheduler" element={<PrivateRoute element={<CalendarUI />} />} />
      </Routes>
    </Router>
  );
};

export default App;
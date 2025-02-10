import { BrowserRouter as Router, Route, Navigate, Routes } from "react-router-dom";
import CalendarUI from "./CalendarUI";
import LoginPage from "./LoginPage";  // ✅ Import new login page
import Navbar from "./Navbar";  

const PrivateRoute = ({ element }) => {
  const token = localStorage.getItem("access_token");
  return token ? element : <Navigate to="/login" />;
};

const App = () => {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/login" element={<LoginPage />} />  {/* ✅ Use LoginPage instead of Login */}
        <Route path="/scheduler" element={<PrivateRoute element={<CalendarUI />} />} />
      </Routes>
    </Router>
  );
};

export default App;
import { BrowserRouter as Router, Route, Navigate, Routes } from "react-router-dom";
import CalendarUI from "./CalendarUI";
import LoginPage from "./LoginPage";  // ✅ Import new login page
import AuthButtons from "./AuthButtons";  // ✅ Import this
import supabase from './supabase'; // Import the Supabase client

const PrivateRoute = ({ element }) => {
  const token = localStorage.getItem("access_token");
  return token ? element : <Navigate to="/login" />;
};

const App = () => {
  const location = window.location.pathname;
  return (
    <Router>
      <AuthButtons /> 
      {location.startsWith("/scheduler") && (
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/scheduler" element={<PrivateRoute element={<CalendarUI />} />} />
        </Routes>
      )}
    </Router>
  );
};

export default App;

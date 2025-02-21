import { BrowserRouter as Router, Route, Navigate, Routes } from "react-router-dom";
import CalendarUI from "./CalendarUI";
import LoginPage from "./LoginPage";  
import AuthButtons from "./AuthButtons";  

const PrivateRoute = ({ element }) => {
  const token = localStorage.getItem("access_token");
  return token ? element : <Navigate to="/login" />;
};

const App = () => {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/scheduler" element={<PrivateRoute element={<CalendarUI />} />} />
    </Routes>
  );
};

export default App;
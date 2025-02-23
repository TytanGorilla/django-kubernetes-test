import { BrowserRouter as Router, Route, Navigate, Routes } from "react-router-dom";
import CalendarUI from "./CalendarUI";


const PrivateRoute = ({ element }) => {
  const token = localStorage.getItem("access_token");
  return token ? element : <Navigate to="/scheduler/login" />; // ✅ Redirects to Django login page if not authenticated
};

const App = () => {
  return (
    <Routes>
      <Route path="/scheduler/*" element={<PrivateRoute element={<CalendarUI />} />} />
    </Routes>
  );
};

export default App;
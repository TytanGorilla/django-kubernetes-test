import { BrowserRouter as Router, Route, Navigate, Routes } from "react-router-dom";
import CalendarUI from "./CalendarUI";


const App = () => {
  return (
    <Routes>
      <Route path="/scheduler/" element={<CalendarUI />} />
    </Routes>
  );
};

export default App;
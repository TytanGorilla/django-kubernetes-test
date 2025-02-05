import { useState } from "react";
import { Calendar as BigCalendar, momentLocalizer } from "react-big-calendar";
import moment from "moment";
import "react-big-calendar/lib/css/react-big-calendar.css";
import { format } from "date-fns";
import axios from "axios"; // Make sure to install axios (npm install axios)

const localizer = momentLocalizer(moment);

const CalendarUI = () => {
  const [events, setEvents] = useState([]);
  const [selectedDate, setSelectedDate] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [formData, setFormData] = useState({ title: "", description: "", start: "", end: "" });

  const handleSelectSlot = ({ start }) => {
    setSelectedDate(start);
    setIsDialogOpen(true);
    // Format the date in a way that the datetime-local input expects
    setFormData({ 
      ...formData, 
      start: format(start, "yyyy-MM-dd'T'HH:mm"), 
      end: format(start, "yyyy-MM-dd'T'HH:mm") 
    });
  };

  const handleFormChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async () => {
    // Build the new event object
    const newEvent = {
      title: formData.title,
      description: formData.description,
      // Convert the datetime strings into ISO format (or as expected by your DRF serializer)
      start_time: new Date(formData.start).toISOString(),
      end_time: new Date(formData.end).toISOString(),
    };

    try {
      // Send a POST request to your Django API endpoint
      const response = await axios.post("http://YOUR_BACKEND_URL/api/events/", newEvent, {
        headers: {
          "Content-Type": "application/json",
        },
      });
      
      // On success, update local state with the returned event (which should include its database ID, etc.)
      setEvents([...events, response.data]);
      setIsDialogOpen(false);
    } catch (error) {
      console.error("Error saving event:", error);
    }
  };

  return (
    <div className="p-4">
      <BigCalendar
        localizer={localizer}
        events={events}
        startAccessor="start_time"
        endAccessor="end_time"
        selectable
        style={{ height: 500 }}
        onSelectSlot={handleSelectSlot}
      />

      {isDialogOpen && (
        <div className="dialog">
          <h2>Create Event</h2>
          <label>Title</label>
          <input name="title" value={formData.title} onChange={handleFormChange} />
          <label>Description</label>
          <textarea name="description" value={formData.description} onChange={handleFormChange} />
          <label>Start Time</label>
          <input type="datetime-local" name="start" value={formData.start} onChange={handleFormChange} />
          <label>End Time</label>
          <input type="datetime-local" name="end" value={formData.end} onChange={handleFormChange} />
          <button onClick={handleSubmit}>Save</button>
          <button onClick={() => setIsDialogOpen(false)}>Cancel</button>
        </div>
      )}
    </div>
  );
};

export default CalendarUI;

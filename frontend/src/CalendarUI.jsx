import { useState, useEffect } from "react";
import { Calendar as BigCalendar, momentLocalizer } from "react-big-calendar";
import moment from "moment";
import "react-big-calendar/lib/css/react-big-calendar.css";
import { format } from "date-fns";
import axios from "axios";

const localizer = momentLocalizer(moment);

const CalendarUI = () => {
  const [events, setEvents] = useState([]);
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [selectedDate, setSelectedDate] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [formData, setFormData] = useState({ id: null, title: "", description: "", start: "", end: "" });

  // Fetch events on page load
  useEffect(() => {
    const fetchEvents = async () => {
      try {
        const token = localStorage.getItem("access_token");

        if (!token) {
          console.error("❌ No access token found in localStorage. User may need to log in.");
          return; // Prevent request if token is missing
        }

        console.log("📡 Sending request with token:", token);

        const response = await axios.get(`${process.env.REACT_APP_BACKEND_URL}/api/events/`, {
          headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json"
          },
        });

        console.log("✅ Events response:", response.data);
        setEvents(response.data);
      } catch (error) {
        console.error("❌ Error fetching events:", error.response?.data || error);
      }
    };

    fetchEvents();
  }, []);

  // Handle selecting a time slot to create a new event
  const handleSelectSlot = ({ start }) => {
    setSelectedDate(start);
    setSelectedEvent(null);
    setIsDialogOpen(true);
    setFormData({
      id: null,
      title: "",
      description: "",
      start: format(start, "yyyy-MM-dd'T'HH:mm"),
      end: format(start, "yyyy-MM-dd'T'HH:mm"),
    });
  };

  // Handle selecting an event (Edit Mode)
  const handleSelectEvent = (event) => {
    setSelectedEvent(event);
    setIsDialogOpen(true);
    setFormData({
      id: event.id,
      title: event.title,
      description: event.description,
      start: format(new Date(event.start_time), "yyyy-MM-dd'T'HH:mm"),
      end: format(new Date(event.end_time), "yyyy-MM-dd'T'HH:mm"),
    });
  };

  // Handle input changes in the form
  const handleFormChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // Handle saving (Create or Update event)
  const handleSubmit = async () => {
    const eventData = {
      title: formData.title,
      description: formData.description,
      start_time: new Date(formData.start).toISOString(),
      end_time: new Date(formData.end).toISOString(),
    };

    try {
      const token = localStorage.getItem("access_token");

      if (formData.id) {
        // Update existing event
        const response = await axios.put(`${process.env.REACT_APP_BACKEND_URL}/api/events/${formData.id}/`, eventData, {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
          },
        });

        setEvents(events.map((event) => (event.id === formData.id ? response.data : event)));
      } else {
        // Create new event
        const response = await axios.post(`${process.env.REACT_APP_BACKEND_URL}/api/events/`, eventData, {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
          },
        });

        setEvents([...events, response.data]);
      }

      setIsDialogOpen(false);
    } catch (error) {
      console.error("Error saving event:", error);
    }
  };

  // Handle deleting an event
  const handleDelete = async () => {
    if (!selectedEvent) return;

    try {
      const token = localStorage.getItem("access_token");

      await axios.delete(`${process.env.REACT_APP_BACKEND_URL}/api/events/${selectedEvent.id}/`, {
        headers: {
          "Authorization": `Bearer ${token}`,
        },
      });

      setEvents(events.filter((event) => event.id !== selectedEvent.id));
      setIsDialogOpen(false);
    } catch (error) {
      console.error("Error deleting event:", error);
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
        onSelectEvent={handleSelectEvent} // Enables event selection for editing
      />

      {isDialogOpen && (
        <div className="dialog">
          <h2>{selectedEvent ? "Edit Event" : "Create Event"}</h2>
          <label>Title</label>
          <input name="title" value={formData.title} onChange={handleFormChange} />
          <label>Description</label>
          <textarea name="description" value={formData.description} onChange={handleFormChange} />
          <label>Start Time</label>
          <input type="datetime-local" name="start" value={formData.start} onChange={handleFormChange} />
          <label>End Time</label>
          <input type="datetime-local" name="end" value={formData.end} onChange={handleFormChange} />
          <button onClick={handleSubmit}>{selectedEvent ? "Update" : "Save"}</button>
          {selectedEvent && <button onClick={handleDelete}>Delete</button>}
          <button onClick={() => setIsDialogOpen(false)}>Cancel</button>
        </div>
      )}
    </div>
  );
};

export default CalendarUI;

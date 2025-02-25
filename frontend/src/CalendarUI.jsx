import { useState, useEffect } from "react";
import { Calendar as BigCalendar, momentLocalizer } from "react-big-calendar";
import moment from "moment";
import "react-big-calendar/lib/css/react-big-calendar.css";
import { format } from "date-fns";
import supabase from "./supabase"; // ✅ Import Supabase client

const localizer = momentLocalizer(moment);

const CalendarUI = () => {
  const [events, setEvents] = useState([]);
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [selectedDate, setSelectedDate] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [formData, setFormData] = useState({
    id: null,
    title: "",
    description: "",
    start: "",
    end: "",
  });

  // ✅ Fetch events from Supabase when the component mounts
  useEffect(() => {
    fetchEvents();
    window.debugEvents = events; // ✅ Expose to console
  }, []);

  // ✅ Fetch events from Supabase
  const fetchEvents = async () => {
    try {
      const { data, error } = await supabase.from("scheduler_event").select("*");
  
      if (error) {
        console.error("❌ Error fetching events:", error.message);
      } else {
        console.log("✅ Supabase events response:", data);
        setEvents(data);
        window.debugEvents = data; // ✅ Now accessible in console
      }
    } catch (err) {
      console.error("❌ Unexpected error fetching events:", err);
    }
  };
  

  // ✅ Handle selecting a time slot to create a new event
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

  // ✅ Handle selecting an event (Edit Mode)
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

  // ✅ Handle input changes in the form
  const handleFormChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // ✅ Handle saving (Create or Update event)
  const handleSubmit = async () => {
    const eventData = {
      title: formData.title,
      description: formData.description,
      start_time: new Date(formData.start).toISOString(),
      end_time: new Date(formData.end).toISOString(),
    };

    try {
      let response;
      if (formData.id) {
        // ✅ Update existing event in Supabase
        response = await supabase
          .from("scheduler_event")
          .update(eventData)
          .match({ id: formData.id });
      } else {
        // ✅ Insert new event in Supabase
        response = await supabase.from("scheduler_event").insert([eventData]);
      }

      if (response.error) throw response.error;

      setIsDialogOpen(false);
      fetchEvents(); // 🔄 ✅ Fetch latest events after saving
    } catch (error) {
      console.error("❌ Error saving event:", error.message);
    }
  };

  // ✅ Handle deleting an event
  const handleDelete = async () => {
    if (!selectedEvent) return;

    try {
      const { error } = await supabase.from("scheduler_event").delete().match({ id: selectedEvent.id });

      if (error) throw error;

      setIsDialogOpen(false);
      fetchEvents(); // 🔄 ✅ Fetch latest events after deleting
    } catch (error) {
      console.error("❌ Error deleting event:", error.message);
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
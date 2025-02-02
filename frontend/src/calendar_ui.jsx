import { useState } from "react";
import { Calendar as BigCalendar, momentLocalizer } from "react-big-calendar";
import moment from "moment";
import "react-big-calendar/lib/css/react-big-calendar.css";
import { format } from "date-fns";

const localizer = momentLocalizer(moment);

const CalendarUI = () => {
  const [events, setEvents] = useState([]);
  const [selectedDate, setSelectedDate] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [formData, setFormData] = useState({ title: "", description: "", start: "", end: "" });

  const handleSelectSlot = ({ start }) => {
    setSelectedDate(start);
    setIsDialogOpen(true);
    setFormData({ ...formData, start: format(start, "yyyy-MM-dd HH:mm"), end: format(start, "yyyy-MM-dd HH:mm") });
  };

  const handleFormChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = () => {
    const newEvent = {
      title: formData.title,
      description: formData.description,
      start: new Date(formData.start),
      end: new Date(formData.end),
      allDay: false,
    };
    setEvents([...events, newEvent]);
    setIsDialogOpen(false);
  };

  return (
    <div className="p-4">
      <BigCalendar
        localizer={localizer}
        events={events}
        startAccessor="start"
        endAccessor="end"
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

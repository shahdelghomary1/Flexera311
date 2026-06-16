
import User from "../models/userModel.js";

import Schedule from "../models/scheduleModel.js";
import Doctor from "../models/doctorModel.js";

export const addSchedule = async (req, res) => {
  try {
    const doctorId = req.user.id;
    const requestDate = req.body.date;

    // 🔒 Authorization
    if (req.user.role !== "doctor") {
      return res.status(403).json({ message: "Access denied" });
    }

    // 📅 Validate date format
    const dateRegex = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/;
    if (!dateRegex.test(requestDate)) {
      return res.status(400).json({
        message: "Invalid date format. Use YYYY-MM-DD"
      });
    }

    // 📅 Validate real date
    const parsedDate = new Date(requestDate);
    const [year, month, day] = requestDate.split("-").map(Number);

    if (
      parsedDate.getFullYear() !== year ||
      parsedDate.getMonth() + 1 !== month ||
      parsedDate.getDate() !== day
    ) {
      return res.status(400).json({
        message: "Invalid date value. This date does not exist."
      });
    }

    // ⏰ Date checks
    const now = new Date();

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const scheduledDate = new Date(requestDate);
    scheduledDate.setHours(0, 0, 0, 0);

    if (scheduledDate < today) {
      return res.status(400).json({
        message: "Cannot add schedule in the past"
      });
    }

    // 🧠 Helpers
    const timeToMinutes = (time) => {
      const [h, m] = time.split(":").map(Number);
      return h * 60 + m;
    };

    const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;

    // ✅ Validate slots (مرة واحدة بس)
    for (const slot of req.body.timeSlots) {
      if (!timeRegex.test(slot.from) || !timeRegex.test(slot.to)) {
        return res.status(400).json({
          message: `Invalid time format: ${JSON.stringify(slot)}`
        });
      }

      const fromMinutes = timeToMinutes(slot.from);
      const toMinutes = timeToMinutes(slot.to);

      if (toMinutes <= fromMinutes) {
        return res.status(400).json({
          message: `'to' must be after 'from' in ${JSON.stringify(slot)}`
        });
      }

      // ⛔ منع وقت فات لو نفس اليوم
      if (scheduledDate.getTime() === today.getTime()) {
        const [h, m] = slot.from.split(":").map(Number);

        const slotDateTime = new Date(requestDate);
        slotDateTime.setHours(h, m, 0, 0);

        if (slotDateTime <= now) {
          return res.status(400).json({
            message: `Cannot add past slot: ${slot.from}`
          });
        }
      }
    }

    // 🧱 Add booking flag
    const slotsWithBooking = req.body.timeSlots.map(slot => ({
      ...slot,
      isBooked: false
    }));

    // 🚫 Prevent duplicates داخل الريكوست
    const seen = new Set();
    for (const slot of slotsWithBooking) {
      const key = `${slot.from}-${slot.to}`;
      if (seen.has(key)) {
        return res.status(400).json({
          message: `Duplicate slot: ${key}`
        });
      }
      seen.add(key);
    }

    // 🔥 Prevent overlap داخل الريكوست
    const sortedSlots = [...slotsWithBooking].sort(
      (a, b) => timeToMinutes(a.from) - timeToMinutes(b.from)
    );

    for (let i = 1; i < sortedSlots.length; i++) {
      const prevEnd = timeToMinutes(sortedSlots[i - 1].to);
      const currStart = timeToMinutes(sortedSlots[i].from);

      if (currStart < prevEnd) {
        return res.status(400).json({
          message: "Time slots cannot overlap"
        });
      }
    }

    // 🔍 Check existing schedule
    const existingSchedule = await Schedule.findOne({
      doctor: doctorId,
      date: requestDate
    });

    if (existingSchedule) {
      for (const newSlot of slotsWithBooking) {
        const newFrom = timeToMinutes(newSlot.from);
        const newTo = timeToMinutes(newSlot.to);

        for (const existingSlot of existingSchedule.timeSlots) {
          const existFrom = timeToMinutes(existingSlot.from);
          const existTo = timeToMinutes(existingSlot.to);

          // duplicate
          if (
            newSlot.from === existingSlot.from &&
            newSlot.to === existingSlot.to
          ) {
            return res.status(400).json({
              message: `Slot already exists: ${newSlot.from}-${newSlot.to}`
            });
          }

          // overlap
          if (newFrom < existTo && existFrom < newTo) {
            return res.status(400).json({
              message: `Overlap with existing slot ${existingSlot.from}-${existingSlot.to}`
            });
          }
        }
      }

      // ➕ add & sort
      existingSchedule.timeSlots.push(...slotsWithBooking);

      existingSchedule.timeSlots.sort(
        (a, b) => timeToMinutes(a.from) - timeToMinutes(b.from)
      );

      await existingSchedule.save();

      // 🔔 notify
      const notificationService = req.app.get("notificationService");
      if (notificationService) {
        const doctor = await Doctor.findById(doctorId);
        if (doctor) {
          await notificationService.newScheduleAvailable(
            doctor,
            requestDate,
            slotsWithBooking
          );
        }
      }

      return res.json({
        message: "Schedule updated successfully",
        schedule: existingSchedule
      });
    }

    // 🆕 create new schedule
    const schedule = await Schedule.create({
      doctor: doctorId,
      date: requestDate,
      timeSlots: slotsWithBooking
    });

    // 🔔 notify
    const notificationService = req.app.get("notificationService");
    if (notificationService) {
      const doctor = await Doctor.findById(doctorId);
      if (doctor) {
        await notificationService.newScheduleAvailable(
          doctor,
          requestDate,
          slotsWithBooking
        );
      }
    }

    return res.json({
      message: "Schedule added successfully",
      schedule
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: "Server error",
      error: err.message
    });
  }
};


export const getDoctorSchedule = async (req, res) => {
  try {
    const doctorId = req.query.doctorId || req.user._id; 
    const schedules = await Schedule.find({ doctor: doctorId });

    res.json({
      message: "Doctor schedule fetched",
      schedules
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
export const updateSchedule = async (req, res) => {
  try {
    const scheduleId = req.params.id;

    
    if (req.user.role !== "doctor") {
      return res.status(403).json({ message: "Access denied" });
    }

   
    const schedule = await Schedule.findById(scheduleId);
    if (!schedule) {
      return res.status(404).json({ message: "Schedule not found" });
    }

    if (schedule.doctor.toString() !== req.user.id) {
      return res.status(403).json({ message: "You cannot edit another doctor's schedule" });
    }

    
    const timeToMinutes = (time) => {
      const [h, m] = time.split(":").map(Number);
      return h * 60 + m;
    };

    
    for (const slot of req.body.timeSlots) {
      const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
      if (!timeRegex.test(slot.from) || !timeRegex.test(slot.to)) {
        return res.status(400).json({ 
          message: `Invalid time format in slot ${JSON.stringify(slot)}` 
        });
      }

      const fromMinutes = timeToMinutes(slot.from);
      const toMinutes = timeToMinutes(slot.to);

      if (toMinutes <= fromMinutes) {
        return res.status(400).json({ 
          message: `Invalid slot: 'to' must be after 'from' in slot ${JSON.stringify(slot)}` 
        });
      }
    }

    if (req.body.timeSlots && req.body.timeSlots.length > 1) {
      const sortedSlots = [...req.body.timeSlots].sort(
        (a, b) => timeToMinutes(a.from) - timeToMinutes(b.from)
      );

      for (let i = 1; i < sortedSlots.length; i++) {
        const prev = sortedSlots[i - 1];
        const curr = sortedSlots[i];

        const prevEnd = timeToMinutes(prev.to);
        const currStart = timeToMinutes(curr.from);

        if (currStart < prevEnd) {
          return res.status(400).json({
            message: `Overlapping time slots in schedule: ${prev.from}-${prev.to} and ${curr.from}-${curr.to}`
          });
        }
      }
    }

  
    const updated = await Schedule.findByIdAndUpdate(
      scheduleId,
      {
        date: req.body.date,
        timeSlots: req.body.timeSlots
      },
      { new: true }
    );

    res.json({
      message: "Schedule updated successfully",
      schedule: updated
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


export const getUserAppointments = async (req, res) => {
  try {
    const userId = req.user._id;

    const schedules = await Schedule.find({ user: userId })
      .populate("doctor", "name  image");

    res.status(200).json({
      message: "User appointments fetched",
      schedules,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};


export const getDoctorAppointments = async (req, res) => {
  try {
   
    const doctorId = req.user._id;
    
    
    const schedules = await Schedule.find({ doctor: doctorId })
      .populate({
        path: 'timeSlots.bookedBy', 
        select: 'name image email' 
      })
      .sort({ date: 1 });

    res.json({
      message: "Doctor appointments fetched",
      schedules
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

export const cancelBookedTimeSlot = async (req, res) => {
    try {
        const { scheduleId, from, to } = req.body;
        const userId = req.user.id; 

        const schedule = await Schedule.findById(scheduleId);
        if (!schedule) {
            return res.status(404).json({ message: "Schedule not found" });
        }

        const slotIndex = schedule.timeSlots.findIndex(
            slot => slot.from === from && slot.to === to && slot.bookedBy.toString() === userId.toString()
        );

        if (slotIndex === -1) {
            return res.status(404).json({ message: "Booked time slot not found for this user" });
        }

        schedule.timeSlots[slotIndex].isBooked = false;
        schedule.timeSlots[slotIndex].bookedBy = null; 

        await schedule.save();

        res.json({ message: "Time slot cancelled successfully", schedule });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error", error: err.message });
    }
};
export const getAppointmentsForDoctor = async (req, res) => {
    try {
      
        const doctorId = req.user.id; 

     
        const schedules = await Schedule.find({ 
            doctor: doctorId 
        })
        .select('date timeSlots') 
        .populate({
            path: 'timeSlots.bookedBy',
            select: 'name image medicalFile' 
        })
        .sort({ date: 1 });

        if (!schedules.length) {
            return res.status(404).json({ message: "No schedules found" });
        }

        const bookedAppointments = [];

        schedules.forEach(schedule => {
            schedule.timeSlots.forEach(slot => {
               
                if (slot.isBooked && slot.bookedBy) {
                    bookedAppointments.push({
                        date: schedule.date,
                        from: slot.from,
                        to: slot.to,
                        user: slot.bookedBy, 
                        slotId: slot._id
                    });
                }
            });
        });

        res.status(200).json({
            message: "Booked appointments fetched successfully",
            appointments: bookedAppointments
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error", error: err.message });
    }
};

export const bookTimeSlot = async (req, res) => {
  try {
    const { doctorId, date, from } = req.body;
    const userId = req.user._id;

    if (!doctorId || !date || !from) {
      return res.status(400).json({ message: "Doctor ID, date, and start time ('from') are required" });
    }

    const schedule = await Schedule.findOne({ doctor: doctorId, date });

    if (!schedule) {
      return res.status(404).json({ message: "No schedule found for this date" });
    }

    const slotIndex = schedule.timeSlots.findIndex(slot => slot.from === from);

    if (slotIndex === -1) {
      return res.status(404).json({ message: "Time slot not found for this start time" });
    }

    if (schedule.timeSlots[slotIndex].isBooked) {
      return res.status(400).json({ message: "Time slot already booked" });
    }

    schedule.timeSlots[slotIndex].isBooked = true;
    schedule.timeSlots[slotIndex].bookedBy = userId;
    await schedule.save();

    res.json({
      message: "Time slot booked successfully",
      bookedSlot: schedule.timeSlots[slotIndex]
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};





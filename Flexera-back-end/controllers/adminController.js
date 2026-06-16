import Doctor from "../models/doctorModel.js";
import User from "../models/userModel.js";
import Schedule from "../models/scheduleModel.js";
import Appointment from "../models/Appointment.js";
import notificationSchema from "../models/notificationModel.js";
import { v2 as cloudinary } from "cloudinary";

import streamifier from "streamifier";
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});
///

export const getAllDoctors = async (req, res) => {
  try {
    const doctors = await Doctor.find().sort({ createdAt: -1 });
    res.json({ doctors });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

export const addDoctor = async (req, res) => {
  try {
    const { name, email, speciality, phone, bio } = req.body;
    console.log(" addDoctor called with:", { name, email, speciality, phone, bio });

  
    const exists = await Doctor.findOne({ email });
    if (exists) {
      console.log(` Doctor with email ${email} already exists`);
      return res.status(400).json({ message: "Doctor email already exists" });
    }

 
    const doctor = await Doctor.create({ name, email, speciality, phone, bio });
    console.log(" Doctor created:", doctor._id);


    const notificationService = req.app.get("notificationService"); 

    if (notificationService) {
      console.log(` Triggering doctorAdded notification for: ${doctor.name}`);
      
     
      await notificationService.doctorAdded(doctor);

    } else {
      console.error(" NotificationService not found in req.app");
    }

   
    res.status(201).json({ message: "Doctor added", doctor });

  } catch (err) {
    console.error(" Error in addDoctor:", err);
    res.status(500).json({ message: "Server error" });
  }
};


import mongoose from "mongoose";

export const deleteDoctor = async (req, res) => {
  try {
    const { id } = req.params;

    // 1. التحقق إذا كان الـ ID المرسل هو ObjectId صالح أم مجرد نص (مثل 666666)
    const isObjectId = mongoose.Types.ObjectId.isValid(id);

    // 2. مسح الجداول (Schedules)
    // هنا بنمسح بأي شكل سواء ObjectId أو String عشان نضمن التنظيف
    await Schedule.deleteMany({ 
      $or: [{ doctor: id }, { doctor: id.toString() }] 
    });

    // 3. مسح المواعيد (Appointments) بحذر
    // لو الـ ID صالح كـ ObjectId هنمسح بيه، لو مش صالح هنمسح كـ String فقط 
    // ده هيمنع ظهور الـ Cast Error اللي حصل معاكي
    if (isObjectId) {
      await Appointment.deleteMany({ doctor: id });
    } else {
      // لو الـ ID نصي زي "666666"، هنحاول نمسحه لو متخزن كـ string
      await Appointment.deleteMany({ doctor: id.toString() }).catch(err => {
        console.log("Skipping Appointment delete due to type mismatch");
      });
    }

    // 4. مسح الدكتور نفسه
    let doc;
    if (isObjectId) {
      doc = await Doctor.findByIdAndDelete(id);
    } else {
      doc = await Doctor.findOneAndDelete({ 
        $or: [{ _id: id }, { email: id }] 
      });
    }

    if (!doc) {
      return res.status(404).json({ 
        success: false, 
        message: "Doctor not found" 
      });
    }

    res.json({ 
      success: true, 
      message: "Doctor and related data removed successfully" 
    });

  } catch (err) {
    console.error("Delete Error:", err);
    res.status(500).json({ 
      success: false, 
      message: "Server error during deletion", 
      error: err.message 
    });
  }
};
export const updateDoctor = async (req, res) => {
  try {
    const { id } = req.params;
    let updates = { ...req.body };
    if (req.file) {
      const streamUpload = () =>
        new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            { folder: "doctors" },
            (error, result) => {
              if (error) reject(error);
              else resolve(result);
            }
          );
          streamifier.createReadStream(req.file.buffer).pipe(stream);
        });

      const result = await streamUpload();
      updates.image = result.secure_url;
    }

    const doctor = await Doctor.findByIdAndUpdate(id, updates, { new: true });

    if (!doctor) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    res.json({ message: "Doctor updated", doctor });

  } catch (err) {
    console.error("UPDATE DOCTOR ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ email: { $ne: "staffflexera@gmail.com" } })
      .select("name email phone dob image createdAt")
      .sort({ createdAt: -1 }) 
      .lean();

    const usersWithAge = users.map(user => {
      const age = user.dob
        ? new Date().getFullYear() - new Date(user.dob).getFullYear()
        : null;

      return {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone || "N/A",
        age,
        image: user.image || null,
      };
    });

    res.json({ users: usersWithAge });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

export const logoutStaff = (req, res) => {
  res.cookie("token", "", { httpOnly: true, expires: new Date(0), sameSite: "strict" });
  res.json({ message: "Staff logged out successfully" });
};
export const getAllPaidAppointmentsForStaff = async (req, res) => {
  try {
    if (req.user.role !== "staff") {
      return res.status(403).json({ message: "Access denied" });
    }

    const schedules = await Schedule.find({
      "timeSlots.paymentStatus": "paid",
    })
      .populate("doctor", "_id name image")
      .populate("timeSlots.bookedBy", "_id name image");

    const appointments = [];

    schedules.forEach((schedule) => {
      schedule.timeSlots.forEach((slot) => {
        if (slot.paymentStatus === "paid" && slot.bookedBy) {
          appointments.push({
            patient: {
              id: slot.bookedBy._id,
              name: slot.bookedBy.name,
              image: slot.bookedBy.image || null,
            },
            doctor: {
              id: schedule.doctor?._id || null,
              name: schedule.doctor?.name || null,
              image: schedule.doctor?.image || null,
            },
            date: schedule.date,
            time: `${slot.from} - ${slot.to}`,
            orderId: slot.orderId,
          });
        }
      });
    });

    return res.json({
      success: true,
      appointments,
    });

  } catch (err) {
    console.error("Error in getAllPaidAppointmentsForStaff:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
//////////////////////
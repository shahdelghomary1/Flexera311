import { useEffect, useState } from "react";
import Navbar from "../../../Component/Navbar/Navbar";
import { Steps } from "antd";
import axios from "axios";
import { getToken } from "../../../utility";
import moment from "moment";
import { useLocation, useNavigate } from "react-router-dom";
import { Calendar, Row, Col, Button } from "antd";
import {
  ClockCircleOutlined,
  ArrowLeftOutlined,
  ExclamationCircleOutlined,
  UserOutlined
} from "@ant-design/icons";
import doctorTool from "../../../assets/images/doctorTool.svg";
import fees from "../../../assets/images/fees.svg";
import IconCalendar from '../../../assets/images/IconCalendar.png'
import "./SelectAppointments.css";

const items = [
  {
    title: "Choose Doctor",
  },
  {
    title: "Select appointment",
  },
  {
    title: "Payment Info",
  },
  {
    title: " Confirmation",
  },
];

function SelectAppointments() {
  const location = useLocation()
  const navigate = useNavigate()
  const [selectedDoctor, setSelectedDoctor] = useState(null)
  const [selectedDate, setSelectedDate] = useState(moment().format("YYYY-MM-DD"))
  const [selectedTime, setSelectedTime] = useState(null)
  const [doctorSchedule, setDoctorSchedule] = useState([]);
  const [availableSlots, setAvailableSlots] = useState([]);

  console.log('location>>', location.state)

  useEffect(() => {
    if (location.state.doctor) {
      setSelectedDoctor(location.state.doctor)
      fetchSchedule(location.state.doctor._id);
    } else {
      navigate('/Booking')
    }
  }, [])

  useEffect(() => {
    if (doctorSchedule.length === 0) return;
    const selectedDaySchedule = doctorSchedule.find((day) => {
      return day.date === selectedDate;
    });

    setAvailableSlots(selectedDaySchedule?.timeSlots);
  }, [selectedDate, doctorSchedule]);

  const fetchSchedule = (doctorId) => {
    axios
      .get(
        `https://flexera.vercel.app/api/auth/doctor-schedule?doctorId=${doctorId}`,
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${getToken()}`,
          },
        }
      )
      .then((res) => {
        setDoctorSchedule(res.data.schedules);
      })
      .catch((err) => { });
  };

  const handleSelectedDate = (date) => {
    setSelectedDate(
      date.format("YYYY-MM-DD"),
    );
  };

  const handleSelectTime = (time) => {
    setSelectedTime(time);
  };


  const handleGoingBack = () => {
    navigate('/Booking')
  }

  const handleGoNext = () => {
    if (!selectedDate || !selectedTime) return;

    navigate('/PaymentDetails', {
      state: {
        doctor: selectedDoctor,
        selectedDate,
        selectedTime,
        price: doctorSchedule[0]?.doctor?.price
      }
    })
  }
  return (
    <div className="select_appointment_page">
      <Navbar activeTab={1} />
      <div className="select_appointment_StepperContainer">
        <Steps
          current={1}
          titlePlacement="vertical"
          items={items}
          ellipsis
          className="select_appointment_page_stepper_style"
        />
      </div>
      <div className="select_appointment_container">
        <Row>
          <Col sm={24} lg={9} xs={24}>
            <button className="back_btn" onClick={handleGoingBack}>
              <ArrowLeftOutlined />
            </button>
            <div className="select_appointment_doctor_info">
              <div className="img_container_doctor_img">
                {selectedDoctor?.image && selectedDoctor?.image.length > 0 ? <img
                  src={selectedDoctor?.image}
                  alt="doctor"
                  className="select_appointment_doctor_img"
                />
                  : <UserOutlined className="dummy_user_image" />
                }
              </div>

              <div className="doctor_name_div">
                <img src={doctorTool} alt="doctorTool.svg" className="info_img" />
                <p className="doctor_info">{selectedDoctor?.name}</p>
              </div>
              <div className="doctor_fees_div">
                <img src={fees} alt="doctorTool.svg" className="info_img" />
                <p className="doctor_info">
                  Consultation Fee:{" "}
                  <span className="fees_amount">{doctorSchedule?.length > 0
                    ? doctorSchedule[0]?.doctor?.price
                    : 0}{" "}
                    EGP</span>
                </p>
              </div>
            </div>
          </Col>
          <Col lg={15} className="calendar_col" sm={24} sx={24}>
            <div className="calendar_info_container">
              <img src={IconCalendar} alt='IconCalendar.png' className="select_date_icon" />
              <p className="calendar_title">Select Date </p>
            </div>
            <div className="calendar_container">
              <Calendar
                fullscreen={false}
                showWeek
                disabledDate={(date) => {
                  if (date.endOf("d").valueOf() < new Date()) {
                    return true;
                  }
                  return false;
                }}
                onSelect={(date) => {
                  handleSelectedDate(date);
                }}
              />
              <div className="divider" />
            </div>
            <div className="calendar_info_container">
              <ClockCircleOutlined className="calendar_icon" />
              <p className="calendar_title">Select Time </p>
            </div>
            <div className="slots_container">
              {availableSlots && availableSlots.length > 0 ? (
                availableSlots?.map((slot) => {
                  return (
                    <span
                      className={
                        slot.isBooked ?
                          "booked_slot" :
                          selectedTime === slot.from
                            ? "active_slot"
                            : "slot_style"
                      }
                      onClick={() => {
                        if (!slot?.isBooked) {
                          handleSelectTime(slot?.from);
                        }
                      }}
                    >
                      {moment(slot?.from, "HH:mm").format("h:mm A")}
                    </span>
                  );
                })
              ) : (
                <div className="select_appoitment_empty_result">
                  <ExclamationCircleOutlined className="emlty_slots_icon" />
                  <p className="select_appoitment_text">
                    No available slots right now, please choose another day or
                    another doctor
                  </p>
                </div>
              )}
            </div>
          </Col>
        </Row>
        <div className="select_appoitment_next_btn_container">
          <Button
            className="select_appoitment_page_next_btn"
            onClick={() => {

              handleGoNext()
            }}
            disabled={!selectedDate || !selectedTime}
          >
            Continue
          </Button>
        </div>
      </div>
    </div>
  );
}

export default SelectAppointments;

import { useEffect, useState } from "react";
import Navbar from "../../../Component/Navbar/Navbar";
import { Steps, Row, Col, Button } from "antd";
import { ArrowLeftOutlined } from "@ant-design/icons";
import doctorTool from "../../../assets/images/doctorTool.svg";
import calendar from '../../../assets/images/calendar.png'
import axios from "axios";
import { getToken } from "../../../utility";
import moment from "moment";
import { useNavigate, useLocation } from "react-router-dom";
import "./PaymentDetails.css";

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

function PaymentDetails() {
  const navigate = useNavigate()
  const location = useLocation()
  const [selectedDoctor, setSelectedDoctor] = useState(null)
  const [selectedDate, setSelectedDate] = useState(moment().format("dddd, MMMM Do"))
  const [selectedTime, setSelectedTime] = useState(null)
  const [price, setPrice] = useState(null)
  const [createAppointmentLoading, setCreateAppointmentLoading] =
    useState(false);
  console.log('location.state>>>', location.state)
  console.log('selectedDoctor>', selectedDoctor)
  console.log('selectedDate>', selectedDate)
  console.log('selectedTime>', selectedTime)
  console.log('price>', price)
  useEffect(() => {
    if (location.state.doctor || location.state.selectedDate || location.state.selectedTime || location.state.price) {
      setSelectedDoctor(location.state?.doctor)
      setSelectedDate(location.state?.selectedDate)
      setSelectedTime(location.state?.selectedTime)
      setPrice(location.state?.price)
    } else {
      navigate('/Booking')
    }
  }, [])

  const createAppointment = () => {
    setCreateAppointmentLoading(true);
    const data = {
      doctorId: selectedDoctor._id,
      date: selectedDate,
      from: selectedTime,
    };
    axios
      .post("https://flexera.vercel.app/api/paymob/init", data, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((res) => {
        console.log("res>>>", res);
        window.location.href = res.data.payment_url
      })
      .catch((err) => {
        console.log("errr<<<", err);
        alert("Payment failed");

      })
      .finally(() => {
        setCreateAppointmentLoading(false);
      });
  };

  const handleGoingBack = () => {
    navigate('/SelectAppointments', { state: { doctor: selectedDoctor } })
  }


  return (
    <div className="payment_details_page">
      <Navbar activeTab={1} />
      <div className="StepperContainer">
        <Steps
          current={2}
          titlePlacement="vertical"
          items={items}
          ellipsis
          className="booking_page_stepper_style"
        />
      </div>
      <div>
        <div className="Payment_section">
          <Row gutter={16}>
            <Col span={24} style={{ display: "flex", padding: 0 }}>
              <div className="price_section">
                <button className="payment_back_btn" onClick={handleGoingBack}>
                  <ArrowLeftOutlined />
                </button>
                <div>
                  <p className="Payment_section_title">You’re paying,</p>
                  <h1 className="Payment_section_price">EGP {price}</h1>
                </div>
                <div className="doctor_name_div_payment">
                  <img src={doctorTool} alt="doctorTool.svg" className="info_img" />
                  <p className="payment_section_doctor_info">{selectedDoctor?.name}</p>
                </div>
                <div className="doctor_name_div_payment">
                  <img src={calendar} alt='calendar.png' className="info_img" />
                  <p className="payment_section_doctor_info">
                    {moment(selectedTime, "HH:mm").format("h:mm A")} , {moment(selectedDate).format("dddd, MMMM Do")}
                  </p>
                </div>
              </div>
            </Col>
          </Row>
          <div className="payment_section_btn_div">
            <Button className="payment_section_submit_btn" loading={createAppointmentLoading}
              onClick={createAppointment}>Continue</Button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default PaymentDetails;

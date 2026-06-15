import { useEffect, useState } from "react";
import Navbar from "../../../Component/Navbar/Navbar";
import { Steps } from "antd";
import axios from "axios";
import { getToken } from "../../../utility";
import moment from "moment";
import { useNavigate } from "react-router-dom";
import SearchBar from "../../../Component/SearchBar/SearchBar";
import LoaderComponent from "../../../Component/DashboardComponents/LoaderComponent/LoaderComponent";
import alertTriangle from '../../../assets/images/alert-triangle.png'
import { UserOutlined } from '@ant-design/icons'
import "./SelectDoctor.css";

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

function SelectDoctor() {
  const navigate = useNavigate()
  const [isFetchDoctorsLoader, setIsFetchDoctorsLoader] = useState(false);
  const [allDoctors, setAlldoctors] = useState([]);
  const [filteredDoctors, setFilteredDoctors] = useState([]);
  const [bookingInfo, setBookingInfo] = useState(null);

  useEffect(() => {
    fetchDoctors();
  }, []);

  const fetchDoctors = () => {
    setIsFetchDoctorsLoader(true);
    axios
      .get("https://flexera.vercel.app/api/auth/authdoctors", {
        headers: {
          "Content-Type": "multipart/form-data",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((res) => {
        setAlldoctors(res.data.doctors);
        setFilteredDoctors(res.data.doctors);
      })
      .catch((error) => { console.log('error>>,', error) })
      .finally(() => {
        setIsFetchDoctorsLoader(false);
      });
  };

  const handleDoctorSearch = (value) => {
    if (value.length === 0) {
      setFilteredDoctors(allDoctors);
      return;
    }
    setFilteredDoctors(
      allDoctors.filter(
        (doctor) =>
          doctor.name.toLowerCase().includes(value.toLowerCase().trim()) ||
          doctor._id.toLowerCase().includes(value.toLowerCase().trim())
      )
    );
  };

  const handleSelectDoctor = async (doctor) => {
    setBookingInfo({
      doctor: doctor,
      selectedDate: moment().format("YYYY-MM-DD"),
    });
    navigate('/SelectAppointments', {
      state: {
        doctor: doctor,
      }
    })
  };


  return (
    <div className="booking_page">
      <Navbar activeTab={1} />
      <p className="booking_page_title">Choose Doctors</p>
      <div className="StepperContainer">
        <Steps
          current={0}
          titlePlacement="vertical"
          items={items}
          ellipsis
          dotSize={10}
          className="booking_page_stepper_style"

        />
      </div>
      {isFetchDoctorsLoader ?
        <LoaderComponent />
        :
        <div className="selectDoctor_white_container">
          <div className="search_container">
            <SearchBar
              handleSearch={handleDoctorSearch}
            />
          </div>
          {filteredDoctors.length > 0 ? (
            <>
              <div className="doctor_row">
                {filteredDoctors.length > 0 &&
                  filteredDoctors?.map((doctor) => {
                    return (
                      <div
                        className="doctor_card"
                        key={`doctor_${doctor._id}`}
                      >
                        <div
                          className={
                            bookingInfo?.doctor?._id === doctor._id
                              ? "doctor_card_content selected_doctor"
                              : "doctor_card_content "
                          }
                          onClick={() => handleSelectDoctor(doctor)}
                        >
                          <div className="doctor_img_container">
                            {doctor?.image && doctor?.image.length > 0 ? <img
                              src={doctor.image}
                              alt="doctor"
                              className="doctor_img"
                            />
                              : <UserOutlined className="dummy_user_image_card" />
                            }
                          </div>
                          <p className="doctor_name">{doctor.name}</p>
                        </div>
                      </div>
                    );
                  })}
              </div>
            </>
          ) : (
            <div className="empty_result">
              <img src={alertTriangle} alt='alertTriangle' className="alertTriangle" />
              <p className="empty_text">Unfortunately, The doctor is not available</p>
            </div>
          )}
        </div>}
    </div>
  );
}

export default SelectDoctor;

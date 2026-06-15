import logo from "../../../assets/images/logo.png";
import usersGroup from "../../../assets/images/usersGroup.png";
import axios from 'axios';
import { getToken } from "../../../utility";
import { googleLogout } from '@react-oauth/google';
import { useNavigate } from "react-router-dom";
import "./SideMenu.css";
import { useEffect, useState } from "react";
import doubleArrow from '../../../assets/images/doubleArrow.png'

function SideMenu() {
  const navigate = useNavigate();
  const [allPatients, setAllPatients] = useState([])

  useEffect(() => {
    fetchPatients()
  }, [])

  const handleLogout = () => {
    const currentUser = JSON.parse(sessionStorage.getItem("user"));
    const data = {
      email: currentUser?.email,
    };

    axios
      .post("https://flexera.vercel.app/api/admin/logout/staff", data, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then(() => {
        googleLogout();
        sessionStorage.clear();
        navigate("/");
      })
      .catch((error) => {
        console.log("error>", error);
      });
  };

  const fetchPatients = () => {
    axios
      .get("https://flexera.vercel.app/api/admin/users", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((response) => {
        setAllPatients(response.data.users);
      })
      .catch((error) => {
        console.error(error);
      });
  }
  return (
    <div className="dashboard_sidemenu_contianer">
      <div className="dashboard_logo_container">
        <img src={logo} alt="logo" className="dashboard_logo" />
      </div>
      <div className="dashboard_info">
        <div className="dashboard_info_img_container">
          <img src={usersGroup} alt="usersGroup" className="dashboard_info_img" />
        </div>
        <div>
          <p className="sidemenu_title">Total patients</p>
          <p className="total_patients">{allPatients?.length}</p>
        </div>

      </div>
      <div className="logout_container" onClick={handleLogout}>
        <p className="logout_text">Logout</p>
        <img src={doubleArrow} alt='doubleArrow' />
      </div>
    </div>
  );
}

export default SideMenu;

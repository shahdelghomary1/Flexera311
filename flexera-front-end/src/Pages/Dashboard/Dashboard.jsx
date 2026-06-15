import SideMenu from "../../Component/DashboardComponents/SideMenu/SideMenu";
import { Tabs } from "antd";
import Patients from "../../Component/DashboardComponents/Patients/Patients";
import Doctors from "../../Component/DashboardComponents/Doctors/Doctors";
import Appointments from "../../Component/DashboardComponents/Appointments/Appointments";
import WavingHand from "../../assets/images/WavingHand.png";
import logo from "../../assets/images/logo.png";
import "./Dashboard.css";

const initialItems = [
  { label: "Patients", children: <Patients />, key: "1" },
  { label: "Doctors", children: <Doctors />, key: "2" },
  {
    label: "Appointments",
    children: <Appointments />,
    key: "3",
  },
];

function Dashboard() {
  return (
    <div className="dashboard">
      <div className="dashboard_sidemenu">
        <SideMenu />
      </div>
      <div className="dashboard_content">
        <div className="small_screen_header">
          <img src={logo} alt="logo" className="dashboard_logo" />

        </div>
        <div className="welcoming_container">
          <h1 className="welcome_style">Welcome</h1>
          <div className="sub_welcoming_container">
            <p className="back_style">back</p>
            <img src={WavingHand} alt="WavingHand" />
          </div>
        </div>
        <Tabs
          //   onChange={onChange}
          type="card"
          items={initialItems}
        />
      </div>
    </div>
  );
}

export default Dashboard;

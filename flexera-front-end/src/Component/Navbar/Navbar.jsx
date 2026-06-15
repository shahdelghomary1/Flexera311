import { useState, useMemo } from "react";
import logo from "../../assets/images/logo.png";
import { listItems } from "./ListItems";
import { useNavigate } from "react-router-dom";
import { getToken } from "../../utility";
import { Button } from "antd";
import WavingHand from "../../assets/images/WavingHand.png";
import axios from "axios";
import { MenuOutlined, LogoutOutlined } from '@ant-design/icons';
import { googleLogout } from '@react-oauth/google';
import "./Navbar.css";

function Navbar({ activeTab }) {
  const navigate = useNavigate();
  const [openMenu, setOpenMenu] = useState(false)
  const currentUser = JSON.parse(sessionStorage.getItem("user"));
  const userToken = getToken();

  const handleActiveItem = (item) => {
    console.log("item.", item);
    navigate(item.path);
  };

  const handleLogout = () => {
    const data = {
      email: currentUser?.email,
    };
    axios
      .post("https://flexera.vercel.app/api/auth/logout", data, {
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

  const handleOpenMenu = () => {
    setOpenMenu(!openMenu)
  }

  const navbarClass = useMemo(() => {
    if (location.pathname === "/") return "navbar_container home_nav";

    return "navbar_container";
  }, [location.pathname]);


  return (
    <>
      <div className={navbarClass}>
        <div className="logo_container">
          <img src={logo} alt="logo" className="logo_style" />
        </div>
        <div className="navbar_lg_screen_list_container">
          <ul className="list_container">
            {listItems.map((item, index) => {
              return (
                <li
                  onClick={() => {
                    handleActiveItem(item);
                  }}
                  className="list_item_style"
                >
                  <p className="list_item_text">{item.name}</p>
                  {activeTab === index && (
                    <span className="activeIndicator"></span>
                  )}
                </li>
              );
            })}
          </ul>
        </div>
        <div className="navbar_lg_screen_action_div">
          {userToken ? (
            <div className="authorized_user">
              <div className="authorized_user_info">
                <p className="authorized_user_greating">
                  Good Morning <img src={WavingHand} alt="WavingHand" />
                </p>
                <p className="authorized_user_name">{currentUser?.name}</p>
              </div>
              <Button onClick={handleLogout} className="logoutBtn">Logout <LogoutOutlined /></Button>
            </div>
          ) : (
            <button
              className="signUpBtn"
              onClick={() => {
                navigate("/signup");
              }}
            >
              Sign-up
            </button>
          )}
        </div>
        <div className="navbar_toggle" >
          <MenuOutlined className="menu_icon" onClick={handleOpenMenu} />
        </div>
      </div>

      {openMenu && <div className="navbar_small_screen_menu">
        <ul className="small_screen_list_container">
          {listItems.map((item, index) => {
            return (
              <li
                onClick={() => {
                  handleActiveItem(item);
                }}
                className="list_item_style"
              >
                <div className="list_item_container">
                  {activeTab === index && (
                    <span className="small_screen_activeIndicator">


                    </span>
                  )}
                  <p className="list_item_text">{item.name}</p>
                </div>
              </li>
            );
          })}
        </ul>
        {userToken ?
          <Button onClick={handleLogout} className="small_screen_logoutBtn">Logout <LogoutOutlined /></Button>
          :
          <button
            className="small_screen_signup_btn"
            onClick={() => {
              navigate("/signup");
            }}
          >
            Sign-up
          </button>
        }
      </div>}
    </>
  );
}

export default Navbar;

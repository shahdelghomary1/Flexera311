import "./HomeFooter.css";
import whiteLogo from "../../assets/images/whiteLogo.png";
import Facebook from "../../assets/images/Facebook.png";
import X from "../../assets/images/X.png";
import Instagram from "../../assets/images/Instagram.png";
import Gmail from "../../assets/images/Gmail.png";
import homeFooter from "../../assets/images/homeFooter.png";
import { useLocation } from "react-router-dom";
import { useEffect, useState } from "react";
function HomeFooter() {
  const location = useLocation()
  const [currentPath, setCurrentPath] = useState('')

  useEffect(() => {
    console.log('location.pathname>', location.pathname)
    setCurrentPath(location.pathname)
  }, [location])

  return (
    <div className="home_footer">
      <div className={currentPath && currentPath.includes('ContactUs') ? "small_home_footer_info" : "home_footer_info"}>
        <img src={whiteLogo} alt="logo" className="home_footer_logo" />

        <div className={currentPath && currentPath.includes('ContactUs') ? "small_footer_info_container" : ""}>
          <p className="home_footer_desc">
            Your trusted partner in recovery and rehabilitation.
          </p>
          <p className="home_footer_desc">
            We help patients follow their physical therapy journey through
            personalized exercises and progress tracking.
          </p>
        </div>

        {currentPath && !currentPath.includes('ContactUs') && <div className="social_media_container">
          <img src={Facebook} alt="facebook" />
          <img src={Instagram} alt="Instagram" />
          <img src={X} alt="X" />
          <img src={Gmail} alt="Gmail" />
        </div>}

        {currentPath && !currentPath.includes('ContactUs') && <div className="contact_us_container">
          <p className="contact_us_info">Contact Us</p>
          <p className="contact_us_info">📞 (+20) 123 456 7890</p>
          <p className="contact_us_info">✉️ support@Flexera117.com</p>
        </div>
        }

        <div className="copy_rights_container">
          <p className="copy_rights_info">
            © 2025 Flexera Recovery System. All rights reserved.
          </p>
          <p className="copy_rights_info">
            Helping patients recover better through smart physical therapy
            solutions.
          </p>
        </div>
      </div>

      <div className={currentPath && currentPath.includes('ContactUs') ? "small_home_footer_img" : "home_footer_img"}>
        <img src={homeFooter} alt="homeFooter" className={
          currentPath && currentPath.includes('ContactUs') ? "small_home_footer_img_style" : "home_footer_img_style"} />
      </div>
    </div >
  );
}

export default HomeFooter;

import React from "react";
import howItWorks from "../../assets/images/howItWorks.gif";
import "./HowItWorkSection.css";
function HowItWorkSection() {
  return (
    <div className="howItWorksSection">
      <div className="howItWorks_info_container">
        <p className="howItWorks_title">How it works</p>
        <div className="howItWorks_img_container_small_screen">
          <img src={howItWorks} alt="howItWorks" className="howItWorks_img" />
        </div>
        <p className="howItWorks_desc">
          The system helps users follow their recovery exercises, track their
          progress, and receive personalized guidance from specialists.
        </p>
        <p className="howItWorks_desc">
          Our goal is to make the rehabilitation process easier, more effective,
          and accessible for everyone.
        </p>
      </div>
      <div className="howItWorks_img_container">
        <img src={howItWorks} alt="howItWorks" className="howItWorks_img" />
      </div>
    </div>
  );
}

export default HowItWorkSection;

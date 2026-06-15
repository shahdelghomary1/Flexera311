import React from "react";
import expertsPeople from "../../assets/images/HowDoctor.png";
import "./ExpertsSection.css";
function ExpertsSection() {
  return (
    <div className="experts_section">
      <p className="experts_section_title">Meet Our Experts</p>
      <div className="experts_container">
        <img
          src={expertsPeople}
          alt="expertsPeople"
          className="expertsPeople_img"
        />
      </div>
      <p className="experts_section_subtitle">
        At Flexera, our people are our greatest strength
      </p>
      <div className="experts_section_qoute">
        <p className="experts_section_qoute_text">
          We are proud to have a multidisciplinary team of licensed
          physiotherapists, rehabilitation specialists, and wellness coaches.
        </p>
        <p className="experts_section_qoute_text">
          Each member of our staff brings extensive clinical experience and a
          genuine passion for patient care.
        </p>
      </div>
    </div>
  );
}

export default ExpertsSection;

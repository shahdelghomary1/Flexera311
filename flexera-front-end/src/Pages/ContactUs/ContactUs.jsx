import HomeFooter from "../../Component/HomeFooter/HomeFooter";
import Facebook from "../../assets/images/face_contact.png";
import X from "../../assets/images/x_contact.png";
import Instagram from "../../assets/images/insta_contact.png";
import Gmail from "../../assets/images/gmail_contact.png";
import contanctUsArrow from '../../assets/images/contanctUsArrow.png'
import Navbar from "../../Component/Navbar/Navbar";
import locationIcon from '../../assets/images/locationIcon.png'
import emailIcon from '../../assets/images/emailIcon.png'
import phoneIcon from '../../assets/images/phoneIcon.png'
import { Button } from 'antd'
import "./ContactUs.css";
import { useState } from "react";
import axios from "axios";
import { ToastContainer, toast } from 'react-toastify';

const initialForm = {
  firstName: null,
  lastName: null,
  email: null,
  phone: null,
  message: null
}
const ContactUs = () => {
  const [form, setForm] = useState(initialForm)
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };


  const handleContactUs = () => {
    const hasNull = Object.values(form).some(value => value === null);
    if (hasNull) return false

    setForm(initialForm)
    toast('Your message sent successfully, We will get back to you soon!', { type: 'success' });
    console.log('form>', form)
  }

  return (
    <div className="contact-container">
      <ToastContainer />

      <Navbar activeTab={2} />
      <div className="contact-flex-grow">
        <div className="contact-text-center">
          <h1 className="contact-title">Contact Us</h1>
          <p className="contact-subtitle">
            Any question or remarks? Just write us a message!
          </p>
        </div>
        <div className="contact-form-container">
          <div className="contact-left-side">
            <div className="left_side_container">

              <div className="contact-info-section">
                <h2 className="contact-info-title">Contact Information</h2>
                <p className="contact-info-subtitle">Say something to start a live chat!</p>
              </div>
              <div className="contact_info_container">
                <div className="contact_info_value">
                  <img src={phoneIcon} alt='locationIcon' />
                  <p>
                    (+20) 123 456 7890
                  </p>
                </div>
                <div className="contact_info_value">
                  <img src={emailIcon} alt='locationIcon' />
                  <p>
                    support@Flexera117.com
                  </p>
                </div>
                <div className="contact_info_value">
                  <img src={locationIcon} alt='locationIcon' />
                  <p>
                    El-Maddie
                  </p>
                </div>
              </div>
              <div className="social-media-container">
                <img src={Facebook} alt="facebook" className="social-icon" />
                <img src={Instagram} alt="Instagram" className="social-icon" />
                <img src={X} alt="X" className="social-icon" />
                <img src={Gmail} alt="Gmail" className="social-icon" />
              </div>
            </div>
          </div>

          <div className="contact-right-side">
            <form className="contact_us_form">
              <div className="contact-form-row">
                <div className="contact-half-width contact-input-group">
                  <label htmlFor="firstName" className="contact-input-label">First Name</label>
                  <input type="text" id="firstName" value={form.firstName || ""}
                    name='firstName' className="contact-input-field" onChange={handleChange} />
                </div>
                <div className="contact-half-width contact-input-group">
                  <label htmlFor="lastName" className="contact-input-label">Last Name</label>
                  <input type="text" id="lastName" value={form.lastName || ""}
                    name='lastName' className="contact-input-field" onChange={handleChange} />
                </div>
              </div>
              <div className="contact-form-row">
                <div className="contact-half-width contact-input-group">
                  <label htmlFor="email" className="contact-input-label">Email</label>
                  <input type="email" id="email" value={form.email || ""}
                    name='email' className="contact-input-field" onChange={handleChange} />
                </div>
                <div className="contact-half-width contact-input-group">
                  <label htmlFor="phone" className="contact-input-label">Phone Number</label>
                  <input type="tel" id="phone" name='phone' value={form.phone || ""}
                    className="contact-input-field" onChange={handleChange} />
                </div>
              </div>
              <div className="contact-input-container">
                <label htmlFor="message" className="contact-input-label">Message</label>
                <textarea id="message" rows="4" name='message' value={form.message || ""}
                  className="contact-textarea-field" placeholder="Write your message.." onChange={handleChange}></textarea>
              </div>
              <div className="contact-form-footer">
                <Button
                  htmltype="submit"
                  className="contact-submit-btn"
                  onClick={handleContactUs}
                >
                  Send Message
                </Button>
              </div>
              <div className="contanctus_arrow_div">
                <img src={contanctUsArrow} alt='contanctUsArrow' className="contanctus_arrow" />
              </div>
            </form>
          </div>
        </div>
      </div>
      <HomeFooter />
    </div>
  );
};

export default ContactUs;

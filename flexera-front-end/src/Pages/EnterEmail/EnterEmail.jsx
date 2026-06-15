import { useState } from "react";
import "./EnterEmail.css";
import Stepper from "../../Component/Stepper/Stepper";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { Input, Button } from 'antd';
import { MailOutlined } from '@ant-design/icons'
import { ToastContainer, toast } from 'react-toastify';

export default function EnterEmail() {
  const navigate = useNavigate();
  const [emailValue, setEmailValue] = useState(null);
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false)

  const sendEmail = () => {
    if (emailValue === null || emailValue === "") {
      setError("Email is required");
      return;
    } else if (!/\S+@\S+\.\S+/.test(emailValue)) {
      setError("please enter a valid email");
      return;
    }
    const data = {
      email: emailValue,
    };
    setIsLoading(true)
    axios
      .post("https://flexera.vercel.app/api/auth/forgot-password", data, {
        headers: {
          "Content-Type": "application/json",
        },
      })
      .then((res) => {
        console.log("sendEmail ress>", res);
        navigate("/CheckEmail", {
          state: { email: emailValue, tempToken: res.data.tempToken },
        });
      })
      .catch((error) => {
        console.log("sendEmail reerrorss>", error);
        if (error.response.data.message) {
          toast(error.response.data.message, { type: 'error' });
        }
        else if (error.response.data.errors && error.response.data.errors.length > 0) {
          toast(error.response.data.errors[0], { type: 'error' });
        }
      }).finally(() => {
        setIsLoading(false)
      });
  };

  return (
    <>
      <div className="forgot-page">
        <Stepper activeStep={1} />
        <h1 className="enter_email_title">
          <span className="forgot-text">Forgot</span>
          <span className="password-text">your password</span>
        </h1>
        <p className="enter_email_description">
          Enter your email address and <br /> we’ll send you a verification code
        </p>

        <Input
          type="email"
          placeholder="Enter Your Email"
          className="email-input"
          onChange={(e) => {
            setEmailValue(e.target.value);
            setError(null);
          }}
          suffix={<MailOutlined />}
        />
        {error && (
          <p style={{ color: "red" }} className="missingEmail">
            {error}
          </p>
        )}
        <Button loading={isLoading} htmlType='submit' className="enter_email_send_btn" onClick={sendEmail}>
          Send Code
        </Button>
      </div>
      <ToastContainer />
    </>
  );
}

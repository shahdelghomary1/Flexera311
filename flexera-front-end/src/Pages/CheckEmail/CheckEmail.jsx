import { useState, useEffect } from "react";
import "./CheckEmail.css";
import Stepper from "../../Component/Stepper/Stepper";
import { useNavigate, useLocation } from "react-router-dom";
import axios from "axios";
import { Input, Form, Button } from "antd";
import LoaderComponent from '../../Component/DashboardComponents/LoaderComponent/LoaderComponent'
import { ToastContainer, toast } from 'react-toastify';

export default function CheckEmail() {
  const navigate = useNavigate();
  const location = useLocation();
  const [form] = Form.useForm();
  const [isLoading, setIsLoading] = useState(false)
  const [isSendEmailLoading, setIsSendEmailLoading] = useState(false)
  const [tempToken, setTempToken] = useState("");
  const [userEmail, setUserEmail] = useState("");
  const [timeLeft, setTimeLeft] = useState(30);
  const [canResend, setCanResend] = useState(false);

  useEffect(() => {
    if (location.state?.tempToken && location.state.email) {
      setTempToken(location.state.tempToken);
      setUserEmail(location.state.email)
    } else {
      navigate('/EnterEmail')
    }
  }, [location.state]);

  useEffect(() => {
    if (timeLeft === 0) {
      setCanResend(true);
      return;
    }

    const timer = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft]);

  const formatTime = (seconds) => {
    const s = String(seconds).padStart(2, "0");
    return `00:${s}`;
  };

  const handleResendEmailAgain = () => {
    if (!canResend) return;

    const data = {
      email: userEmail,
    };
    setIsSendEmailLoading(true)
    axios
      .post("https://flexera.vercel.app/api/auth/forgot-password", data, {
        headers: {
          "Content-Type": "application/json",
        },
      })
      .then(() => {
        setTimeLeft(30);
        setCanResend(false);
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
        setIsSendEmailLoading(false)
      });

  };

  const sendOTP = (values) => {
    const data = {
      otp: values.otp,
    };
    setIsLoading(true)
    axios
      .post("https://flexera.vercel.app/api/auth/verify-otp", data, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tempToken}`,
        },
      })
      .then((res) => {
        navigate("/CreatePassword", {
          state: {
            resetToken: res.data.resetToken,
          },
        });
      })
      .catch((error) => {
        console.log("error", error);
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
    <div className="check-page">
      <Stepper activeStep={2} />
      <h1 className="check_email_title">
        <span className="check-text">Check</span>
        <span className="email-text">your email</span>
      </h1>

      <p className="check_email_description">
        We’ve sent you a 4-digit code.
        <br />
        Please enter it below.
      </p>
      <Form
        form={form}
        layout="vertical"
        onFinish={sendOTP}
      >
        <Form.Item
          name="otp"
          rules={[
            { required: true, message: "OTP is required" },
            { len: 4, message: "OTP must be 4 digits" }
          ]}        >
          <Input.OTP length={4} inputType="text" size="large" />
        </Form.Item>

        <Button className="verify-btn" htmlType="submit" loading={isLoading}>
          Verify
        </Button>
      </Form>
      <p className="resend-text" onClick={handleResendEmailAgain}>
        Didn’t receive the code?{" "}
        {isSendEmailLoading ?
          <span>
            <LoaderComponent height='10vh'
            />
          </span>
          : canResend ? (
            <span className="resend-link active">
              Send again
            </span>
          ) : (
            <span className="resend-link">
              Resend after {formatTime(timeLeft)}
            </span>
          )}
      </p>
      <ToastContainer />
    </div>
  );
}

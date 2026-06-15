import { useEffect, useState } from "react";
import "./CreatePassword.css";
import Stepper from "../../Component/Stepper/Stepper";
import axios from "axios";
import { Form, Input, Button } from "antd";
import { useNavigate, useLocation } from "react-router-dom";
import { ToastContainer, toast } from 'react-toastify';

export default function CreatePassword() {
  const [resetToken, setResetToken] = useState("");
  const [isLoading, setIsLoading] = useState(false)

  const [form] = Form.useForm();
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    if (location.state?.resetToken) {
      setResetToken(location.state.resetToken);
    } else {
      navigate('/EnterEmail')
    }
  }, [location.state]);

  const handleResetPassword = (values) => {
    const data = {
      newPassword: values.password,
      confirmPassword: values.confirm_password,
    };
    setIsLoading(true)
    axios
      .post("https://flexera.vercel.app/api/auth/reset-password", data, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${resetToken}`,
        },
      })
      .then(() => {
        navigate("/Signin");
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
    <div className="create-page">
      <Stepper />
      <div className="content-wrapper">
        <h1 className="new_password_title">
          <span className="create-text">Create</span>
          <span className="password-text">new password</span>
        </h1>

        <p className="description">Please enter your new password</p>

        <Form form={form} layout="vertical" onFinish={handleResetPassword}>
          <div className="password-container">
            <Form.Item
              name="password"
              rules={[{ required: true, message: "Enter password" }]}
            >
              <div className="input-wrapper">
                <Input.Password
                  placeholder="New Password"
                  className="create_password_input"
                />

              </div>
            </Form.Item>
            <Form.Item
              name="confirm_password"
              style={{ margin: 0 }}
              rules={[{ required: true, message: "Enter password" }]}
            >
              <div className="input-wrapper">
                <Input.Password
                  placeholder="Confirm Password"
                  className="create_password_input"
                  style={{
                    marginTop: '25px'
                  }} />
              </div>
            </Form.Item>
          </div>
          <div className="requirements">
            <p>Make sure that</p>
            <ul>
              <li>At least 8 characters</li>
              <li>One uppercase letter</li>
              <li>One lowercase letter</li>
              <li>Number and symbol</li>
            </ul>
          </div>
          <Button className="reset-btn" loading={isLoading} htmlType="submit">
            Reset Password
          </Button>
        </Form>
      </div>
      <ToastContainer />
    </div>
  );
}

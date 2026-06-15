import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useNavigate, useLocation } from "react-router-dom";
import LoginWithGoogle from '../../Component/LoginWithGoogle/LoginWithGoogle';
import "./style2.css";
import axios from "axios";
import { Input, Button } from 'antd'
import { MailOutlined, UserOutlined } from '@ant-design/icons'
import { ToastContainer, toast } from 'react-toastify';

export default function Signup() {
  const navigate = useNavigate();
  const location = useLocation();

  const [form, setForm] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: "",
  });
  const [errors, setErrors] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false)
  const comingFrom = location.state?.comingFrom || "/";

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    let errors = {};

    if (!form.name) {
      errors.name = "Name is required";
    }
    else if (form.name.length < 3) {
      errors.name = "The Name should at least contains 3 letters";
    }

    if (!form.email) {
      errors.email = "Email is required";
    } else if (!/\S+@\S+\.\S+/.test(form.email)) {
      errors.email = "Email is invalid";
    } else if (!form.email.endsWith("@gmail.com")) {
      errors.email = "Email must be a Gmail address";
    }

    if (!form.password) {
      errors.password = "Password is required";
    } else if (form.password.length < 8) {
      errors.password = "Password must be at least 8 characters";
    } else if (!/(?=.*[a-z])/.test(form.password)) {
      errors.password = "Password must contain at least one lowercase letter";
    } else if (!/(?=.*[A-Z])/.test(form.password)) {
      errors.password = "Password must contain at least one uppercase letter";
    } else if (!/(?=.*[!@#$%^&?*])/.test(form.password)) {
      errors.password = "Password must contain at least one special character";
    }
    if (!form.confirmPassword) {
      errors.confirmPassword = "Confirm password is required";
    } else if (form.confirmPassword.trim() !== form.password.trim()) {
      errors.confirmPassword = "Confirm password must equal the password";
    }
    return errors;
  };

  useEffect(() => {
    if (isSubmitted) {
      const validationErrors = validate();
      setErrors(validationErrors);
    }
  }, [isSubmitted, form])

  const handleSubmit = () => {
    setIsSubmitted(true)
    const validationErrors = validate();
    setErrors(validationErrors);

    if (Object.keys(validationErrors).length === 0) {
      const data = {
        name: form.name,
        email: form.email,
        password: form.password,
        confirmPassword: form.confirmPassword,
      };
      setIsLoading(true)
      axios
        .post("https://flexera.vercel.app/api/auth/register", data, {
          headers: {
            "Content-Type": "application/json",
          },
        })
        .then((response) => {
          sessionStorage.setItem("token", JSON.stringify(response.data.token));
          sessionStorage.setItem("user", JSON.stringify(response.data.user));
          navigate(`${comingFrom}` ?? "/", { replace: true });
        })
        .catch((error) => {
          console.log('error>>>', error)
          if (error.response.data.message) {
            toast(error.response.data.message, { type: 'error' });
          }
          else if (error.response.data.errors && error.response.data.errors.length > 0) {
            toast(error.response.data.errors[0], { type: 'error' });
          }
        }).finally(() => {
          setIsLoading(false)

        })
    }
  };

  return (
    <>
      <div className="signup-container">
        <div className="signup-card">
          <div className="signup_logo_title">
            <p className="signup_logo-text">Welcome Let’s</p>
            <p className="signup_logo_text_2">get started</p>
          </div>
          <div className="tab-buttons">
            <button onClick={() => navigate("/Signin", {
              state: {
                comingFrom
              }
            })}>Log in</button>
            <button className="active">Sign Up</button>
          </div>
          <form>
            <div className="input-box">
              <Input
                name="name"
                type="text"
                placeholder="Your Name"
                className="signup_input"
                onChange={handleChange}
                suffix={<UserOutlined />}
                styles={{
                  color: 'red'
                }}
              />
              {errors?.name && <p className="error_style">{errors.name}</p>}
            </div>

            <div className="input-box">
              <Input
                name="email"
                type="email"
                placeholder="Your Email"
                className="signup_input"
                onChange={handleChange}
                suffix={<MailOutlined />}
              />
              {errors?.email && <p className="error_style">{errors.email}</p>}
            </div>
            <div className="input-box " style={{ position: "relative" }}>
              <Input.Password
                name="password"
                placeholder="Password"
                onChange={handleChange}
                className="signup_input"

              />
              <p className="password_hint">At least contain one uppercase , one lowercase ,one number and one special character</p>
            </div>
            {errors?.password && (
              <p className="error_style">{errors.password}</p>
            )}

            <div className="input-box">
              <Input.Password
                name="confirmPassword"
                placeholder="Confirm Password"
                className="signup_input"
                onChange={handleChange}
              />
              {errors?.confirmPassword && (
                <p className="error_style">{errors.confirmPassword}</p>
              )}
            </div>

            <Button
              type="submit"
              loading={isLoading}
              className="signup_btn"
              onClick={(event) => {
                event.preventDefault();
                handleSubmit();
              }}
            >
              Create Account
            </Button>
          </form>
          <div className="divider">
            <hr /> <span>or</span> <hr />
          </div>
          <LoginWithGoogle comingFrom={comingFrom} />
          <Link to="/Signin" state={{ comingFrom }} className="signup_hint_link">
            <p className="signup_hint">Already have an account? Log in</p>
          </Link>
        </div>
      </div>
      <ToastContainer />
    </>
  );
}

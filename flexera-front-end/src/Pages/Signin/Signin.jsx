import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useNavigate, useLocation } from "react-router-dom";
import axios from "axios";
import LoginWithGoogle from '../../Component/LoginWithGoogle/LoginWithGoogle'
import "./style1.css";
import { Input, Button } from 'antd'
import { MailOutlined } from '@ant-design/icons'
import { ToastContainer, toast } from 'react-toastify';

export default function Signin() {
  const navigate = useNavigate();
  const location = useLocation();
  const [form, setForm] = useState({
    email: "",
    password: "",
  });
  const [errors, setErrors] = useState(null);
  const [role, setRole] = useState("user");
  const [isLoading, setIsLoading] = useState(false)
  const [isSubmitted, setIsSubmitted] = useState(false)
  const comingFrom = location.state?.comingFrom || "/";

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    let errors = {};

    if (!form.email) {
      errors.email = "Email is required";
    } else if (!/\S+@\S+\.\S+/.test(form.email)) {
      errors.email = "Email is invalid";
    } else if (!form.email.endsWith("@gmail.com")) {
      errors.email = "Email must be a Gmail address";
    }

    if (!form.password) {
      errors.password = "Password is required";
    }
    return errors;
  };

  useEffect(() => {
    if (isSubmitted) {
      const validationErrors = validate();
      setErrors(validationErrors);
    }
  }, [isSubmitted, form])


  const handleSubmit = (e) => {
    setIsSubmitted(true)
    e.preventDefault();
    const validationErrors = validate();
    setErrors(validationErrors);

    if (Object.keys(validationErrors).length === 0) {
      const data = {
        email: form.email,
        password: form.password,
        role: role
      };
      setIsLoading(true)

      axios
        .post("https://flexera.vercel.app/api/auth/login", data, {
          headers: {
            "Content-Type": "application/json",
          },
        })
        .then((response) => {
          setIsLoading(false)
          sessionStorage.setItem("token", JSON.stringify(response.data.token));
          sessionStorage.setItem("user", JSON.stringify(response.data.user));
          console.log('comingFrom>>', comingFrom)
          if (role === 'staff') {
            navigate("/Dashboard", { replace: true });
          } else {
            navigate(`${comingFrom}` ?? "/", { replace: true });
          }
        })
        .catch((error) => {
          setIsLoading(false)
          console.error('error', error)
          if (error.response.data.message) {
            toast(error.response.data.message, { type: 'error' });
          }
          else if (error.response.data.errors && error.response.data.errors.length > 0) {
            toast(error.response.data.errors[0], { type: 'error' });
          }
        });
    }
  };


  return (
    <>
      <div className="signin-container">
        <div className="login-card">
          <div className="signin_logo_title">
            <p className="signin_logo-text">Let’s</p>
            <p className="signin_logo_text_2">get started</p>
          </div>
          <div></div>
          <div className="tab-buttons">
            <button className="active">Log in </button>
            <button onClick={() => navigate("/Signup", {
              state: {
                comingFrom
              }
            })}>Sign Up</button>
          </div>
          <form className="signin_form">
            <div className="input-box">
              <Input type="email" name="email"
                placeholder="Your Email"
                onChange={handleChange}
                className="signin_input"
                suffix={<MailOutlined />}
              />
              {errors?.email && <p className="error_style">{errors.email}</p>}
            </div>
            <div className="input-box pass-cont">
              <Input.Password
                name="password"
                placeholder="Password"
                onChange={handleChange}
                className="signin_input"
              />
            </div>
            {errors?.password && (
              <p className="error_style">{errors.password}</p>
            )}

            <div className="signin_options">
              <div className="signin_remember_me">
                <label >
                  <input type="checkbox" /> Remember me
                </label>
              </div>
              <div className="signin_forgetpassword">
                <Link to="/EnterEmail" state={{ comingFrom }}
                  className="signin_forgetpassword_link" >Forgot Password?</Link>
              </div>
            </div>
            <div className="roles">
              <label>
                <input
                  type="radio"
                  name="role"
                  value="user"
                  checked={role === "user"}
                  onChange={() => setRole("user")}
                />
                User
              </label>
              <label>
                <input
                  type="radio"
                  name="role"
                  value="staff"
                  checked={role === "staff"}
                  onChange={() => setRole("staff")}
                />
                Staff
              </label>
            </div>
            <Button type="submit" loading={isLoading} className="login-btn" onClick={handleSubmit}>
              Login
            </Button>
            <p className="terms">
              <small>
                ⓘ I agree to the Terms of Service and Privacy Policy
              </small>
            </p>
            <div className="divider">
              <hr /> <span>or</span> <hr />
            </div>
            <LoginWithGoogle comingFrom={comingFrom} />
            <div
              className="signup_hint_container"
              onClick={() => navigate("/Signup", {
                state: {
                  comingFrom
                }
              })}>

              <p className="signin_hint">Don’t have an account? Sign up</p>
            </div>
          </form>
        </div >
      </div >
      <ToastContainer />

    </>
  );
}

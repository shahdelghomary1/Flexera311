import { GoogleLogin } from '@react-oauth/google';
import axios from 'axios';
import { ToastContainer, toast } from 'react-toastify';
import { useNavigate } from "react-router-dom";
import './LoginWithGoogle.css'

function LoginWithGoogle({ comingFrom }) {
    const navigate = useNavigate();
    const handleLoginWithGoogle = (data) => {
        const body = {
            credential: data?.credential
        }

        axios.post('https://flexera.vercel.app/api/auth/google', body, {
            headers: {
                "Content-Type": "application/json",
            }
        }).then((response) => {
            console.log('response', response)
            sessionStorage.setItem("user", JSON.stringify(response.data.user));
            sessionStorage.setItem("token", JSON.stringify(response.data.token));
            if (response.data.user.role === 'staff') {
                navigate("/Dashboard", { replace: true });
            } else {
                navigate(`${comingFrom}` ?? "/", { replace: true });
            }
        }).catch((error) => {
            console.log('errororor', error)
            if (error.response.data.message) {
                toast(error.response.data.message, { type: 'error' });
            }
            else if (error.response.data.errors && error.response.data.errors.length > 0) {
                toast(error.response.data.errors[0], { type: 'error' });
            }
        });


    }

    return (
        <div className='LoginWithGoogleContainer'>
            <GoogleLogin
                onSuccess={credentialResponse => {
                    console.log('credentialResponse', credentialResponse);
                    handleLoginWithGoogle(credentialResponse)
                }}
                onError={() => {
                    console.log("Login Failed");
                }}
                size='large'
            />
            <ToastContainer />
        </div>
    )
}

export default LoginWithGoogle
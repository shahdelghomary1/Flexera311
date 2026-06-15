import Navbar from '../../../Component/Navbar/Navbar'
import paymentSteps from '../../../assets/images/paymentSteps.png'
import paymentSuccess from '../../../assets/images/paymentSuccess.gif'
import close_icon from '../../../assets/images/close_icon.png'
import { useNavigate } from "react-router-dom";

import './PaymentSuccess.css'

function PaymentSuccess() {
    const navigate = useNavigate()

    const handleGoingBack = () => {
        navigate('/Booking') 
    }

    return (
        <div className='PaymentSuccess_page'>
            <Navbar activeTab={1} />
            <div className='center_content'>
                <div className='PaymentSuccessContainer' >
                    <div className='titleContianer'>
                        <div>
                            <p className='payment_success_title'>Appointment </p>
                            <p className='payment_success_title'>confirmed</p></div>
                        <div className='closeContainer' onClick={handleGoingBack}>
                            <img src={close_icon} alt='close_icon' />
                        </div>
                    </div>
                    <div className='payment_steps_container'>
                        <img src={paymentSteps} alt='paymentSteps' />
                    </div>
                    <div className='payment_success_info'>

                        <div className='payment_success_gif_container'>
                            <img src={paymentSuccess} alt='paymentSuccess' className='payment_success_gif' />
                        </div>                    <div>
                            <p className='payment_success_info_title'>
                                We look forward to seeing you at your scheduled time.
                            </p>
                            <p className='payment_success_info_subtitle'>Wishing you a smooth and healthy visit!</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    )
}

export default PaymentSuccess
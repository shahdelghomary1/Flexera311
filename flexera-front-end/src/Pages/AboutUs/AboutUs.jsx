import Navbar from '../../Component/Navbar/Navbar'
import separator from '../../assets/images/separator.png';
import aboutUs from '../../assets/images/aboutUs.gif';
import arrow from '../../assets/images/arrow.png'
import './AboutUs.css'
import HomeFooter from '../../Component/HomeFooter/HomeFooter';
import starImage from "../../assets/images/star.png";
import ourValueLineImage from "../../assets/images/our_value_line.png";

function AboutUs() {
    return (
        <div >
            <Navbar activeTab={3} />
            <div className='about_us_container'>
                <div className='about_us_first_section'>
                    <div className='aboutus_info_section1'>
                        <h1 className='aboutus_section1_title'>Why US?</h1>
                        <img src={separator} alt='separator' className='why_us_separator' />
                        <p className='aboutus_section1_desc'>
                            Flexera provides personalized physical therapy solutions that help you recover faster and stay healthy. Our expert therapists and easy-to-use platform make your wellness journey simple and effective.
                        </p>
                    </div>
                    <div className='aboutus_image_section1'>
                        <div className='rectangle1'></div>
                        <img src={aboutUs} alt='aboutUs' className='aboutUs_gif' />
                        <div className='rectangle2'></div>
                    </div>

                </div>

                <div className='about_us_second_section'>
                    <div className='mission_section'>
                        <p className='aboutus_mission_title'>Our Mission</p>
                        <div className='arrow_img_whyus_container'>
                            <img src={arrow} alt='arrow' className='arrow_img_whyus' />
                        </div>
                    </div>
                    <div className='aboutus_mission_container'>
                        <div className='aboutus_mission_content'>
                            <p className='mission_text'>
                                Our mission is to restore mobility, relieve pain, and improve quality of life through accessible, high-quality physical therapy services. We strive to bring modern rehabilitation from post-surgery recovery to chronic pain management to everyone who needs it, regardless of age or physical condition.
                            </p>
                        </div>
                        <div className='aboutus_mission_content'>
                            <p className='mission_text'>We aim to empower individuals to live active, healthy lives without relying unnecessarily on medications or invasive treatments. Through education, personalized care, and ongoing support, we want to make physical wellness a realistic goal for all</p>
                        </div>
                    </div>
                </div>

                <div className="about_us_third_section">
                    <h2 className="our-value-title">Our Value</h2>
                    <div className='title_underline_container'>
                        <img src={ourValueLineImage} alt="Our Value Underline" className="our-value-underline" />
                    </div>
                    <div className="our-value-box">
                        <p className="our-value-text">
                            We provide compassionate, personalized care delivered by certified professionals you can trust.
                        </p>
                        <p className="our-value-text">
                            With clear communication and honest guidance, we help you understand your body and take control of your recovery.
                            Our focus goes beyond pain relief - we support long-term mobility, strength, and complete well-being.
                        </p>
                        <img src={starImage} alt="Star Left" className="star_image left_star" />
                        <img src={starImage} alt="Star Right" className="star_image right_star" />
                    </div>
                </div>
            </div>
            <HomeFooter />
        </div>
    )
}

export default AboutUs
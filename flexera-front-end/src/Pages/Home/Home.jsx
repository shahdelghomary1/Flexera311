import IntroSection from "../../Component/IntroSection/IntroSection";
import ServiceSection from "../../Component/ServiceSection/ServiceSection";
import HowItWorkSection from "../../Component/HowItWorkSection/HowItWorkSection";
import ExpertsSection from "../../Component/ExpertsSection/ExpertsSection";
import DownloadSection from "../../Component/DownloadSection/DownloadSection";
import HomeFooter from "../../Component/HomeFooter/HomeFooter";
import Navbar from "../../Component/Navbar/Navbar";
import "./Home.css";

const Home = () => {
  return (
    <div className="home_page">
      <Navbar activeTab={0} />
      <IntroSection />
      <ServiceSection />
      <HowItWorkSection />
      <ExpertsSection />
      <DownloadSection />
      <HomeFooter />
    </div>
  );
};

export default Home;

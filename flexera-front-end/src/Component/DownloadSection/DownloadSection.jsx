import googlePlay from "../../assets/images/googlePlay.png";
import appStore from "../../assets/images/appStore.png";
import download from "../../assets/images/download.png";
import "./DownloadSection.css";

function DownloadSection() {
  return (
    <div className="download_section">
      <div className="download_section_img">
        <img src={download} alt="download" />
      </div>
      <div className="download_section_info">
        <p className="download_section_title">Your Recovery Starts Here</p>
        <div className="download_section_img_small_screen">
          <img src={download} alt="download" />
        </div>
        <div className="download_section_desc_container">
          <p>At Flexera, we bring expert physiotherapy closer to you.</p>
          <p>
            Our Application offers educational articles, treatment insights, and
            online booking to make your recovery journey easier.
          </p>
          <div className="download_section_links">

            <img src={appStore} alt="appStore" />
            <img src={googlePlay} alt="googlePlay" />

          </div>
        </div>
      </div>
    </div>
  );
}

export default DownloadSection;

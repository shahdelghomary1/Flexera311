import introImage from "../../assets/images/introImage.png";
import reviewImg from "../../assets/images/review.png";
import "./IntroSection.css";

function IntroSection() {
  return (
    <div className="intro_section_container">
      <div className="intro_section_content">
        <div className="intro_section_info_container">
          <div className="intro_section_title">
            <p className="intro_section_title_first_part intro_section_gradient_text">
              With you in
            </p>
            <span className="intro_section_title_second_part intro_section_gradient_text2">
              Every Step
            </span>

            <p className="intro_section_title_first_part intro_section_gradient_text_small_screen">
              With you in     Every Step
            </p>
          </div>
          <div className="intro_section_discription">
            <p className="intro_section_discription_info">
              whole community standing with you making your recovery journey
              easier, smarter, and more meaningful
            </p>
          </div>
          <div className="intro_section_review_section">
            <img
              src={reviewImg}
              alt="review"
              className="intro_section_review_img"
            />
            <div>
              <p className="intro_section_review_section_desc">
                Over <span className="intro_section_bold_text">100,000+</span>{" "}
                users are
              </p>
              <p className="intro_section_review_section_desc">
                actively using the app
              </p>
            </div>
          </div>
        </div>
        <div className="intro_section_img_container">
          <img src={introImage} alt="intro_img" className="intro_img" />
        </div>
        <div className="intro_section_review_section_small_screen">
          <img
            src={reviewImg}
            alt="review"
            className="intro_section_review_img"
          />
          <div>
            <p className="intro_section_review_section_desc">
              Over <span className="intro_section_bold_text">100,000+</span>{" "}
              users are
            </p>
            <p className="intro_section_review_section_desc">
              actively using the app
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default IntroSection;

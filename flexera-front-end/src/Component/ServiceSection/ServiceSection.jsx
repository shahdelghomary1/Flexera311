import { useState } from "react";
import { servicesList } from "../../constant";
import "./ServiceSection.css";

function ServiceSection() {
  const [activeService, setActiveService] = useState(0);
  return (
    <div className="services_section">
      <p className="service_title">Our Services </p>
      <div className="small_services_container">
        {servicesList.map((serviceItem, index) => {
          return (
            <div className={activeService === index ? "small_active_card_container" : ""}>
              <div
                onClick={() => setActiveService(index)}
                className={
                  activeService === index
                    ? "small_single_active_service_container "
                    : "small_single_static_service_container"
                }
              >
                <img
                  src={
                    activeService === index
                      ? serviceItem.activeImg
                      : serviceItem.smallStaticImg
                  }
                  alt={`service_${index}`}
                  className={
                    activeService === index ? "activeImage" : "smallStaticImage"
                  }
                />
              </div>

              {activeService === index && (
                <div className="small_active_overlay">
                  <p className="service_name">{serviceItem.serviceName}</p>
                  <p className="subtitle">{serviceItem.subtitle}</p>
                </div>
              )}
            </div>
          );
        })}
      </div>

      <div className="services_container">
        {servicesList.map((serviceItem, index) => {
          return (
            <div
              onClick={() => setActiveService(index)}
              className={
                activeService === index
                  ? "single_active_service_container"
                  : "single_static_service_container"
              }
            >
              <img
                src={
                  activeService === index
                    ? serviceItem.activeImg
                    : serviceItem.staticImg
                }
                alt={`service_${index}`}
                className={
                  activeService === index ? "activeImage" : "staticImage"
                }
              />

              {activeService === index && (
                <div className="active_overlay">
                  <p className="service_name">{serviceItem.serviceName}</p>
                  <p className="subtitle">{serviceItem.subtitle}</p>
                </div>
              )}
              {activeService !== index && index !== 0 && (
                <div className="static_overlay">
                  <p className="service_name">{serviceItem.serviceName}</p>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default ServiceSection;

import service1 from "./assets/images/service1.gif";
import service2 from "./assets/images/service2.gif";
import service3 from "./assets/images/service3.gif";
import service4 from "./assets/images/service4.gif";
import service0static from './assets/images/service0static.png'
import staticService2 from "./assets/images/staticService2.png";
import staticService3 from "./assets/images/staticService3.png";
import staticService4 from "./assets/images/staticService4.png";
import smallservices0 from './assets/images/smallservices0.png'
import smallServices1 from './assets/images/smallServices1.png';
import smallService2 from './assets/images/smallService2.png'
import smallServices3 from './assets/images/smallServices3.png'

export const servicesList = [
  {
    staticImg: service0static,
    activeImg: service1,
    smallStaticImg: smallservices0,
    serviceName: "Exercise",
    subtitle: "Exercises for your recovery",
  },
  {
    staticImg: staticService2,
    activeImg: service2,
    smallStaticImg: smallServices1,
    serviceName: "Progress",
    subtitle: " Healing naturally, one step at a time.",
  },
  {
    staticImg: staticService3,
    activeImg: service3,
    smallStaticImg: smallService2,
    serviceName: "Tips",
    subtitle: "Feel better with quick tips",
  },
  {
    staticImg: staticService4,
    activeImg: service4,
    smallStaticImg: smallServices3,
    serviceName: "Booking",
    subtitle: "Book your session in seconds",
  },
];

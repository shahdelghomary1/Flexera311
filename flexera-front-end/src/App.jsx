import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Signin from "./Pages/Signin/Signin";
import Signup from "./Pages/Signup/Signup";
import Home from "./Pages/Home/Home";
import EnterEmail from "./Pages/EnterEmail/EnterEmail";
import CheckEmail from "./Pages/CheckEmail/CheckEmail";
import CreatePassword from "./Pages/CreatePassword/CreatePassword";
import Booking from "./Pages/Booking/SelectDoctor/SelectDoctor";
import SelectAppointments from './Pages/Booking/SelectAppointments/SelectAppointments';
import PaymentDetails from './Pages/Booking/PaymentDetails/PaymentDetails';
import PaymentSuccess from "./Pages/Booking/PaymentSuccess/PaymentSuccess";
import Dashboard from "./Pages/Dashboard/Dashboard";
import ContactUs from './Pages/ContactUs/ContactUs.jsx';
import AboutUs from './Pages/AboutUs/AboutUs';
import PublicRoute from './PublicRoute.jsx'
import AuthRoute from './AuthRoute';
import PrivateUserRoute from "./PrivateUserRoute.jsx";
import PrivateAdminRoute from './PrivateAdminRoute.jsx'
import { GoogleOAuthProvider } from '@react-oauth/google';

const google_client_id = "145334392661-5rjoo4ukvqgo7ckueasn2l27d09bd2hj.apps.googleusercontent.com";

function App() {
  return (
    <GoogleOAuthProvider clientId={google_client_id}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={
            <PublicRoute>
              <Home />
            </PublicRoute>}
          />

          <Route path="ContactUs" element={
            <PublicRoute>
              <ContactUs />
            </PublicRoute>}
          />

          <Route path="AboutUs" element={
            <PublicRoute>
              <AboutUs />
            </PublicRoute>}
          />

          <Route path="Signup" element={
            <AuthRoute>
              <Signup />
            </AuthRoute>}
          />
          <Route path="Signin" element={
            <AuthRoute>
              <Signin />
            </AuthRoute>
          }
          />
          <Route path="EnterEmail" element={
            <AuthRoute>
              <EnterEmail />
            </AuthRoute>
          } />
          <Route path="CheckEmail" element={
            <AuthRoute>
              <CheckEmail />
            </AuthRoute>}
          />
          <Route path="CreatePassword" element={
            <AuthRoute>
              <CreatePassword />
            </AuthRoute>} />
          <Route
            path="Booking"
            element={
              <PrivateUserRoute>
                <Booking />
              </PrivateUserRoute>
            }
          />
          <Route
            path="SelectAppointments"
            element={
              <PrivateUserRoute>
                <SelectAppointments />
              </PrivateUserRoute>
            }
          />
          <Route
            path="PaymentDetails"
            element={
              <PrivateUserRoute>
                <PaymentDetails />
              </PrivateUserRoute>
            }
          />
          <Route
            path="paymentSuccess"
            element={
              <PrivateUserRoute>
                <PaymentSuccess />
              </PrivateUserRoute>
            }
          />
          <Route
            path="Dashboard"
            element={
              <PrivateAdminRoute>
                <Dashboard />
              </PrivateAdminRoute>
            }
          />
        </Routes>
      </BrowserRouter>
    </GoogleOAuthProvider>
  );
}

export default App;

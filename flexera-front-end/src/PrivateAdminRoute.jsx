import { Navigate, useLocation } from "react-router-dom";
import { getToken } from "./utility";
import { getUser } from './utility'

const PrivateAdminRoute = ({ children }) => {
  const isAuthenticated = !!getToken();
  const location = useLocation();
  const currentLocation = location.pathname
  const user = getUser()
  if (isAuthenticated && user?.role === 'staff') return children
  if (isAuthenticated && user?.role === 'user') return <Navigate to="/" />
  if (!isAuthenticated) {
    return <Navigate to="/Signin" replace
      state={{
        comingFrom: currentLocation
      }} />
  }

  return null
};

export default PrivateAdminRoute;

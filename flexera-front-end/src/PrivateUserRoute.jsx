import { Navigate, useLocation } from "react-router-dom";
import { getToken } from "./utility";
import { getUser } from './utility'

const PrivateUserRoute = ({ children }) => {
  const isAuthenticated = !!getToken();
  const location = useLocation();
  const currentLocation = location.pathname
  const user = getUser()
  if (isAuthenticated && user?.role === 'user') return children
  if (isAuthenticated && user?.role === 'staff') return <Navigate to="/Dashboard" />
  if (!isAuthenticated) {
    return <Navigate to="/Signin" replace
      state={{
        comingFrom: currentLocation
      }} />
  }
  return null
};

export default PrivateUserRoute;

import { Navigate } from "react-router-dom";
import { getToken } from "./utility";
import { getUser } from './utility'

const AuthRoute = ({ children }) => {
  const isAuthenticated = !!getToken();
  const user = getUser()

  if (!isAuthenticated) return children
  if (isAuthenticated && user && user.role === 'user') return <Navigate to="/" />
  if (isAuthenticated && user && user.role === 'staff') return <Navigate to="/Dashboard" />
  return null
};

export default AuthRoute;

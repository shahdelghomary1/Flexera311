import { Navigate } from "react-router-dom";
import { getToken } from "./utility";
import { getUser } from './utility'

const PublicRoute = ({ children }) => {
  const isAuthenticated = !!getToken();
  const user = getUser()
  console.log('isAuthenticated>>', isAuthenticated)
  if (!isAuthenticated || (isAuthenticated && user && user?.role === 'user')) return children
  if (isAuthenticated && user && user?.role === 'staff') return <Navigate to="/Dashboard" />
  return null
};

export default PublicRoute;

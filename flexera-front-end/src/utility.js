import moment from "moment";

export function getToken() {
  const token = JSON.parse(sessionStorage.getItem("token"));
  if (token && token?.length > 0) return token;
  return null;
}


export function getUser() {
  return JSON.parse(sessionStorage.getItem("user"));
}

export const formatTimeRange = (timeRange) => {
  if (!timeRange) return "";

  const [start] = timeRange.split(" - ");

  const startTime = moment(start, "HH:mm").format("h:mm A");

  return `${startTime}`;
};
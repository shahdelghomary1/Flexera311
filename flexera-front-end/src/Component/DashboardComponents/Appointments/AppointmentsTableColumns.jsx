import { UserOutlined } from "@ant-design/icons";

export const AppointmentsTableColumns = [
  {
    title: "User profile",
    dataIndex: ["patient", "image"],
    key: "photo",
    render: (photo) => (
      <div className="image_cell">
        {photo ? (
          <img src={photo} alt="photo" className="table_user_img" />
        ) : (
          <UserOutlined />
        )}
      </div>
    ),
  },
  {
    title: 'Appointment id',
    dataIndex: ['orderId'],
    key: 'appointmentId'
  },
  {
    title: "Patient Name",
    dataIndex: ["patient", "name"],
    key: "Patient_name",
  },
  {
    title: "Doctor",
    dataIndex: ["doctor", "name"],
    key: "doctor_name",
  },
  {
    title: "Date",
    dataIndex: "date",
    key: "date",
  },
  { title: "Time", dataIndex: "time", key: "time" },

];

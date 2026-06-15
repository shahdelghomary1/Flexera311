import { UserOutlined } from "@ant-design/icons";

export const PatientTableColumns = [
  {
    title: "User profile",
    dataIndex: "image",
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
    title: "Patient Name",
    dataIndex: "name",
    key: "Patient_Name",
  },
  {
    title: "Age",
    dataIndex: "age",
    key: "Age",
  },
  { title: "Email", dataIndex: "email", key: "email" },
  { title: "Phone Number", dataIndex: "phone", key: "phone" },

];

import { UserOutlined } from "@ant-design/icons";

export const DoctorsTableColumns = [
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
    title: "Doctor Name",
    dataIndex: "name",
    key: "doctor_Name",
  },
  {
    title: "ID",
    dataIndex: "_id",
    key: "doctor_id",
  },
  {
    title: "Price",
    dataIndex: "price",
    key: "price",
  },
  { title: "Email", dataIndex: "email", key: "email" },
  { title: "Phone Number", dataIndex: "phone", key: "phone" },

  {
    title: "Action",
    key: "action",
  },
];

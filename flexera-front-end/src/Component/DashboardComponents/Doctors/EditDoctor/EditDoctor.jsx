import { useState } from "react";
import { Button, Form, Input, Modal, Upload } from "antd";
import { PlusOutlined, ArrowRightOutlined } from "@ant-design/icons";
import logo from "../../../../assets/images/logo.png";
import { useEffect } from "react";
import "./EditDoctor.css";

function EditDoctor({
  isOpen,
  handleCloseModal,
  editedDoctor,
  editDoctorLoading,
  submitAction,
}) {
  const [form] = Form.useForm();
  const variant = Form.useWatch("variant", form);
  const [fileList, setFileList] = useState([]);

  const formItemLayout = {
    labelCol: {
      xs: { span: 24 },
      sm: { span: 6 },
    },
    wrapperCol: {
      xs: { span: 24 },
      sm: { span: 14 },
    },
  };
  const normFile = (e) => {
    if (Array.isArray(e)) {
      return e;
    }
    return e?.fileList;
  };

  useEffect(() => {
    if (editedDoctor) {
      form.setFieldsValue({
        name: editedDoctor.name,
        email: editedDoctor.email,
        phone: editedDoctor.phone,
        price: editedDoctor.price,
      });

      if (editedDoctor.image && editedDoctor.image.length > 0) {
        setFileList([
          {
            uid: "-1",
            name: "image.png",
            status: "done",
            url: editedDoctor.image,
          },
        ]);
      } else {
        setFileList([]);
      }
    }
  }, [editedDoctor, form]);

  return (
    <Modal
      closable={{ "aria-label": "Custom Close Button" }}
      open={isOpen}
      onCancel={() => {
        form.resetFields();
        handleCloseModal();
      }}
      footer={null}
    >
      <div className="doctor_action_container">
        <img src={logo} alt="logo" className="doctor_action_logo" />
        <p className="doctor_action_title">Edit Member</p>
        <p className="doctor_action_subtitle">
          Provide accurate personal details for the new member
        </p>
        <Form
          {...formItemLayout}
          form={form}
          variant={variant || "filled"}
          style={{ maxWidth: 600 }}
          onFinish={(values) => {
            submitAction({ ...values, image: fileList });
          }}
          initialValues={{
            name: editedDoctor?.name,
            email: editedDoctor?.email,
            phone: editedDoctor?.phone,
            price: editedDoctor?.price,
            image: editedDoctor?.image,
          }}
        >
          <div className="doctor_action_form_container">
            <p className="doctor_action_form_container_title">Personal data</p>
            <p className="doctor_action_form_container_subtitle">
              Please provide the member’s personal details accurately
            </p>


            <Form.Item
              label={null}
              valuePropName="fileList"
              getValueFromEvent={normFile}
            >
              <Upload
                action="/upload.do"
                listType="picture-card"
                fileList={fileList}
                onChange={({ fileList }) => setFileList(fileList)}
              >
                {fileList.length >= 1 ? null : (
                  <button
                    style={{
                      color: "inherit",
                      cursor: "inherit",
                      border: 0,
                      background: "none",
                    }}
                    type="button"
                  >
                    <PlusOutlined />
                    <div style={{ marginTop: 8 }}>Upload</div>
                  </button>
                )}
              </Upload>
            </Form.Item>
            <Form.Item
              label="Member name"
              name="name"
              rules={[{ required: true, message: "Please enter the name!" }]}
              labelCol={{ span: 24 }}
              wrapperCol={{ span: 24 }}
            >
              <Input variant="underlined" style={{ width: "100%" }} />
            </Form.Item>
            <Form.Item
              label="Price"
              name="price"
              rules={[{ required: true, message: "Please enter the Price!" }]}
              labelCol={{ span: 24 }}
              wrapperCol={{ span: 24 }}
            >
              <Input variant="underlined" style={{ width: "100%" }} />
            </Form.Item>
            <Form.Item
              label="Email"
              name="email"
              rules={[{ required: true, message: "Please enter the Email!" }]}
              labelCol={{ span: 24 }}
              wrapperCol={{ span: 24 }}
            >
              <Input
                type={"email"}
                variant="underlined"
                style={{ width: "100%" }}
              />
            </Form.Item>
            <Form.Item
              label="Phone Number"
              name="phone"
              rules={[
                { required: true, message: "Please enter the Phone Number!" },
              ]}
              labelCol={{ span: 24 }}
              wrapperCol={{ span: 24 }}
            >
              <Input variant="underlined" style={{ width: "100%" }} />
            </Form.Item>

          </div>
          <Form.Item label={null}
            style={{ margin: '0 64px', }}
            labelCol={{ span: 24 }}
            wrapperCol={{ span: 24 }}>
            <div className="submit_btn_style_div">
              <Button
                type="primary"
                htmlType="submit"
                loading={editDoctorLoading}
                className="submit_btn_style"
              >
                Submit{" "}
                <ArrowRightOutlined />
              </Button>
            </div>
          </Form.Item>
        </Form>
      </div>
    </Modal >
  );
}

export default EditDoctor;

import { Button, Form, Input, Modal, Upload, Row, Col, InputNumber, } from "antd";
import { PlusOutlined, ArrowRightOutlined } from "@ant-design/icons";
import logo from "../../../../assets/images/logo.png";
import "./AddDoctor.css";

function AddDoctor({
  isOpen,
  handleCloseModal,
  addDoctorLoading,
  submitAction,
}) {
  const [form] = Form.useForm();
  const variant = Form.useWatch("variant", form);
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

  return (
    <Modal
      style={{ top: 20, padding: 0 }}
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
        <p className="doctor_action_title">Add Member</p>
        <p className="doctor_action_subtitle">
          Provide accurate personal details for the new member
        </p>
        <Form
          {...formItemLayout}
          form={form}
          variant={variant || "filled"}
          style={{ maxWidth: 600 }}
          initialValues={{ variant: "filled" }}
          onFinish={(values) => {
            form.resetFields();
            submitAction(values);
          }}
        >
          <div className="doctor_action_form_container">
            <p className="doctor_action_form_container_title">Personal data</p>
            <p className="doctor_action_form_container_subtitle">
              Please provide the member’s personal details accurately
            </p>

            <Form.Item
              name="image"
              label={null}
              rules={[
                { required: true, message: "Please enter upload image!" },
              ]}
              valuePropName="image"
              getValueFromEvent={normFile}
            >
              <Upload action="/upload.do" listType="picture-card">
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
              label="ID"
              name="_id"
              rules={[{ required: true, message: "Please enter the ID!" },
              { max: 6, message: 'The Id must be 6 characters' },
              { min: 6, message: 'The Id must be 6 characters' },
              ]}
              labelCol={{ span: 24 }}
              wrapperCol={{ span: 24 }}
            >
              <Input
                type={"text"}
                variant="underlined"
                maxLength={6}
                style={{ width: "100%" }}
              />
            </Form.Item>

            <Form.Item
              label="Price"
              name="price"
              rules={[{ required: true, message: "Please enter the Price!" },
              { type: 'number', max: 2000, message: 'Maximum price is 2000 EGP' },
              ]}
              labelCol={{ span: 24 }}
              wrapperCol={{ span: 24 }}
            >
              <InputNumber min={0} variant="underlined" style={{ width: "100%" }} />
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
              <Input variant="underlined" style={{ width: "100%" }} size="large" className="doctor_form_input" />
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
                loading={addDoctorLoading}
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

export default AddDoctor;

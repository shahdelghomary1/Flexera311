
import './Stepper.css'
const Stepper = ({ activeStep = 3 }) => {
    return (
        <div className='stepper_container'>
            <div className={`single_step ${activeStep === 1 ? 'step1_round' : 'normal_step'}`}>
                <h1 className='step_text'>Step 1</h1>
            </div>

            <div className={`single_step ${activeStep === 2 ? 'step2_round' : 'normal_step'}`}>
                <h1 className='step_text'>Step 2</h1>
            </div>

            <div className={`single_step ${activeStep === 3 ? 'step3_round' : 'normal_step'}`}>
                <h1 className='step_text'>Step 3</h1>
            </div>


        </div>
    )
}

export default Stepper
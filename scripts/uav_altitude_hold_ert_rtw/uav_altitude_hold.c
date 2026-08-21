/*
 * File: uav_altitude_hold.c
 *
 * Code generated for Simulink model 'uav_altitude_hold'.
 *
 * Model version                  : 1.11
 * Simulink Coder version         : 26.1 (R2026a) 20-Nov-2025
 * C/C++ source code generated on : Fri Aug 21 12:59:24 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "uav_altitude_hold.h"
#include "rtwtypes.h"
#include <string.h>

/* Block states (default storage) */
DW_uav_altitude_hold_T uav_altitude_hold_DW; /* polyspace MISRA-C-2023:8.7 [Justified:Low] "ERT main/integration TU sets/reads this struct" */

/* External inputs (root inport signals with default storage) */
ExtU_uav_altitude_hold_T uav_altitude_hold_U; /* polyspace MISRA-C-2023:8.7 [Justified:Low] "ERT main/integration TU sets/reads this struct" */

/* External outputs (root outports fed by signals with default storage) */
ExtY_uav_altitude_hold_T uav_altitude_hold_Y; /* polyspace MISRA-C-2023:8.7 [Justified:Low] "ERT main/integration TU sets/reads this struct" */

/* Model step function */
void uav_altitude_hold_step(void)
{
  real_T rtb_AltitudeError;

  /* Sum: '<S1>/Altitude Error' incorporates:
   *  Inport: '<Root>/alt_cmd'
   *  Inport: '<Root>/alt_meas'
   */
  rtb_AltitudeError = uav_altitude_hold_U.alt_cmd - uav_altitude_hold_U.alt_meas;

  /* Switch: '<Root>/Fallback Switch' incorporates:
   *  Constant: '<S3>/Constant'
   *  Constant: '<S4>/Constant'
   *  Constant: '<S5>/Constant'
   *  Constant: '<S6>/Constant'
   *  Constant: '<S7>/Constant'
   *  Constant: '<S8>/Constant'
   *  Inport: '<Root>/alt_cmd'
   *  Inport: '<Root>/alt_meas'
   *  Inport: '<Root>/sensor_valid'
   *  Inport: '<Root>/vz_meas'
   *  Logic: '<S2>/All Conditions AND'
   *  RelationalOperator: '<S3>/Compare'
   *  RelationalOperator: '<S4>/Compare'
   *  RelationalOperator: '<S5>/Compare'
   *  RelationalOperator: '<S6>/Compare'
   *  RelationalOperator: '<S7>/Compare'
   *  RelationalOperator: '<S8>/Compare'
   */
  /* polyspace-begin MISRA-C-2023:10.1 [Justified:Low] "boolean_T operand is essentially Boolean by Simulink typedef" */
  if (((((((uav_altitude_hold_U.alt_cmd >= 0.0) && (uav_altitude_hold_U.alt_cmd <=
            500.0)) && (uav_altitude_hold_U.alt_meas >= 0.0)) &&
         (uav_altitude_hold_U.alt_meas <= 500.0)) &&
        (uav_altitude_hold_U.vz_meas >= -15.0)) && (uav_altitude_hold_U.vz_meas <=
        15.0)) && (uav_altitude_hold_U.sensor_valid)) {
  /* polyspace-end MISRA-C-2023:10.1 */
    /* Sum: '<S1>/Combine Terms' incorporates:
     *  Constant: '<S1>/Hover Trim'
     *  DiscreteIntegrator: '<S1>/Bounded Integral'
     *  Gain: '<S1>/Kd (Rate Damping)'
     *  Gain: '<S1>/Kp (Proportional)'
     */
    uav_altitude_hold_Y.throttle_cmd = (((0.04 * rtb_AltitudeError) + 0.5) +
      (-0.06 * uav_altitude_hold_U.vz_meas)) +
      uav_altitude_hold_DW.BoundedIntegral_DSTATE;

    /* polyspace-begin MISRA-C-2023:15.7 [Justified:Low] "Embedded Coder Saturate-block pattern; in-range case needs no action" */
    /* Saturate: '<S1>/Output Saturation' */
    if (uav_altitude_hold_Y.throttle_cmd > 1.0) {
      /* Sum: '<S1>/Combine Terms' incorporates:
       *  Outport: '<Root>/throttle_cmd'
       */
      uav_altitude_hold_Y.throttle_cmd = 1.0;
    } else if (uav_altitude_hold_Y.throttle_cmd < 0.0) {
      /* Sum: '<S1>/Combine Terms' incorporates:
       *  Outport: '<Root>/throttle_cmd'
       */
      uav_altitude_hold_Y.throttle_cmd = 0.0;
    }

    /* End of Saturate: '<S1>/Output Saturation' */
    /* polyspace-end MISRA-C-2023:15.7 */
  } else {
    /* Sum: '<S1>/Combine Terms' incorporates:
     *  Constant: '<Root>/Hover Fallback'
     *  Outport: '<Root>/throttle_cmd'
     */
    uav_altitude_hold_Y.throttle_cmd = 0.5;
  }

  /* End of Switch: '<Root>/Fallback Switch' */

  /* Update for DiscreteIntegrator: '<S1>/Bounded Integral' incorporates:
   *  Gain: '<S1>/Ki (Integral Gain)'
   */
  uav_altitude_hold_DW.BoundedIntegral_DSTATE += 0.02 * (0.01 *
    rtb_AltitudeError);
  /* polyspace-begin MISRA-C-2023:15.7 [Justified:Low] "Embedded Coder anti-windup clamp pattern; in-range case needs no action" */
  if (uav_altitude_hold_DW.BoundedIntegral_DSTATE > 0.3) {
    uav_altitude_hold_DW.BoundedIntegral_DSTATE = 0.3;
  } else if (uav_altitude_hold_DW.BoundedIntegral_DSTATE < -0.3) {
    uav_altitude_hold_DW.BoundedIntegral_DSTATE = -0.3;
  }
  /* polyspace-end MISRA-C-2023:15.7 */

  /* End of Update for DiscreteIntegrator: '<S1>/Bounded Integral' */
}

/* Model initialize function */
void uav_altitude_hold_initialize(void)
{
  /* Registration code */

  /* states (dwork) */
  (void) memset((void *)&uav_altitude_hold_DW, 0,
                sizeof(DW_uav_altitude_hold_T));

  /* external inputs */
  (void)memset(&uav_altitude_hold_U, 0, sizeof(ExtU_uav_altitude_hold_T));

  /* external outputs */
  uav_altitude_hold_Y.throttle_cmd = 0.0;
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

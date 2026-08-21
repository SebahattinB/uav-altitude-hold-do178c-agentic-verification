/*
 * File: uav_altitude_hold.h
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

#ifndef uav_altitude_hold_h_
#define uav_altitude_hold_h_
#ifndef uav_altitude_hold_COMMON_INCLUDES_
#define uav_altitude_hold_COMMON_INCLUDES_
#include "rtwtypes.h"
#endif                                 /* uav_altitude_hold_COMMON_INCLUDES_ */

#include "uav_altitude_hold_types.h"
#include <string.h>

/* Block states (default storage) for system '<Root>' */
typedef struct {
  real_T BoundedIntegral_DSTATE;       /* '<S1>/Bounded Integral' */
} DW_uav_altitude_hold_T;

/* External inputs (root inport signals with default storage) */
typedef struct {
  real_T alt_cmd;                      /* '<Root>/alt_cmd' */
  real_T alt_meas;                     /* '<Root>/alt_meas' */
  real_T vz_meas;                      /* '<Root>/vz_meas' */
  boolean_T sensor_valid;              /* '<Root>/sensor_valid' */
} ExtU_uav_altitude_hold_T;

/* External outputs (root outports fed by signals with default storage) */
typedef struct {
  real_T throttle_cmd;                 /* '<Root>/throttle_cmd' */
} ExtY_uav_altitude_hold_T;

/* Block states (default storage) */
extern DW_uav_altitude_hold_T uav_altitude_hold_DW;

/* External inputs (root inport signals with default storage) */
extern ExtU_uav_altitude_hold_T uav_altitude_hold_U;

/* External outputs (root outports fed by signals with default storage) */
extern ExtY_uav_altitude_hold_T uav_altitude_hold_Y;

/* Model entry point functions */
extern void uav_altitude_hold_initialize(void);
extern void uav_altitude_hold_step(void);

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'uav_altitude_hold'
 * '<S1>'   : 'uav_altitude_hold/Control Law'
 * '<S2>'   : 'uav_altitude_hold/Input Validity Gate'
 * '<S3>'   : 'uav_altitude_hold/Input Validity Gate/AltCmd_GE_0'
 * '<S4>'   : 'uav_altitude_hold/Input Validity Gate/AltCmd_LE_500'
 * '<S5>'   : 'uav_altitude_hold/Input Validity Gate/AltMeas_GE_0'
 * '<S6>'   : 'uav_altitude_hold/Input Validity Gate/AltMeas_LE_500'
 * '<S7>'   : 'uav_altitude_hold/Input Validity Gate/Vz_GE_neg15'
 * '<S8>'   : 'uav_altitude_hold/Input Validity Gate/Vz_LE_15'
 */

/*-
 * Requirements for '<Root>': uav_altitude_hold

 */
#endif                                 /* uav_altitude_hold_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

/*
 * test_uav_altitude_hold.c
 *
 * PSTUnit C unit tests for the generated uav_altitude_hold_step()
 * function (scripts/uav_altitude_hold_ert_rtw/uav_altitude_hold.c).
 *
 * Each test calls uav_altitude_hold_initialize() then a single
 * uav_altitude_hold_step() so the bounded-integral term starts at
 * exactly 0.0; expected throttle_cmd values below are derived
 * analytically for that single-step case (throttle = 0.5 hover trim +
 * Kp*error + Kd*vz_meas, saturated to [0,1], or 0.5 fallback when any
 * input fails the validity gate).
 */

#include "pstunit.h"
#include "uav_altitude_hold.h"

PST_SUITE(uav_altitude_hold_suite);

static void reset_model(void)
{
    uav_altitude_hold_initialize();
}

static void set_inputs(real_T alt_cmd, real_T alt_meas, real_T vz_meas,
                        boolean_T sensor_valid)
{
    uav_altitude_hold_U.alt_cmd = alt_cmd;
    uav_altitude_hold_U.alt_meas = alt_meas;
    uav_altitude_hold_U.vz_meas = vz_meas;
    uav_altitude_hold_U.sensor_valid = sensor_valid;
}

/* Nominal: positive altitude error produces above-trim throttle. */
PST_TEST_CONFIG(uav_altitude_hold_suite, nominal_positive_error) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, nominal_positive_error) {
    set_inputs(60.0, 50.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.9, 1e-9);
}

/* Nominal: negative altitude error produces below-trim throttle. */
PST_TEST_CONFIG(uav_altitude_hold_suite, nominal_negative_error) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, nominal_negative_error) {
    set_inputs(40.0, 50.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.1, 1e-9);
}

/* Zero altitude error and zero rate hold exactly at hover trim. */
PST_TEST_CONFIG(uav_altitude_hold_suite, zero_error_holds_trim) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, zero_error_holds_trim) {
    set_inputs(50.0, 50.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* Positive vertical rate pulls throttle below trim (damping). */
PST_TEST_CONFIG(uav_altitude_hold_suite, rate_damping) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, rate_damping) {
    set_inputs(50.0, 50.0, 5.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.2, 1e-9);
}

/* Large positive error saturates throttle at the upper limit. */
PST_TEST_CONFIG(uav_altitude_hold_suite, output_saturates_high) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, output_saturates_high) {
    set_inputs(500.0, 0.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 1.0, 1e-9);
}

/* Large negative error saturates throttle at the lower limit. */
PST_TEST_CONFIG(uav_altitude_hold_suite, output_saturates_low) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, output_saturates_low) {
    set_inputs(0.0, 500.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.0, 1e-9);
}

/* Sensor-invalid flag forces the 0.5 hover fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_sensor_invalid) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_sensor_invalid) {
    set_inputs(60.0, 50.0, 0.0, ((boolean_T)0));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* alt_cmd below the [0,500] valid range forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_alt_cmd_below_range) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_alt_cmd_below_range) {
    set_inputs(-10.0, 50.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* alt_cmd above the [0,500] valid range forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_alt_cmd_above_range) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_alt_cmd_above_range) {
    set_inputs(600.0, 50.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* alt_meas below the [0,500] valid range forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_alt_meas_below_range) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_alt_meas_below_range) {
    set_inputs(60.0, -10.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* alt_meas above the [0,500] valid range forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_alt_meas_above_range) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_alt_meas_above_range) {
    set_inputs(60.0, 600.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* vz_meas below the [-15,15] valid range forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_vz_below_range) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_vz_below_range) {
    set_inputs(60.0, 50.0, -20.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* vz_meas above the [-15,15] valid range forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_vz_above_range) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_vz_above_range) {
    set_inputs(60.0, 50.0, 20.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

/* Non-finite alt_cmd fails the range checks and forces the fallback. */
PST_TEST_CONFIG(uav_altitude_hold_suite, fallback_non_finite_input) {
    PST_SETUP(reset_model);
}
PST_TEST_BODY(uav_altitude_hold_suite, fallback_non_finite_input) {
    set_inputs((real_T)(0.0 / 0.0), 50.0, 0.0, ((boolean_T)1));
    uav_altitude_hold_step();
    PST_VERIFY_EQ_APPROX_FLT(uav_altitude_hold_Y.throttle_cmd, 0.5, 1e-9);
}

int main(int argc, char* argv[]) {
    PST_ADD_TEST(uav_altitude_hold_suite, nominal_positive_error);
    PST_ADD_TEST(uav_altitude_hold_suite, nominal_negative_error);
    PST_ADD_TEST(uav_altitude_hold_suite, zero_error_holds_trim);
    PST_ADD_TEST(uav_altitude_hold_suite, rate_damping);
    PST_ADD_TEST(uav_altitude_hold_suite, output_saturates_high);
    PST_ADD_TEST(uav_altitude_hold_suite, output_saturates_low);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_sensor_invalid);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_alt_cmd_below_range);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_alt_cmd_above_range);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_alt_meas_below_range);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_alt_meas_above_range);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_vz_below_range);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_vz_above_range);
    PST_ADD_TEST(uav_altitude_hold_suite, fallback_non_finite_input);
    return PST_MAIN(argc, argv);
}
